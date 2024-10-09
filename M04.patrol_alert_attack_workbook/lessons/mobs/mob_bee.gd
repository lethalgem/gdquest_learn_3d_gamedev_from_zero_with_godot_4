
class_name MobBee3D extends Mob3D

func _ready():
	var state_machine = AI.StateMachine.new()
	add_child(state_machine)

	var idle = AI.StateIdle.new(self)
	
	var look_at_player = AI.StateLookAtPlayer.new(self)
	
	var chase = AI.StateChase.new(self)
	chase.chase_speed = 3.0
	
	var charge = AI.StateCharge.new(self)
	
	var wait = AI.StateWait.new(self)
	
	var stagger := AI.StateStagger.new(self)
	
	var die := AI.StateDie.new(self)

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
		},
		stagger: {
			AI.Events.FINISHED: idle,
		}
	}
	
	state_machine.add_transition_to_all_states(AI.Events.TOOK_DAMAGE, stagger)
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)

	state_machine.activate(idle)

	state_machine.is_debugging = true

	hurt_box.took_hit.connect(func (hit_box: HitBox3D) -> void:
		health -= hit_box.damage
		if health <= 0:
			state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
		else:
			state_machine.trigger_event(AI.Events.TOOK_DAMAGE)
	)
