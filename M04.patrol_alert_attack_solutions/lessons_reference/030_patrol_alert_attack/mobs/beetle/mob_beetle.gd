class_name MobBeetle3D extends Mob3D


func _ready() -> void:
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)

	hurt_box.took_hit.connect(func (hit_box: HitBox3D) -> void:
		health -= hit_box.damage
		if health <= 0:
			state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
		else:
			state_machine.trigger_event(AI.Events.TOOK_DAMAGE)
	)

	var idle := AI.StateIdle.new(self)
	var seek := AI.StateSeek.new(self)
	var chase := AI.StateChase.new(self)
	chase.chase_speed = 3.0
	var wait_charge := AI.StateWait.new(self)
	wait_charge.duration = 1.0
	var stomp := AI.StateStomp.new(self)
	var wait_after_charge := AI.StateWait.new(self)
	wait_after_charge.duration = 1.5

	var stagger := AI.StateStagger.new(self)
	var die := AI.StateDie.new(self)

	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: chase,
			AI.Events.TOOK_DAMAGE: seek,
		},
		seek: {
			AI.Events.FINISHED: chase,
		},
		chase: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
			AI.Events.PLAYER_ENTERED_ATTACK_RANGE: wait_charge,
		},
		wait_charge: {
			AI.Events.FINISHED: stomp,
		},
		stomp: {
			AI.Events.FINISHED: wait_after_charge,
		},
		wait_after_charge: {
			AI.Events.FINISHED: chase,
		},
		stagger: {
			AI.Events.FINISHED: idle,
		},
	}

	state_machine.add_transition_to_all_states(AI.Events.TOOK_DAMAGE, stagger)
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)
	state_machine.add_transition_to_all_states(AI.Events.PLAYER_DIED, idle)

	state_machine.activate(idle)
	state_machine.is_debugging = true
