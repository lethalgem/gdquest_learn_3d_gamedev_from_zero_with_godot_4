# NOTE: This test uses type checking on the practice script,
# res://practices/L6.P1/turret_with_states.gd. So there is a copy of the
# practice script committed and the repository with the type definitions. It
# needs to be kept in sync in case the practice code changes.
extends "res://addons/gdpractice/tester/test.gd"


const PracticeTurret := preload("res://practices/L6.P1/turret_with_states.gd")

var practice_bullet_scene: PackedScene = _load("bullet.tscn", true)


var practice_turret: Node3D = null
var practice_state_machine = null
var solution_turret: Node3D = null

class TestData:
	# If true, it means that the practice turret changed from way to shoot in sync with the solution turret.
	var wait_to_shoot_change_matched_solution := false

	var shoot_state_spawned_bullet := false
	var spawned_bullet_was_turret_sibling := false
	var spawned_bullet_spawn_was_at_shooting_point := false
	var spawned_bullet_aligned_with_shooting_point := false

var data := TestData.new()


func _build_requirements() -> void:
	practice_turret = _practice.find_child("TurretWithStates", false)
	solution_turret = _solution.find_child("TurretWithStates", false)

	for child: Node in practice_turret.get_children():
		if child is PracticeTurret.StateMachine:
			practice_state_machine = child
			break

	_add_properties_requirement([
		"Events",
		"State",
		"StateWait",
		"StateMachine",
	], practice_turret)

	var requirement_state_shoot_bullet := Requirement.new()
	requirement_state_shoot_bullet.description = tr("The turret script has a state named 'StateShootBullet'.")
	requirement_state_shoot_bullet.checker = func() -> String:
		if not "StateShootBullet" in practice_turret:
			return tr("The turret script does not have a state named 'StateShootBullet'. Did you remove or rename the class?")
		return ""

	var requirement := Requirement.new()
	requirement.description = tr("The practice scene has an instance of the turret named 'TurretWithStates'.")
	requirement.checker = func() -> String:
		if practice_turret == null:
			return tr("The practice scene does not have an instance of the turret named 'TurretWithStates'. Did you remove the an instance of the turret from the practice scene?")
		return ""
	
	var requirement_2 := Requirement.new()
	requirement_2.description = tr("The practice scene has an instance of the state machine named 'StateMachine'.")
	requirement_2.checker = func() -> String:
		if practice_state_machine == null:
			return tr("The practice scene does not have an instance of the state machine named 'StateMachine'. Did you remove the an instance of the state machine from the practice scene?")
		return ""

	requirements += [requirement, requirement_2]


func _setup_populate_test_space() -> void:
	practice_state_machine.state_changed.connect(
	func on_practice_state_changed(new_state: PracticeTurret.State) -> void:
		if new_state is PracticeTurret.StateShootBullet:
			get_tree().physics_frame.connect(
			func() -> void:
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
	)
	await get_tree().create_timer(.8).timeout


func _build_checks() -> void:
	var check_wait_state_transitions_to_shoot := Check.new()
	check_wait_state_transitions_to_shoot.description = tr("The wait state transitions to the shoot bullet state.")
	check_wait_state_transitions_to_shoot.checker = func() -> String:
		for state in practice_state_machine.transitions:
			if not state is PracticeTurret.StateWait:
				continue

			var t = practice_state_machine.transitions[state]
			if t.has(PracticeTurret.Events.FINISHED):
				if not t[PracticeTurret.Events.FINISHED] is PracticeTurret.StateShootBullet:
					return tr("The wait state does not transition to the shoot bullet state. Did you set the transition from the wait state?")
				return ""
		return tr("The wait state appears not to be used in the transitions dictionary and not to have transitions. Did you forget to add the wait state to the state machine's transitions dictionary?")
	

	var check_shoot_state_transitions_to_wait := Check.new()
	check_shoot_state_transitions_to_wait.description = tr("The shoot bullet state transitions to the wait state.")
	check_shoot_state_transitions_to_wait.checker = func() -> String:
		for state in practice_state_machine.transitions:
			if not state is PracticeTurret.StateShootBullet:
				continue

			var t = practice_state_machine.transitions[state]
			if t.has(PracticeTurret.Events.FINISHED):
				if not t[PracticeTurret.Events.FINISHED] is PracticeTurret.StateWait:
					return tr("The shoot bullet state does not transition to the wait state. Did you set the transition from the shoot bullet state?")
				return ""
		return tr("The shoot bullet state appears not to be used in the transitions dictionary and not to have transitions. Did you forget to add the shoot bullet state to the state machine's transitions dictionary?")
	

	var check_shoot_state_emits_finished_signal := Check.new()
	check_shoot_state_emits_finished_signal.description = tr("The shoot bullet state emits the 'finished' signal.")
	check_shoot_state_emits_finished_signal.checker = func() -> String:
		# Spawn the bullet far from the view, so it isn't visible on camera 
		var spawn_point := Node3D.new()
		_practice.add_child(spawn_point)
		spawn_point.global_position = Vector3(1000, 1000, 1000)
		var state := PracticeTurret.StateShootBullet.new(practice_turret, spawn_point, practice_bullet_scene)
		# Using a dictionary to force the lambda to preserve the reference and not create
		# a closure around a boolean variable.
		var finished_emitted := {"emitted": false}
		state.finished.connect(func() -> void:
			finished_emitted["emitted"] = true
		)
		state.enter()
		spawn_point.queue_free()
		if finished_emitted["emitted"] == false:
			return tr("The shoot bullet state did not emit the 'finished' signal. Did you forget to emit the 'finished' signal after spawning the bullet?")
		return ""
	

	var check_bullet := Check.new()
	check_bullet.description = tr("The turret shoots a bullet moving forward from the spawning point.")

	var check_shoot_state_spawns_bullet := Check.new()
	check_shoot_state_spawns_bullet.description = tr("The shoot state spawns a bullet.")
	check_shoot_state_spawns_bullet.checker = func() -> String:
		if not data.shoot_state_spawned_bullet:
			return tr("The shoot state did not spawn a bullet. Did you forget to instantiate the bullet scene and add it as a sibling of the turret node?")
		return ""

	var check_shoot_state_spawns_bullet_as_sibling := Check.new()
	check_shoot_state_spawns_bullet_as_sibling.description = tr("The shoot state spawns the bullet as a sibling of the turret node.")
	check_shoot_state_spawns_bullet_as_sibling.checker = func() -> String:
		if not data.spawned_bullet_was_turret_sibling:
			return tr("The bullet was not spawned as a sibling of the turret node. Did you forget to add the bullet as a sibling of the turret node? Did you add it as a child of the turret instead?")
		return ""
	check_shoot_state_spawns_bullet_as_sibling.dependencies = [check_shoot_state_spawns_bullet]


	var check_shoot_state_spawns_bullet_at_shooting_point := Check.new()
	check_shoot_state_spawns_bullet_at_shooting_point.description = tr("The shoot state spawns the bullet at the shooting point.")
	check_shoot_state_spawns_bullet_at_shooting_point.checker = func() -> String:
		if not data.spawned_bullet_spawn_was_at_shooting_point:
			return tr("The bullet was not spawned at the shooting point. Did you forget to set the bullet's global position to the turret's shooting point?")
		return ""
	check_shoot_state_spawns_bullet_at_shooting_point.dependencies = [check_shoot_state_spawns_bullet]

	var chesk_shoot_state_spawns_bullet_aligned_with_shooting_point := Check.new()
	chesk_shoot_state_spawns_bullet_aligned_with_shooting_point.description = tr("The shoot state spawns the bullet aligned with the shooting point.")
	chesk_shoot_state_spawns_bullet_aligned_with_shooting_point.checker = func() -> String:
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
		check_shoot_state_transitions_to_wait,
		check_shoot_state_emits_finished_signal,
		check_bullet,
	]
