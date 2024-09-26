
class_name MobBee3D extends Mob3D

func _ready():
	var state_machine = AI.StateMachine.new()
	add_child(state_machine)

	var idle = AI.StateIdle.new(self)
	var flee = AI.StateFlee.new(self)

	state_machine.transitions = {
		idle: {
			AI.Events.PLAYER_ENTERED_LINE_OF_SIGHT: flee
		},
		flee: {
			AI.Events.PLAYER_EXITED_LINE_OF_SIGHT: idle
		},
	}

	state_machine.activate(idle)

	state_machine.is_debugging = true
