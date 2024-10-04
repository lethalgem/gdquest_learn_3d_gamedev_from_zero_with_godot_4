## This script demonstrates how to implement a reusable state machine for mobs
## in a 3D game.
## In this game, this single file contains all the shared logic for mob behaviors.
#ANCHOR:class_name
class_name AI extends RefCounted
#END:class_name

## List of the possible events that can trigger a transition between states.
## These events are returned from each [AI.State]'s [method AI.State.update]
## method or injected into the state machine from other parts of the game by
## calling [method AI.StateMachine.trigger_event].
##
## Return [constant AI.Events.NONE] from the state's [method AI.State.update] to
## indicate that no transition is needed.
##
## The [constant AI.Events.FINISHED] event is a special event that is triggered
## when the state emits its [signal AI.State.finished] signal. It is used to
## transition to the next state in the state machine.
#ANCHOR:enum_events_definition
enum Events {
	#END:enum_events_definition
	#ANCHOR:enum_events_NONE
	NONE,
	#END:enum_events_NONE
	#ANCHOR:enum_events_FINISHED
	FINISHED,
	#END:enum_events_FINISHED

	#ANCHOR:enum_events_PLAYER_EXITED_LINE_OF_SIGHT
	PLAYER_EXITED_LINE_OF_SIGHT,
	#END:enum_events_PLAYER_EXITED_LINE_OF_SIGHT
	#ANCHOR:enum_events_PLAYER_ENTERED_LINE_OF_SIGHT
	PLAYER_ENTERED_LINE_OF_SIGHT,
	#END:enum_events_PLAYER_ENTERED_LINE_OF_SIGHT
	#ANCHOR:enum_events_PLAYER_ENTERED_ATTACK_RANGE
	PLAYER_ENTERED_ATTACK_RANGE,
	#END:enum_events_PLAYER_ENTERED_ATTACK_RANGE

	#ANCHOR:enum_events_PLAYER_TOOK_DAMAGE
	TOOK_DAMAGE,
	#END:enum_events_PLAYER_TOOK_DAMAGE
	#ANCHOR:enum_events_PLAYER_HEALTH_DEPLETED
	HEALTH_DEPLETED,
	#END:enum_events_PLAYER_HEALTH_DEPLETED
	#ANCHOR:enum_events_PLAYER_DIED
	PLAYER_DIED,
	#END:enum_events_PLAYER_DIED
}


## The state machine is a node that manages the mob's states and transitions
## between them.[br]
## Because it is a node, it has access to `_physics_process` and `_process`
## functions, which are called by the engine. It makes it slightly easier to use.
#ANCHOR:class_state_machine
class StateMachine extends Node:
	#END:class_state_machine

	## A Dictionary of dictionaries. Maps State → Event → State. [br]
	## Uses [AI.State] keys. Each value is a dictionary with
	## [constant AI.Event] keys and [AI.State] values.
	#ANCHOR:fsm_var_transitions
	var transitions := {}: set = set_transitions
	#END:fsm_var_transitions

	## Holds the current state of the state machine.
	#ANCHOR:fsm_var_current_state
	var current_state: State
	#END:fsm_var_current_state

	## If [code]true[/code], associated mob will display a label with its current
	## state.
	#ANCHOR:fsm_var_is_debugging
	var is_debugging := false: set = set_is_debugging
	#END:fsm_var_is_debugging


	#ANCHOR:fsm_init
	func _init() -> void:
		set_physics_process(false)
		#END:fsm_init
		#ANCHOR:fsm_init_blackboard_player_died
		var blackboard := Blackboard.new()
		Blackboard.player_died.connect(trigger_event.bind(Events.PLAYER_DIED))
		#END:fsm_init_blackboard_player_died


	## The setter doesn't do anything in production, but in debug mode, verifies the
	## dictionary's integrity.
	#ANCHOR:fsm_func_set_transitions
	func set_transitions(new_transitions: Dictionary) -> void:
		transitions = new_transitions
		if OS.is_debug_build():
			for state: State in transitions:
				assert(
					state is State,
					"Invalid state in the transitions dictionary. " +
					"Expected a State object, but got " + str(state)
				)
				for event: Events in transitions[state]:
					assert(
						event is Events,
						"Invalid event in the transitions dictionary. " +
						"Expected an Events object, but got " + str(event)
					)
					assert(
						transitions[state][event] is State,
						"Invalid state in the transitions dictionary. " +
						"Expected a State object, but got " +
						str(transitions[state][event])
					)
	#END:fsm_func_set_transitions


	## Sets the initial state
	#ANCHOR:fsm_func_activate
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
	#END:fsm_func_activate


	#ANCHOR:fsm_func_set_is_debugging
	func set_is_debugging(new_value: bool) -> void:
		is_debugging = new_value
		if (
			current_state != null and
			current_state.mob != null and
			current_state.mob.debug_label != null
		):
			current_state.mob.debug_label.text = current_state.name
			current_state.mob.debug_label.visible = is_debugging
	#END:fsm_func_set_is_debugging


	## Automates creating a transition that is applied to every recorded
	## state.[br]
	#ANCHOR:fsm_func_add_transition_to_all_states
	func add_transition_to_all_states(event: Events, end_state: State) -> void:
		for state: State in transitions:
			transitions[state][event] = end_state
	#END:fsm_func_add_transition_to_all_states


	## If the passed [constant AI.Events] is valid, the associated transition
	## will be triggered, and the state machine will transition to a new [AI.State]
	#ANCHOR:fsm_func_trigger_event
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
		var next_state =  transitions[current_state][event]
		_transition(next_state)
	#END:fsm_func_trigger_event


	#ANCHOR:fsm_physics_process
	func _physics_process(delta: float) -> void:
		var event := current_state.update(delta)
		if event == Events.NONE:
			return
		trigger_event(event)
	#END:fsm_physics_process


	#ANCHOR:fsm_transition_to_next_state_definition
	func _transition(new_state: State) -> void:
	#END:fsm_transition_to_next_state_definition
	#ANCHOR:fsm_transition_to_next_state_setup
		current_state.exit()
		current_state.finished.disconnect(_on_state_finished)
		current_state = new_state
	#ANCHOR:fsm_transition_to_next_state_finished
		current_state.finished.connect(_on_state_finished.bind(current_state))
	#END:fsm_transition_to_next_state_finished
		current_state.enter()
	#END:fsm_transition_to_next_state_setup

	#ANCHOR:fsm_transition_to_next_state_debug
		if is_debugging and current_state.mob.debug_label != null:
			current_state.mob.debug_label.text = current_state.name
	#END:fsm_transition_to_next_state_debug


	#ANCHOR:fsm_on_state_finished
	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"Add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])
	#END:fsm_on_state_finished


## Extensible data structure that gives AIs access to game world data.
## Uses static variables for data that needs to be shared across all mobs like access to the player.
## Thanks to static variables, you can fill relevant parts of the Blackboard from other parts of the game.
## This way, the mob gets the data it needs without direct connections with other game systems.
#ANCHOR:class_blackboard_definition
class Blackboard extends RefCounted:
	#END:class_blackboard_definition
	#ANCHOR:class_blackboard_signal_player_died
	signal _player_died

	static var player_died: Signal
	#END:class_blackboard_signal_player_died

	#ANCHOR:class_blackboard_init
	func _init() -> void:
		player_died = _player_died
	#END:class_blackboard_init

	#ANCHOR:class_blackboard_player_position
	static var player_global_position := Vector3.ZERO
	#END:class_blackboard_player_position
	#ANCHOR:class_blackboard_is_player_dead
	static var is_player_dead := false: set = set_is_player_dead

	func set_is_player_dead(new_value: bool) -> void:
		is_player_dead = new_value
		if is_player_dead:
			player_died.emit()
	#END:class_blackboard_is_player_dead


## Base class to extend for mob states.
##
## Each state should have a reference to the mob it controls. The base class doesn't
## do much by itself, it is intended to be extended in subclasses.
#ANCHOR:class_State
#ANCHOR:class_state
class State extends RefCounted:
	#END:class_state

	## Emitted when the state completes and the state machine should transition to the next state.
	## Use this for time-based states or moves that have a fixed duration.
	#ANCHOR:state_finished
	signal finished
	#END:state_finished

	#ANCHOR:state_properties
	## Display name of the state, for debugging purposes.
	var name := "State"
	## Reference to the mob that the state controls.
	var mob: Mob3D = null
	#END:state_properties


	#ANCHOR:state_init
	func _init(init_name: String, init_mob: Mob3D) -> void:
		name = init_name
		mob = init_mob
	#END:state_init


	## Called by the state machine on the engine's physics update tick.
	## Returns an event that the state machine can use to transition to the next state.
	## If there is no event, return [constant AI.Events.None]
	#ANCHOR:state_update
	func update(_delta: float) -> Events:
		return Events.NONE
	#END:state_update


	## Called by the state machine upon changing the active state. The `data` parameter
	## is a dictionary with arbitrary data the state can use to initialize itself.
	#ANCHOR:state_enter
	func enter() -> void:
		pass
	#END:state_enter


	## Called by the state machine before changing the active state. Use this function
	## to clean up the state.
	#ANCHOR:state_exit
	func exit() -> void:
		pass
	#END:state_exit
#END:class_State


#ANCHOR:class_StateIdle
#ANCHOR:class_StateIdle_definition
class StateIdle extends State:
	#END:class_StateIdle_definition

	#ANCHOR:class_StateIdle_init
	func _init(init_mob: Mob3D) -> void:
		super("Idle", init_mob)
	#END:class_StateIdle_init


	#ANCHOR:class_StateIdle_enter
	func enter() -> void:
		mob.skin.play("idle")
	#END:class_StateIdle_enter


	#ANCHOR:class_StateIdle_update_definition
	func update(_delta: float) -> Events:
	#END:class_StateIdle_update_definition
	#ANCHOR:class_StateIdle_update_dead
		if Blackboard.is_player_dead:
			return Events.NONE
	#END:class_StateIdle_update_dead

	#ANCHOR:class_StateIdle_update_distance
		var distance := mob.global_position.distance_to(Blackboard.player_global_position)
		if distance > mob.vision_range:
			return Events.NONE
	#END:class_StateIdle_update_distance

	#ANCHOR:class_StateIdle_update_vision_cone
		var cos_max_angle_of_vision := cos(mob.vision_angle)
		var direction := mob.global_position.direction_to(Blackboard.player_global_position)
		var dot := mob.global_basis.z.dot(direction)

		var player_in_vision_cone := dot > cos_max_angle_of_vision
		if player_in_vision_cone:
			return Events.PLAYER_ENTERED_LINE_OF_SIGHT
	#END:class_StateIdle_update_vision_cone
	#ANCHOR:class_StateIdle_update_return_default
		return Events.NONE
	#END:class_StateIdle_update_return_default
#END:class_StateIdle


## This state makes the mob look at the player for a certain amount of time before transitioning
## to the next state.
#ANCHOR:class_StateLookAtPlayer
#ANCHOR:class_StateLookAtPlayer_definition
class StateLookAtPlayer extends State:
	#END:class_StateLookAtPlayer_definition

	#ANCHOR:class_StateLookAtPlayer_properties
	var duration := 2.0
	var _time := 0.0
	#END:class_StateLookAtPlayer_properties


	#ANCHOR:class_StateLookAtPlayer_init
	func _init(init_mob: Mob3D) -> void:
		super("Look at Player", init_mob)
	#END:class_StateLookAtPlayer_init


	#ANCHOR:class_StateLookAtPlayer_enter
	func enter() -> void:
		_time = 0.0
	#END:class_StateLookAtPlayer_enter


	#ANCHOR:class_StateLookAtPlayer_update_definition
	func update(delta: float) -> Events:
	#END:class_StateLookAtPlayer_update_definition
	#ANCHOR:class_StateLookAtPlayer_time
		_time += delta
		if _time >= duration:
			return Events.FINISHED
		#END:class_StateLookAtPlayer_time

		#ANCHOR:class_StateLookAtPlayer_distance
		var player_distance := mob.global_position.distance_to(
			Blackboard.player_global_position
		)
		if player_distance > mob.vision_range:
			return Events.PLAYER_EXITED_LINE_OF_SIGHT
		#END:class_StateLookAtPlayer_distance

		#ANCHOR:class_StateLookAtPlayer_look_at_player
		var direction := mob.global_position.direction_to(
			Blackboard.player_global_position
		)
		var target_rotation_y := Vector3.FORWARD.signed_angle_to(
			direction, Vector3.UP
		) + PI
		mob.rotation.y = lerp_angle(
			mob.rotation.y, target_rotation_y, 2.0 * delta
		)
		#END:class_StateLookAtPlayer_look_at_player
		#ANCHOR:class_StateLookAtPlayer_return_default
		return Events.NONE
		#END:class_StateLookAtPlayer_return_default
	#END:class_StateLookAtPlayer


## This state makes the mob wait for a certain amount of time before transitioning to the next state.
# TODO: challenge: implement color change
#ANCHOR:class_StateWait
class StateWait extends State:

	var duration := 0.5
	var _time := 0.0


	func _init(init_mob: Mob3D) -> void:
		super("Wait", init_mob)


	func enter() -> void:
		mob.skin.play("idle")
		_time = 0.0


	func update(delta: float) -> Events:
		_time += delta
		if _time >= duration:
			return Events.FINISHED
		return Events.NONE
#END:class_StateWait


#ANCHOR:class_StateFireProjectile
#ANCHOR:class_StateFireProjectile_definition
class StateFireProjectile extends State:
	#END:class_StateFireProjectile_definition

	#ANCHOR:class_StateFireProjectile_properties_init
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
	#END:class_StateFireProjectile_properties_init


	#ANCHOR:class_StateFireProjectile_enter
	func enter() -> void:
		var projectile: Projectile3D = projectile_scene.instantiate()
		mob.add_sibling(projectile)

		projectile.global_position = spawning_point.global_position
		projectile.look_at(spawning_point.global_position + spawning_point.global_basis.z)

		finished.emit()
	#END:class_StateFireProjectile_enter
#END:class_StateFireProjectile


## Seek is the mob looking for the player.
## It moves towards the player's position slowly and looks left and right until a certain amount of time passes or it finds the player.
class StateSeek extends State:

	var seek_speed := 3.0
	var drag_factor := 10.0
	var attack_range := 2.0


	func _init(init_mob: Mob3D) -> void:
		super("Seek", init_mob)


	func update(delta: float) -> Events:
		var player_position := Blackboard.player_global_position
		var desired_velocity: Vector3 = mob.global_position.direction_to(player_position) * seek_speed
		var velocity_distance := mob.velocity.distance_to(desired_velocity)
		# Vector3.move_toward() prevents the velocity from overshooting the desired velocity.
		mob.velocity = mob.velocity.move_toward(desired_velocity, velocity_distance * drag_factor * delta)

		var distance := mob.global_position.distance_to(player_position)
		if distance < attack_range:
			return Events.PLAYER_ENTERED_LINE_OF_SIGHT
		return Events.NONE


#ANCHOR:class_StateChase
#ANCHOR:class_StateChase_definition
class StateChase extends State:
	#END:class_StateChase_definition

	#ANCHOR:class_StateChase_properties
	var chase_speed := 3.0
	var drag_factor := 10.0
	var attack_range := 3.5
	#END:class_StateChase_properties


	#ANCHOR:class_StateChase_init
	func _init(init_mob: Mob3D) -> void:
		super("Chase", init_mob)
	#END:class_StateChase_init


	#ANCHOR:class_StateChase_enter
	func enter() -> void:
		mob.skin.play("chase")
	#END:class_StateChase_enter


	#ANCHOR:class_StateChase_update_definition
	func update(delta: float) -> Events:
	#END:class_StateChase_update_definition
	#ANCHOR:class_StateChase_steering
		var player_position := Blackboard.player_global_position
		var direction := mob.global_position.direction_to(player_position)
		var desired_velocity := (
			direction * chase_speed
		)
		var velocity_distance := mob.velocity.distance_to(desired_velocity)
		mob.velocity = mob.velocity.move_toward(
			desired_velocity,
			velocity_distance * drag_factor * delta
		)
		mob.move_and_slide()
	#END:class_StateChase_steering

	#ANCHOR:class_StateChase_rotation
		mob.rotation.y = (
			Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
		)
	#END:class_StateChase_rotation

	#ANCHOR:class_StateChase_distance
		var distance := mob.global_position.distance_to(player_position)
		if distance < attack_range:
			return Events.PLAYER_ENTERED_ATTACK_RANGE
		elif distance > mob.vision_range:
			return Events.PLAYER_EXITED_LINE_OF_SIGHT
	#END:class_StateChase_distance
	#ANCHOR:class_StateChase_return_default
		return Events.NONE
	#END:class_StateChase_return_default
#END:class_StateChase


#ANCHOR:class_StateCharge
#ANCHOR:class_StateCharge_definition
class StateCharge extends State:
	#END:class_StateCharge_definition

	#ANCHOR:class_StateCharge_properties
	var charge_speed := 10.0
	var charge_distance := 7.0

	var _traveled_distance := 0.0
	#END:class_StateCharge_properties

	#ANCHOR:class_StateCharge_init
	func _init(init_mob: Mob3D) -> void:
		super("Charge", init_mob)
	#END:class_StateCharge_init


	#ANCHOR:class_StateCharge_enter
	func enter() -> void:
		_traveled_distance = 0.0
		mob.skin.play("charge")
	#END:class_StateCharge_enter


	#ANCHOR:class_StateCharge_update_definition
	func update(delta: float) -> Events:
		#END:class_StateCharge_update_definition
		#ANCHOR:class_StateCharge_movement
		mob.velocity = mob.global_basis.z * charge_speed
		mob.move_and_slide()
		#END:class_StateCharge_movement

		#ANCHOR:class_StateCharge_collision
		if mob.get_slide_collision_count() > 0:
			return Events.FINISHED
		#END:class_StateCharge_collision

		#ANCHOR:class_StateCharge_distance
		_traveled_distance += charge_speed * delta
		if _traveled_distance >= charge_distance:
			return Events.FINISHED
		#END:class_StateCharge_distance
		#ANCHOR:class_StateCharge_return_default
		return Events.NONE
		#END:class_StateCharge_return_default


	#ANCHOR:class_StateCharge_exit
	func exit() -> void:
		mob.velocity = Vector3.ZERO
	#END:class_StateCharge_exit
#END:class_StateCharge


class StateAttack extends State:

	func _init(init_mob: Mob3D) -> void:
		super("Attack", init_mob)


	func enter() -> void:
		mob.skin.play("attack")
		mob.skin.animation_finished.connect(func (anim_name: String):
			if anim_name == "attack":
				finished.emit()
		)


class StateStomp extends State:

	const StompAttackScene = preload("res://assets/entities/projectile/stomp_attack/stomp_attack.tscn")


	func _init(init_mob: Mob3D) -> void:
		super("Stomp", init_mob)


	func enter() -> void:
		mob.skin.play("attack")

		var stomp_attack := StompAttackScene.instantiate()
		mob.add_sibling(stomp_attack)
		stomp_attack.global_position = mob.global_position

		mob.get_tree().create_timer(0.7).timeout.connect(func():
			finished.emit()
		)


#ANCHOR:class_StateStagger
class StateStagger extends State:

	func _init(init_mob: Mob3D) -> void:
		super("Stagger", init_mob)


	func enter() -> void:
		mob.skin.play("stagger")
		mob.skin.animation_finished.connect(_on_animation_finished)


	func exit() -> void:
		mob.skin.animation_finished.disconnect(_on_animation_finished)


	func _on_animation_finished(_anim_name: String) -> void:
		finished.emit()
#END:class_StateStagger


#ANCHOR:class_StateDie
class StateDie extends State:

	const SmokeExplosionScene = preload("res://assets/vfx/smoke_vfx/smoke_explosion.tscn")


	func _init(init_mob: Mob3D) -> void:
		super("Die", init_mob)


	func enter() -> void:
		mob.skin.play("die")
		mob.deactivate()

		var smoke_explosion := SmokeExplosionScene.instantiate()
		mob.add_sibling(smoke_explosion)
		smoke_explosion.global_position = mob.global_position

		mob.skin.animation_finished.connect(func (_animation_name: String) -> void:
			mob.queue_free()
		)
#END:class_StateDie
