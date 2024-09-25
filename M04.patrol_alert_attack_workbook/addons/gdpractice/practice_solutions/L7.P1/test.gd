# NOTE: This test uses type checking on the practice script,
# res://practices/L7.P1/mob_follow.gd. So there is a copy of the
# practice script committed and the repository with the type definitions. It
# needs to be kept in sync in case the practice code changes.
extends "res://addons/gdpractice/tester/test.gd"

const PracticeMob := preload("res://practices/L7.P1/mob_follow.gd")
const SolutionMob := preload("res://addons/gdpractice/practice_solutions/L7.P1/mob_follow.gd")

enum States {
	IDLE,
	FOLLOW,
}

class FrameData:
	var practice_velocity: Vector3
	var solution_velocity: Vector3
	var practice_state: States
	var solution_state: States


var frame_data: Array[FrameData] = []


var practice_mob: Node3D = null
var practice_state_machine = null
var solution_mob: Node3D = null
var solution_state_machine = null

func _build_requirements() -> void:
	practice_mob = _practice.find_child("MobFollow", false)
	solution_mob = _solution.find_child("MobFollow", false)

	for child: Node in practice_mob.get_children():
		if child is PracticeMob.StateMachine:
			practice_state_machine = child
			break
	for child: Node in solution_mob.get_children():
		if child is SolutionMob.StateMachine:
			solution_state_machine = child
			break

	_add_properties_requirement([
		"Events",
		"State",
		"StateIdle",
		"StateFollow",
		"StateMachine",
	], practice_mob)

	var requirement_state_machine := Requirement.new()
	requirement_state_machine.description = tr("The practice scene has an instance of the state machine named 'StateMachine'.")
	requirement_state_machine.checker = func() -> String:
		if practice_state_machine == null:
			return tr("The practice scene does not have an instance of the state machine named 'StateMachine'. Did you remove the an instance of the state machine from the practice scene?")
		return ""

	requirements += [requirement_state_machine]


func _setup_populate_test_space() -> void:
	await _connect_timed(0.5, get_tree().physics_frame, func() -> void:
		var frame := FrameData.new()
		frame.practice_velocity = practice_mob.velocity
		frame.solution_velocity = solution_mob.velocity

		if practice_state_machine.current_state is PracticeMob.StateIdle:
			frame.practice_state = States.IDLE
		elif practice_state_machine.current_state is PracticeMob.StateFollow:
			frame.practice_state = States.FOLLOW

		if solution_state_machine.current_state is SolutionMob.StateIdle:
			frame.solution_state = States.IDLE
		elif solution_state_machine.current_state is SolutionMob.StateFollow:
			frame.solution_state = States.FOLLOW

		frame_data.append(frame)
	)


# Test that:
# - Mob enters follow state when ball is in range
# - Mob exits follow state when ball is out of range
# - Mob Follows ball at same velocity as reference in follow state
func _build_checks() -> void:
	var check_idle_transitions_to_follow := Check.new()
	check_idle_transitions_to_follow.description = tr("The Idle state transitions to the Follow state when the ball enters the line of sight.")
	check_idle_transitions_to_follow.checker = func() -> String:
		for state in practice_state_machine.transitions:
			if not state is PracticeMob.StateIdle:
				continue

			var transition = practice_state_machine.transitions[state]
			if transition.has(PracticeMob.Events.PLAYER_ENTERED_LINE_OF_SIGHT):
				var target_state = transition[PracticeMob.Events.PLAYER_ENTERED_LINE_OF_SIGHT]
				if not target_state is PracticeMob.StateFollow:
					return tr("The %s state does not transition to the %s state. Did you set the transition from the %s state?" % [state.name, target_state.name, state.name])
				return ""
			return tr("The %s state appears not to be used in the transitions dictionary and not to have transitions. Did you forget to add the %s state to the state machine's transitions dictionary?" % [state.name, state.name])
		return tr("The StateIdle state is not found in the transitions dictionary. Did you forget to add it?")

	var check_follow_transitions_to_idle := Check.new()
	check_follow_transitions_to_idle.description = tr("The Follow state transitions to the Idle state when the ball exits the line of sight.")
	check_follow_transitions_to_idle.checker = func() -> String:
		for state in practice_state_machine.transitions:
			if not state is PracticeMob.StateFollow:
				continue

			var transition = practice_state_machine.transitions[state]
			if transition.has(PracticeMob.Events.PLAYER_EXITED_LINE_OF_SIGHT):
				var target_state = transition[PracticeMob.Events.PLAYER_EXITED_LINE_OF_SIGHT]
				if not target_state is PracticeMob.StateIdle:
					return tr("The %s state does not transition to the %s state. Did you set the transition from the %s state?" % [state.name, target_state.name, state.name])
				return ""
			return tr("The %s state appears not to be used in the transitions dictionary and not to have transitions. Did you forget to add the %s state to the state machine's transitions dictionary?" % [state.name, state.name])
		return tr("The StateFollow state is not found in the transitions dictionary. Did you forget to add it?")

	var check_follow_state_properties := Check.new()
	check_follow_state_properties.description = tr("The Follow state has the follow speed set to 2 and the drag factor set to 10.")
	check_follow_state_properties.checker = func() -> String:
		for state in practice_state_machine.transitions:
			if not state is PracticeMob.StateFollow:
				continue

			if state.follow_speed != 2.0:
				return tr("The follow speed of the Follow state is not set to 2. Did you set the follow speed of the Follow state?")

			if state.drag_factor != 10.0:
				return tr("The drag factor of the Follow state is not set to 10. Did you set the drag factor of the Follow state?")

			return ""
		return tr("I couldn't find the StateFollow state in the states dictionary. Did you forget to add it?")

	var check_state_transitions_match_solution := Check.new()
	check_state_transitions_match_solution.description = tr("The mob transitions to the follow state when the ball enters the line of sight and transitions to the idle state when the ball exits the line of sight.")
	check_state_transitions_match_solution.checker = func() -> String:
		var previous_frame: FrameData = frame_data.front()
		for index: int in range(1, frame_data.size()):
			var frame: FrameData = frame_data[index]
			if (
				frame.practice_state == States.IDLE and
				frame.solution_state == States.FOLLOW and
				previous_frame.solution_state == States.IDLE
			):
				return tr("The mob does not transition to the follow state when the ball enters the line of sight. Did you set the transition from the idle state to the follow state?")
			elif (
				frame.practice_state == States.FOLLOW and
				frame.solution_state == States.IDLE and
				previous_frame.solution_state == States.FOLLOW
			):
				return tr("The mob does not transition to the idle state when the ball exits the line of sight. Did you set the transition from the follow state to the idle state? And did you return the PLAYER_EXITED_LINE_OF_SIGHT event in the follow state?")
			elif (frame.practice_state != frame.solution_state):
				return tr("The mob does not transition to the correct state. Did you set the transitions correctly?")
			previous_frame = frame
		return ""


	var check_follows_ball_velocity := Check.new()
	check_follows_ball_velocity.description = tr("The mob follows the ball at the same velocity as the reference mob.")
	check_follows_ball_velocity.checker = func() -> String:
		for index in range(frame_data.size()):
			var frame: FrameData = frame_data[index]

			# The solution velocity can be offset by one frame, so we need to check the previous and next frames as well.
			var has_no_match := true
			for offset in [-1, 0, 1]:
				var reference_index: int = index + offset
				if reference_index < 0 or reference_index >= frame_data.size():
					continue
				var reference_frame: FrameData = frame_data[reference_index]
				if reference_frame.solution_velocity.distance_to(frame.practice_velocity) < 0.05:
					has_no_match = false
					break

			if has_no_match:
				return tr("The mob does not follow the ball at the same velocity as the reference mob. Are you using the follow steering equation?")
		return ""

	var check_state_name_is_correct := Check.new()
	var expected_state_name := "Follow"
	check_state_name_is_correct.description = tr("The state machine is named '%s'.")%[expected_state_name]
	check_state_name_is_correct.checker = func() -> String:
		var found := false
		for state in practice_state_machine.transitions:
			if not state is PracticeMob.StateFollow:
				continue
			found = true
			if not state.name == expected_state_name:
				return tr("The state machine is named '%s' instead of '%s'. Did you name the state machine correctly?")%[state.name, expected_state_name]
		if not found:
			return tr("The StateFollow state was not found in the transitions dictionary. Did you forget to add it?")
		return ""

	checks = [
		check_idle_transitions_to_follow,
		check_follow_transitions_to_idle,
		check_follow_state_properties,
		check_state_transitions_match_solution,
		check_follows_ball_velocity,
		check_state_name_is_correct
	]
