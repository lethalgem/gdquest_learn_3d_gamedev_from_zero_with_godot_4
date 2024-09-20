class_name AI extends RefCounted

enum Events {
	NONE,
	FINISHED,
}

class State extends RefCounted:

	signal finished

	## Display name of the state, for debugging purposes.
	var name := "State"
	## Reference to themob that the state controls.
	var mob: Mob3D = null

	func _init(init_name: String, init_mob: Mob3D) -> void:
		name = init_name
		mob = init_mob

	func update(_delta: float) -> Events:
		return Events.NONE

	func enter() -> void:
		pass

	func exit() -> void:
		pass

class StateMachine extends Node:

	var transitions := {}: set = set_transitions
	var current_state: State

	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but go " + str(state)
				)
				for event: Events in transitions[state]:
					assert(
						event is Events,
						"Invalid event in the transitions dictionary. " +
						"Expected an events object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)

	func _init() -> void:
		set_physics_process(false)

	func activate(initial_state: State = null) -> void:
		if initial_state != null:
			current_state = initial_state
		assert(
			current_state != null,
			"Activated the state machine but the state variable is null. " +
			"Please assign a starting state to the state machine."
		)
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		set_physics_process(true)

	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Events.NONE:
			return
		trigger_event(event)

	func trigger_event(event: Events) -> void:
		assert(
			transitions[current_state],
			"Current state doesn't exist in the transitions dictionary."
		)
		if not transitions[current_state].has(event):
			print_debug(
				"Trying to trigger event " + Events.keys()[event] +
				" from state " + current_state.name +
				" but the transition does not exist."
			)
			return
		var next_state = transitions[current_state][event]
		_transition(next_state)

	func _transition(new_state: State) -> void:
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])

class Blackboard extends RefCounted:
	static var player_global_position := Vector3.ZERO


