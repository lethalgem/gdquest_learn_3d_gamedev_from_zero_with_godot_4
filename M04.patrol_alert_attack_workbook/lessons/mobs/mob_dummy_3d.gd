class_name MobDummy3D extends Mob3D

@onready var shooting_point = %ShootingPoint

func _ready() -> void:
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)

	var idle := AI.StateIdle.new(self)
	var look_at_player := AI.StateLookAtPlayer.new(self)
	var wait := AI.StateWait.new(self)

	const Projectile3DScene = preload("res://assets/entities/projectile/mob_fireball.tscn")
	var fire_projectile := AI.StateFireProjectile.new(self, shooting_point, Projectile3DScene)

	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: look_at_player,
		},
		look_at_player: {
			AI.Events.FINISHED: wait,
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
		},
		wait: {
			AI.Events.FINISHED: fire_projectile,
		},
		fire_projectile: {
			AI.Events.FINISHED: look_at_player,
		},
	}

	state_machine.activate(idle)
