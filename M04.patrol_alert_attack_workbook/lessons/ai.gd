class_name AI extends RefCounted

enum Events {
	NONE,
	FINISHED,
	PLAYER_ENTERED_LINE_OF_SIGHT,
	PLAYER_EXITED_LINE_OF_SIGHT,
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
		print("exiting: " + current_state.name)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		print("entering: " + current_state.name)

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])

class Blackboard extends RefCounted:
	static var player_global_position := Vector3.ZERO

class StateIdle extends State:

	func _init(init_mob: Mob3D) -> void:
		super("Idle", init_mob)

	func enter() -> void:
		mob.skin.play("idle")

	func update(_delta: float) -> Events:
		var distance: float = mob.global_position.distance_to(Blackboard.player_global_position)
		if distance > mob.vision_range:
			return Events.NONE

		var cos_max_angle_of_vision := cos(mob.vision_angle)
		var direction: Vector3 = mob.global_position.direction_to(Blackboard.player_global_position)
		var dot: float = mob.global_basis.z.dot(direction)

		var player_in_vision_cone := dot > cos_max_angle_of_vision
		if player_in_vision_cone:
			return Events.PLAYER_ENTERED_LINE_OF_SIGHT

		return Events.NONE

class StateLookAtPlayer extends State:

	func _init(init_mob: Mob3D) -> void:
		super("Look at Player", init_mob)

	var duration := 2.0
	var _time := 0.0

	func enter() -> void:
		_time = 0.0

	func update(delta: float) -> Events:
		_time += delta
		if _time >= duration:
			return Events.FINISHED

		var player_distance: float = mob.global_position.distance_to(
			Blackboard.player_global_position
		)
		if player_distance > mob.vision_range:
			return Events.PLAYER_EXITED_LINE_OF_SIGHT

		var direction: Vector3 = mob.global_position.direction_to(
			Blackboard.player_global_position
		)
		var target_rotation_y := Vector3.FORWARD.signed_angle_to(
			direction, Vector3.UP
		) + PI
		mob.rotation.y = lerp_angle(
			mob.rotation.y, target_rotation_y, 2.0 * delta
		)
		return Events.NONE

class StateWait extends State:

	var duration := 0.5
	var _time := 0.0

	func _init(init_mob: Mob3D) -> void:
		super("Wait", init_mob)

	func enter() -> void:
		_time = 0.0
		mob.skin.play("idle")

	func update(delta: float) -> Events:
		_time += delta
		if _time >= duration:
			return Events.FINISHED
		return Events.NONE

class StateFireProjectile extends State:

	var spawning_point: Node3D = null
	var projectile_scene: PackedScene = null

	func _init(
		init_mob: Mob3D,
		init_spawning_point: Node3D,
		init_projectile_scene: PackedScene
	) -> void:
		super("Fire Projectile", init_mob)
		spawning_point = init_spawning_point
		projectile_scene = init_projectile_scene

	func enter() -> void:
		var projectile: Projectile3D = projectile_scene.instantiate()
		mob.add_sibling(projectile)

		projectile.global_position = spawning_point.global_position
		projectile.look_at(spawning_point.global_position + spawning_point.global_basis.z)

		finished.emit()