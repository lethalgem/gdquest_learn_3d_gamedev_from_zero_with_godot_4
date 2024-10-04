extends Mob3D


func _ready() -> void:
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)


	var idle := AI.StateIdle.new(self)
	var chase := AI.StateChase.new(self)
	chase.chase_speed = 3.0
	var look_at_player := AI.StateLookAtPlayer.new(self)
	look_at_player.duration = 2.0

	var charge_and_shoot := StateChargeAndShoot.new(self)
	charge_and_shoot.charge_speed = 14.0
	charge_and_shoot.projectile_count = 5
	charge_and_shoot.arc_angle = 2.0 * PI

	var wait_after_charge := AI.StateWait.new(self)
	wait_after_charge.duration = 1.5

	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase,
		},
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
			AI.Events.PLAYER_ENTERED_ATTACK_RANGE: look_at_player,
		},
		look_at_player: {
			AI.Events.FINISHED: charge_and_shoot,
		},
		charge_and_shoot: {
			AI.Events.FINISHED: wait_after_charge,
		},
		wait_after_charge: {
			AI.Events.FINISHED: chase,
		},
	}

	state_machine.activate(idle)
	state_machine.is_debugging = true


class StateChargeAndShoot extends AI.State:

	var projectile_count := 5
	var arc_angle := PI
	var projectile_scene := preload("res://assets/entities/projectile/mob_fireball.tscn")

	var charge_speed := 10.0
	var charge_distance := 7.0

	var _traveled_distance := 0.0

	func _init(init_mob: Mob3D) -> void:
		super("Charge and Shoot", init_mob)


	func enter() -> void:
		_traveled_distance = 0.0
		mob.skin.play("charge")

		var angle_interval := arc_angle / projectile_count
		var half_arc := arc_angle / 2.0
		for i in range(projectile_count):
			var projectile := projectile_scene.instantiate()
			mob.add_sibling(projectile)
			projectile.global_position = mob.global_position
			projectile.global_basis = mob.global_basis
			projectile.rotate_y(half_arc - i * angle_interval)


	func update(delta: float) -> Events:
		mob.velocity = mob.global_basis.z * charge_speed
		mob.move_and_slide()

		if mob.get_slide_collision_count() > 0:
			return Events.FINISHED

		_traveled_distance += charge_speed * delta
		if _traveled_distance >= charge_distance:
			return Events.FINISHED
		return Events.NONE


	func exit() -> void:
		mob.velocity = Vector3.ZERO
