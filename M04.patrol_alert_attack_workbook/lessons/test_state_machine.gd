extends Mob3D

class TestState extends AI.State:
	func _init(init_mob: Mob3D) -> void:
		name = "Test state"
		mob = init_mob

	func update(_delta: float) -> Events:
		print("Test state update")
		return AI.Events.NONE

	func enter() -> void:
		print("Test state enter")

	func exit() -> void:
		print("Test state exit")

func _ready() -> void:
	var state_machine := AI.StateMachine.new()
	add_child(state_machine)

	var test_state := TestState.new(self)
	state_machine.current_state = test_state
	state_machine.activate()

	for i in 5:
		await get_tree().physics_frame

	state_machine.queue_free()
