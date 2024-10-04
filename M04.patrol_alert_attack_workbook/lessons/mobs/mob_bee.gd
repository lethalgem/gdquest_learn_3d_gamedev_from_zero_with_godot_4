
class_name MobBee3D extends Mob3D

func _ready():
	var state_machine = AI.StateMachine.new()
	add_child(state_machine)

	var idle = AI.StateIdle.new(self)
	
	var look_at_player = AI.StateLookAtPlayer.new(self)
	
	var chase = AI.StateChase.new(self)
	chase.chase_speed = 3.0
	
	const Projectile3DScene = preload("res://assets/entities/projectile/mob_fireball.tscn")
	var charge = AI.StateCharge.new(self, %ShootingPoint, Projectile3DScene)
	
	var wait = AI.StateWait.new(self)

	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase
		},
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
			AI.Events.PLAYER_ENTERED_ATTACK_RANGE: look_at_player,
		},
		look_at_player: {
			AI.Events.FINISHED: charge,
		},
		charge: {
			AI.Events.FINISHED: wait,
		},
		wait: {
			AI.Events.FINISHED: chase,
		}
	}

	state_machine.activate(idle)

	state_machine.is_debugging = true
