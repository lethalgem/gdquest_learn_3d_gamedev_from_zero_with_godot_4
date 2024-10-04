#ANCHOR:extends
class_name MobDummy3D extends Mob3D
#END:extends

#ANCHOR:var_shooting_point
@onready var shooting_point = %ShootingPoint
#END:var_shooting_point


#ANCHOR:func_ready_definition
func _ready() -> void:
#END:func_ready_definition
#ANCHOR:add_state_machine
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)
#END:add_state_machine

	state_machine.is_debugging = true

	hurt_box.took_hit.connect(func (hit_box: HitBox3D) -> void:
		health -= hit_box.damage
		if health <= 0:
			state_machine.trigger_event(AI.Events.HEALTH_DEPLETED)
		else:
			state_machine.trigger_event(AI.Events.TOOK_DAMAGE)
	)


#ANCHOR:states_idle_look_at_player
	var idle := AI.StateIdle.new(self)
	var look_at_player := AI.StateLookAtPlayer.new(self)
#END:states_idle_look_at_player
#ANCHOR:states_shoot_bullet
	var wait := AI.StateWait.new(self)

	const Projectile3DScene = preload("res://assets/entities/projectile/mob_fireball.tscn")
	var fire_projectile := AI.StateFireProjectile.new(
		self, shooting_point, Projectile3DScene
	)
#END:states_shoot_bullet

	var stagger := AI.StateStagger.new(self)
	var die := AI.StateDie.new(self)

#ANCHOR:transitions
	state_machine.transitions = {
#END:transitions
#ANCHOR:transitions_idle_look_at_player
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: look_at_player,
		},
		look_at_player: {
#END:transitions_idle_look_at_player
#ANCHOR:transitions_wait_shoot
			AI.Events.FINISHED: wait,
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle,
		},
		wait: {
			AI.Events.FINISHED: fire_projectile,
		},
		fire_projectile: {
			AI.Events.FINISHED: look_at_player,
		},
#END:transitions_wait_shoot
		stagger: {
			AI.Events.FINISHED: idle,
		},
	}

	state_machine.add_transition_to_all_states(AI.Events.TOOK_DAMAGE, stagger)
	state_machine.add_transition_to_all_states(AI.Events.HEALTH_DEPLETED, die)
	#ANCHOR:transition_player_died
	state_machine.add_transition_to_all_states(AI.Events.PLAYER_DIED, idle)
	#END:transition_player_died

#ANCHOR:activate_idle
	state_machine.activate(idle)
#END:activate_idle
	state_machine.is_debugging = true
