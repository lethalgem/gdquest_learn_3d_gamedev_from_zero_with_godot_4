extends "res://addons/gdpractice/tester/test.gd"

const SolutionTurret = preload("res://addons/gdpractice/practice_solutions/L3.P1/turret.gd")

var practice_turret: Node3D = null
var solution_turret: Node3D = null

class TestData:
	# If true, it means that the practice turret changed from way to shoot in sync with the solution turret.
	var wait_to_shoot_change_matched_solution := false
	# Same as above, but for the shoot to wait change.
	var shoot_to_wait_change_matched_solution := false

	var wait_transitions_to_shoot := false
	var shoot_state_transitions_to_wait := false

	var shoot_state_spawned_bullet := false
	var spawned_bullet_was_turret_sibling := false
	var spawned_bullet_spawn_was_at_shooting_point := false
	var spawned_bullet_aligned_with_shooting_point := false

var data := TestData.new()


func _build_requirements() -> void:
	practice_turret = _practice.find_child("Turret", false)
	solution_turret = _solution.find_child("Turret", false)

	_add_properties_requirement([
		"States",
		"bullet_scene",
		"current_state",
		"bullet_spawning_point",
	], practice_turret)

	var requirement := Requirement.new()
	requirement.description = tr("The practice scene has an instance of the turret named 'Turret'.")
	requirement.checker = func () -> String:
		if practice_turret == null:
			return tr("The practice scene does not have an instance of the turret named 'Turret'. Did you remove the an instance of the turret from the practice scene?")
		return ""

	var requirement_enum := Requirement.new()
	requirement_enum.description = tr("The States enum has a state named WAIT and another named SHOOT.")
	requirement_enum.checker = func () -> String:
		if not "WAIT" in practice_turret.States:
			return tr("The States enum does not have a state named WAIT. Did you remove it from the States enum?")
		if not "SHOOT" in practice_turret.States:
			return tr("The States enum does not have a state named SHOOT. Did you forget to add a state named SHOOT to the States enum? Or does it have a typo?")
		return ""
	requirements += [requirement, requirement_enum]


var solution_last_state = -1
var practice_last_state = -1

# To know if the wait state in the practice lasts 0.7 seconds, we check against the solution.
var practice_wait_to_shoot_transition_time_msec := 0.0
var solution_wait_to_shoot_transition_time_msec := 0.0
var practice_shoot_to_wait_transition_time_msec := 0.0
var solution_shoot_to_wait_transition_time_msec := 0.0


func _setup_populate_test_space() -> void:
	practice_turret.state_changed.connect(func on_practice_state_changed(new_state) -> void:
		self.practice_last_state = practice_turret.current_state

		if (practice_turret.current_state == practice_turret.States.WAIT and
			new_state == practice_turret.States.SHOOT):
			practice_wait_to_shoot_transition_time_msec = Time.get_ticks_msec()

			data.wait_transitions_to_shoot = true

			get_tree().physics_frame.connect(func () -> void:
				# Find the last bullet instance in the tree (because there can be multiple bullets at once)
				# NOTE: a limitation of this approach is that it only works for a single turret.
				# If there are multiple turrets firing simultaneously, this will not work.
				var found_bullet: Node3D = null
				for child: Node in _practice.get_children():
					if child.scene_file_path.get_file() == "bullet.tscn":
						found_bullet = child

				if found_bullet == null:
					for child: Node in practice_turret.get_children():
						if child.scene_file_path.get_file() == "bullet.tscn":
							found_bullet = child

				if found_bullet != null:
					data.shoot_state_spawned_bullet = true
					data.spawned_bullet_was_turret_sibling = found_bullet.get_parent() == practice_turret.get_parent()
					data.spawned_bullet_spawn_was_at_shooting_point = (
						found_bullet.global_position.distance_to(practice_turret.bullet_spawning_point.global_position) < 0.1
					)
					var dot_product: float = found_bullet.global_basis.z.dot(practice_turret.bullet_spawning_point.global_basis.z)
					# look_at(), which we teach students to use, makes -Z point toward the target position by default, so the bullet will face in the opposite direction
					# compared to the turret.
					data.spawned_bullet_aligned_with_shooting_point = (
						dot_product < -0.99
					),
				CONNECT_ONE_SHOT
			)
		elif (practice_turret.current_state == practice_turret.States.SHOOT and
			new_state == practice_turret.States.WAIT):
			practice_shoot_to_wait_transition_time_msec = Time.get_ticks_msec()
			data.shoot_state_transitions_to_wait = true
	)

	solution_turret.state_changed.connect(func on_solution_state_changed(new_state) -> void:
		self.solution_last_state = practice_turret.current_state

		if (solution_turret.current_state == SolutionTurret.States.WAIT and
			new_state == SolutionTurret.States.SHOOT):
			solution_wait_to_shoot_transition_time_msec = Time.get_ticks_msec()
			data.wait_to_shoot_change_matched_solution = (
				practice_last_state == practice_turret.States.WAIT and
				practice_turret.current_state == practice_turret.States.SHOOT
			)
		elif (solution_turret.current_state == SolutionTurret.States.SHOOT and
			new_state == SolutionTurret.States.WAIT):
			solution_shoot_to_wait_transition_time_msec = Time.get_ticks_msec()
			get_tree().physics_frame.connect(func () -> void:
				data.shoot_to_wait_change_matched_solution = (
					practice_last_state == practice_turret.States.SHOOT and
					practice_turret.current_state == practice_turret.States.WAIT
				), CONNECT_ONE_SHOT)
	)

	await get_tree().create_timer(1.0).timeout
	data.shoot_to_wait_change_matched_solution = abs(
		practice_shoot_to_wait_transition_time_msec - solution_shoot_to_wait_transition_time_msec
	) < 50.0
	data.wait_to_shoot_change_matched_solution = abs(
		practice_wait_to_shoot_transition_time_msec - solution_wait_to_shoot_transition_time_msec
	) < 50.0


func _build_checks() -> void:
	var check_wait_state_transitions_to_shoot := Check.new()
	check_wait_state_transitions_to_shoot.description = tr("The WAIT state transitions to the SHOOT state.")
	check_wait_state_transitions_to_shoot.checker = func () -> String:
		if not data.wait_transitions_to_shoot:
			return tr("The WAIT state did not transition to the SHOOT state. Did you forget to call set_change_state() with States.SHOOT as an argument?")
		return ""

	var check_wait_state_lasts_0_7_seconds := Check.new()
	check_wait_state_lasts_0_7_seconds.description = tr("The WAIT state lasts 0.7 seconds.")
	check_wait_state_lasts_0_7_seconds.checker = func () -> String:
		if not data.wait_to_shoot_change_matched_solution:
			return tr("The WAIT state did not last the same duration as the solution which suggests it did not last 0.7 seconds. Did you set the duration of the WAIT state to 0.7 seconds?")
		return ""
	check_wait_state_lasts_0_7_seconds.dependencies = [check_wait_state_transitions_to_shoot]

	var check_shoot_state_transitions_to_wait := Check.new()
	check_shoot_state_transitions_to_wait.description = tr("The SHOOT state transitions to the WAIT state.")
	check_shoot_state_transitions_to_wait.checker = func () -> String:
		if not data.shoot_state_transitions_to_wait:
			return tr("The SHOOT state did not transition to the WAIT state. Did you forget to call set_change_state() with States.WAIT as an argument?")
		return ""

	var check_bullet := Check.new()
	check_bullet.description = tr("The turret shoots a bullet moving forward from the spawning point.")

	var check_shoot_state_spawns_bullet := Check.new()
	check_shoot_state_spawns_bullet.description = tr("The SHOOT state spawns a bullet.")
	check_shoot_state_spawns_bullet.checker = func () -> String:
		if not data.shoot_state_spawned_bullet:
			return tr("The SHOOT state did not spawn a bullet. Did you forget to instantiate the bullet scene and add it as a sibling of the turret node?")
		return ""

	var check_shoot_state_spawns_bullet_as_sibling := Check.new()
	check_shoot_state_spawns_bullet_as_sibling.description = tr("The SHOOT state spawns the bullet as a sibling of the turret node.")
	check_shoot_state_spawns_bullet_as_sibling.checker = func () -> String:
		if not data.spawned_bullet_was_turret_sibling:
			return tr("The bullet was not spawned as a sibling of the turret node. Did you forget to add the bullet as a sibling of the turret node? Did you add it as a child of the turret instead?")
		return ""
	check_shoot_state_spawns_bullet_as_sibling.dependencies = [check_shoot_state_spawns_bullet]


	var check_shoot_state_spawns_bullet_at_shooting_point := Check.new()
	check_shoot_state_spawns_bullet_at_shooting_point.description = tr("The SHOOT state spawns the bullet at the shooting point.")
	check_shoot_state_spawns_bullet_at_shooting_point.checker = func () -> String:
		if not data.spawned_bullet_spawn_was_at_shooting_point:
			return tr("The bullet was not spawned at the shooting point. Did you forget to set the bullet's global position to the turret's shooting point?")
		return ""
	check_shoot_state_spawns_bullet_at_shooting_point.dependencies = [check_shoot_state_spawns_bullet]

	var chesk_shoot_state_spawns_bullet_aligned_with_shooting_point := Check.new()
	chesk_shoot_state_spawns_bullet_aligned_with_shooting_point.description = tr("The SHOOT state spawns the bullet aligned with the shooting point.")
	chesk_shoot_state_spawns_bullet_aligned_with_shooting_point.checker = func () -> String:
		if not data.spawned_bullet_aligned_with_shooting_point:
			return tr("The bullet was not spawned aligned with the shooting point. Did you forget to set the bullet's Z basis to match the shooting point's basis?")
		return ""

	check_bullet.subchecks = [
		check_shoot_state_spawns_bullet,
		check_shoot_state_spawns_bullet_as_sibling,
		check_shoot_state_spawns_bullet_at_shooting_point,
		chesk_shoot_state_spawns_bullet_aligned_with_shooting_point,
	]

	checks = [
		check_wait_state_transitions_to_shoot,
		check_wait_state_lasts_0_7_seconds,
		check_shoot_state_transitions_to_wait,
		check_bullet,
	]
