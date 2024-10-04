extends CharacterBody3D

@export var vision_range := 5.0
@export var vision_angle := PI / 3.0

func _ready() -> void:
	var state_machine := StateMachine.new()
	add_child(state_machine)

	var idle := StateIdle.new(self)
	var follow := StateFollow.new(self) #

	state_machine.transitions = {
		idle: { #
			Events.PLAYER_ENTERED_LINE_OF_SIGHT: follow, #
		}, #
		follow: { #
			Events.PLAYER_EXITED_LINE_OF_SIGHT: idle, #
		}, #
	}

	state_machine.activate(idle)


enum Events {
	NONE,
	PLAYER_EXITED_LINE_OF_SIGHT,
	PLAYER_ENTERED_LINE_OF_SIGHT,
}

class Blackboard extends RefCounted:
	static var ball_global_position := Vector3.ZERO


class StateIdle extends State:

	func _init(init_mob: CharacterBody3D) -> void:
		super("Idle", init_mob)

	func update(_delta: float) -> Events:
		var distance := mob.global_position.distance_to(Blackboard.ball_global_position)
		if distance > mob.vision_range:
			return Events.NONE

		var direction := mob.global_position.direction_to(Blackboard.ball_global_position)
		var player_in_vision_cone := mob.global_basis.z.dot(direction) > cos(mob.vision_angle)
		if player_in_vision_cone:
			return Events.PLAYER_ENTERED_LINE_OF_SIGHT
		return Events.NONE


class StateFollow extends State:

	var follow_speed := 2.0 #var follow_speed := 0.0
	var drag_factor := 10.0 #var drag_factor := 10.0

	func _init(init_mob: CharacterBody3D) -> void:
		super("Follow", init_mob) # pass

	func update(delta: float) -> Events:
		# Steer towards the ball using the "follow" steering behavior.
		# Use Vector3.move_toward() to steer the current velocity toward the desired velocity.
		var ball_position := Blackboard.ball_global_position # return Events.NONE
		var desired_velocity := mob.global_position.direction_to(ball_position) * follow_speed #
		var velocity_distance := mob.velocity.distance_to(desired_velocity) #
		mob.velocity = mob.velocity.move_toward( #
			desired_velocity, velocity_distance * drag_factor * delta #
		) #
		mob.move_and_slide() #

		var direction := mob.global_position.direction_to(ball_position) #
		mob.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI #

		var distance := mob.global_position.distance_to(ball_position) #
		if distance > mob.vision_range: #
			return Events.PLAYER_EXITED_LINE_OF_SIGHT #
		return Events.NONE #


# Below is a simplified copy of the state machine code from the lessons. Feel
# free to read the code for reference, but note that you don't have to edit
# anything down there.
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
		current_state = new_state
		state_changed.emit(current_state)
		current_state.enter()
