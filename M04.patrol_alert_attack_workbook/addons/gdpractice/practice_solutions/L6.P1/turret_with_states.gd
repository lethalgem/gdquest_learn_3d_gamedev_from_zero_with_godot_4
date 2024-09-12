extends CharacterBody3D

@export var bullet_spawning_point: Node3D = null
@export var bullet_scene: PackedScene = null


func _ready() -> void:
	var state_machine := StateMachine.new()
	add_child(state_machine)

	var wait := StateWait.new(self)
	var shoot_bullet := StateShootBullet.new(self, bullet_spawning_point, bullet_scene) #

	state_machine.transitions = {
		wait: {Events.FINISHED: shoot_bullet}, #
		shoot_bullet: {Events.FINISHED: wait}, #
	}

	state_machine.activate(wait)


class StateShootBullet extends State:

	var bullet_spawn_point: Node3D = null
	var bullet_scene: PackedScene = null

	func _init(
		init_mob: CharacterBody3D,
		init_spawning_point: Node3D,
		init_projectile_scene: PackedScene
	) -> void:
		super("Shoot Bullet", init_mob)
		bullet_spawn_point = init_spawning_point #
		bullet_scene = init_projectile_scene #

	func enter() -> void:
		var bullet: Node3D = bullet_scene.instantiate() # pass
		mob.add_sibling(bullet) #

		bullet.global_position = bullet_spawn_point.global_position #
		bullet.look_at(bullet_spawn_point.global_position + bullet_spawn_point.global_basis.z) #

		finished.emit() #



# Below is a simplified copy of the state machine code from the lessons. Feel
# free to read the code for reference, but note that you don't have to edit
# anything down there.
enum Events {
	NONE,
	FINISHED,
}


class State extends RefCounted:
	signal finished

	var name := "State"
	var mob: CharacterBody3D = null

	func _init(init_name: String, init_mob: CharacterBody3D) -> void:
		name = init_name
		mob = init_mob

	func update(_delta: float) -> Events:
		return Events.NONE

	func enter() -> void:
		pass

	func exit() -> void:
		pass


class StateWait extends State:

	var duration := 0.5
	var _time := 0.0

	func _init(init_mob: CharacterBody3D) -> void:
		super("Wait", init_mob)

	func enter() -> void:
		_time = 0.0

	func update(delta: float) -> Events:
		_time += delta
		if _time >= duration:
			return Events.FINISHED
		return Events.NONE


# Compared to the lessons, this version of the state machine uses defensive code to not cause errors while you're following the practice.
# I've also added a signal to notify when the state changes.
class StateMachine extends Node:

	signal state_changed(new_state: State)

	var transitions := {}
	var current_state: State

	func _init() -> void:
		set_physics_process(false)


	func activate(initial_state: State = null) -> void:
		if initial_state != null:
			current_state = initial_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		current_state.enter()
		set_physics_process(true)


	func trigger_event(event: Events) -> void:
		if current_state in transitions and event in transitions[current_state]:
			var next_state = transitions[current_state][event]
			_transition(next_state)


	func _physics_process(delta: float) -> void:
		if current_state in transitions:
			var event := current_state.update(delta)
			if event != Events.NONE and event in transitions[current_state]:
				trigger_event(event)


	func _transition(new_state: State) -> void:
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
		current_state.finished.connect(_on_state_finished.bind(current_state))
		state_changed.emit(current_state)
		current_state.enter()


	func _on_state_finished(finished_state: State) -> void:
		if finished_state in transitions and Events.FINISHED in transitions[finished_state]:
			_transition(transitions[finished_state][Events.FINISHED])
