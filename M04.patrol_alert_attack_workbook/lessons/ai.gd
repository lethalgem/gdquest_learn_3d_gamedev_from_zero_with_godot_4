class_name AI extends RefCounted

enum Events {
	NONE,
	FINISHED,
	PLAYER_ENTERED_LINE_OF_SIGHT,
	PLAYER_EXITED_LINE_OF_SIGHT,
	PLAYER_ENTERED_ATTACK_RANGE,
	TOOK_DAMAGE,
	HEALTH_DEPLETED,
	PLAYER_DIED,
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
		Blackboard.player_died.connect(trigger_event.bind(Events.PLAYER_DIED))

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

		if is_debugging and current_state.mob.debug_label != null:
			current_state.mob.debug_label.text = current_state.name

	func _on_state_finished(finished_state: State) -> void:
		assert(
			Events.FINISHED in transitions[current_state],
			"Received a state that does not have a transition for the FINISHED event, " + current_state.name + ". " +
			"add a transition for this event in the transitions dictionary."
		)
		_transition(transitions[finished_state][Events.FINISHED])

	var is_debugging := false: set = set_is_debugging

	func set_is_debugging(new_value: bool) -> void:
		is_debugging = new_value
		if (
			current_state != null and
			current_state.mob != null and
			current_state.mob.debug_label != null
		):
			current_state.mob.debug_label.text = current_state.name
			current_state.mob.debug_label.visible = is_debugging
			
	func add_transition_to_all_states(event: Events, end_state: State) -> void:
		for state: State in transitions:
			if state == end_state:
				continue
			transitions[state][event] = end_state
		

class Blackboard extends RefCounted:
	static var player_global_position := Vector3.ZERO
	
	static var player_died: Signal = (func ():
		(Blackboard as RefCounted).add_user_signal("player_died")
		return Signal(Blackboard, "player_died")
	).call()
	
	static var is_player_dead := false

class StateIdle extends State:

	func _init(init_mob: Mob3D) -> void:
		super("Idle", init_mob)

	func enter() -> void:
		mob.skin.play("idle")

	func update(_delta: float) -> Events:
		if Blackboard.is_player_dead:
			return Events.NONE
		
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

class StateChase extends State:

	var chase_speed := 3.0
	var drag_factor := 10.0
	var attack_range := 3.5

	func _init(init_mob: Mob3D) -> void:
		super("Chase", init_mob)

	func enter() -> void:
		mob.skin.play("chase")

	func update(delta: float) -> Events:
		var player_position := Blackboard.player_global_position
		var direction: Vector3 = mob.global_position.direction_to(player_position)
		var desired_velocity := (
			direction * chase_speed
		)
		var velocity_distance: float = mob.velocity.distance_to(desired_velocity)
		mob.velocity = mob.velocity.move_toward(
			desired_velocity,
			velocity_distance * drag_factor * delta
		)
		mob.move_and_slide()

		mob.rotation.y = (
			Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI
		)

		var distance: float = mob.global_position.distance_to(player_position)
		if distance < attack_range:
			return Events.PLAYER_ENTERED_ATTACK_RANGE
		elif distance > mob.vision_range:
			return Events.PLAYER_EXITED_LINE_OF_SIGHT
		return Events.NONE

class StateCharge extends State:
	
	var charge_speed := 10.0
	var charge_distance := 10.0
	
	var _traveled_distance := 0.0

	func _init(init_mob: Mob3D) -> void:
		super("Charge", init_mob)

	func enter() -> void:
		_traveled_distance = 0.0
		mob.skin.play("charge")

	func exit() -> void:
		mob.velocity = Vector3.ZERO
		
	func update(delta: float) -> Events:
		mob.velocity = mob.global_basis.z * charge_speed
		mob.move_and_slide()

		if mob.get_slide_collision_count() > 0:
			return Events.FINISHED

		_traveled_distance += charge_speed * delta
		if _traveled_distance >= charge_distance:
			return Events.FINISHED

		return Events.NONE
		
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

class StateDie extends State:
	
	const SmokeExplosionScene = preload("res://assets/vfx/smoke_vfx/smoke_explosion.tscn")
	
	func _init(init_mob: Mob3D) -> void:
		super("Die", init_mob)
		
	func enter() -> void:
		mob.skin.play("die")
		
		var smoke_explosion := SmokeExplosionScene.instantiate()
		mob.add_sibling(smoke_explosion)
		smoke_explosion.global_position = mob.global_position
		
		mob.skin.animation_finished.connect(func (_animation_name: String) -> void:
			mob.queue_free()
		)

class StateStomp extends State:
	var duration := 0.5
	var number_of_stomps := 1
	var delay_between_stomps := 0.5
	var times_stomped := 0
	
	const ShockwaveScene = preload("res://assets/entities/projectile/stomp_attack/stomp_attack.tscn")
	
	func _init(init_mob: Mob3D) -> void:
		super("Stomp", init_mob)
	
	func enter() -> void:
		stomp()
	
	func exit() -> void:
		times_stomped = 0
		
	func stomp() -> void:
		mob.skin.play("attack")
		
		var shockwave := ShockwaveScene.instantiate()
		mob.add_sibling(shockwave)
		shockwave.global_position = mob.global_position
		
		times_stomped += 1
		
		mob.get_tree().create_timer(duration).timeout.connect(func ():
			if times_stomped == number_of_stomps:
				finished.emit()
			else:
				# stomp again
				mob.get_tree().create_timer(delay_between_stomps).timeout.connect(func ():
					stomp()
				)
		)

class StateStompWalk extends State:
	var duration := 2.0
	var walk_speed := 3.0
	var drag_factor := 10.0
	
	var elapsed_time := 0.0
	
	const ShockwaveScene = preload("res://assets/entities/projectile/stomp_attack/stomp_attack.tscn")
	
	func _init(init_mob: Mob3D) -> void:
		super("StompWalk", init_mob)
	
	func enter() -> void:
		mob.skin.play("chase")
		mob.skin.foot_step.connect(stomp)
	
	func exit() -> void:
		elapsed_time = 0.0
		mob.skin.foot_step.disconnect(stomp)

	func update(delta: float) -> Events:
		var direction: Vector3 = mob.global_transform.basis.z
		var desired_velocity := (
			direction * walk_speed
		)
		var velocity_distance: float = mob.velocity.distance_to(desired_velocity)
		mob.velocity = mob.velocity.move_toward(
			desired_velocity,
			velocity_distance * drag_factor * delta
		)
		mob.move_and_slide()

		elapsed_time += delta
		if elapsed_time >= duration:
			return Events.FINISHED
		return Events.NONE
		
		
	func stomp() -> void:
		var shockwave := ShockwaveScene.instantiate()
		mob.add_sibling(shockwave)
		shockwave.global_position = mob.global_position
