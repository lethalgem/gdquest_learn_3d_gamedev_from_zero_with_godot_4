extends "res://addons/gdpractice/tester/test.gd"


class TestData:
	var practice_mouse_position_2d: Vector2
	var practice_mouse_ray: Vector3
	var practice_world_mouse_position: Variant
	var practice_gobot_skin_3d_basis_z: Vector3

	var expected_mouse_position_2d: Vector2
	var expected_mouse_ray: Vector3
	var expected_world_mouse_position: Variant
	var expected_gobot_skin_3d_basis_z: Vector3


func _build_requirements() -> void:
	_add_properties_requirement([
		"_camera_3d",
		"_gobot_skin_3d",
		"_world_plane",
		"mouse_position_2d",
		"mouse_ray",
		"world_mouse_position",
	])


func _setup_state() -> void:
	var viewport := get_viewport()
	var starting_mouse_position := viewport.get_mouse_position()

	await get_tree().physics_frame

	var size := viewport.get_visible_rect().size
	for p: Vector2 in [Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)]:
		viewport.warp_mouse(p)

		await get_tree().create_timer(0.1).timeout
	
		var test_data := TestData.new()
		
		test_data.practice_mouse_position_2d = _practice.mouse_position_2d
		test_data.practice_mouse_ray = _practice.mouse_ray
		test_data.practice_world_mouse_position = _practice.world_mouse_position
		test_data.practice_gobot_skin_3d_basis_z = _practice._gobot_skin_3d.global_transform.basis.z

		test_data.expected_mouse_position_2d = _practice.get_viewport().get_mouse_position()
		test_data.expected_mouse_ray = _practice._camera_3d.project_ray_normal(test_data.expected_mouse_position_2d)
		if _practice._world_plane != null:
			test_data.expected_world_mouse_position = _practice._world_plane.intersects_ray(_practice._camera_3d.global_position, test_data.expected_mouse_ray)
		else:
			test_data.expected_world_mouse_position = Vector3.INF
		if _practice.world_mouse_position != null:
			test_data.expected_gobot_skin_3d_basis_z = test_data.expected_world_mouse_position.direction_to(_practice._gobot_skin_3d.global_position)
		else:
			test_data.expected_gobot_skin_3d_basis_z = Vector3.INF

		_test_space.append(test_data)

	viewport.warp_mouse(starting_mouse_position)


func _build_checks() -> void:
	var check_player_click_turns_gobot_skin_3d := Check.new()
	check_player_click_turns_gobot_skin_3d.description = tr("The player's skin looks at the world mouse position when the mouse moves.")

	var check_world_plane := Check.new()
	check_world_plane.description = tr("The _world_plane variable is a Plane object with a normal pointing up.")
	check_world_plane.checker = func() -> String:
		if _practice._world_plane == null:
			return tr("The _world_plane variable has a value of null. Did you forget to assign a new Plane object to it?")
		elif not _practice._world_plane.normal.is_equal_approx(Vector3.UP):
			return tr("The _world_plane variable has a value of %s. For this practice, it should have a value of %s. Did you create a Plane object with a normal pointing up?" % [_practice._world_plane, _solution._world_plane])
		return ""
	

	var check_mouse_position := Check.new()
	check_mouse_position.description = tr("The mouse position variable is the mouse cursor position.")
	check_mouse_position.checker = func() -> String:
		for data: TestData in _test_space:
			if data.practice_mouse_position_2d.distance_to(data.expected_mouse_position_2d) > 0.1:
				return tr("When we tested your code, we found that when we moved the mouse position to %s, your mouse_position_2d property had a value of %s instead. Did you get the mouse cursor position using the get_viewport().get_mouse_position() method? If so, please make sure to run the practice without moving the mouse cursor." % [data.practice_mouse_position_2d, data.expected_mouse_position_2d])
		return ""
	check_mouse_position.dependencies = [check_world_plane]


	var check_camera_ray_orientation := Check.new()
	check_camera_ray_orientation.description = tr("The mouse ray is pointing towards the mouse cursor.")
	check_camera_ray_orientation.checker = func() -> String:
		for data: TestData in _test_space:
			var expected_direction := data.expected_mouse_ray.normalized()
			var practice_direction := data.practice_mouse_ray.normalized()
			var dot_product := expected_direction.dot(practice_direction)
			if dot_product < 0.99 or not is_equal_approx(sign(dot_product), 1.0):
				return tr("The mouse ray is not pointing towards the mouse cursor. Did you project the mouse cursor position using the Camera3D.project_ray_normal() method?")
		return ""
	check_camera_ray_orientation.dependencies = [check_mouse_position]


	var check_player_looks_at_mouse := Check.new()
	check_player_looks_at_mouse.description = tr("The player's skin looks at the world mouse position.")
	check_player_looks_at_mouse.checker = func() -> String:
		for data: TestData in _test_space:
			var expected_forward := data.expected_gobot_skin_3d_basis_z
			var practice_forward := data.practice_gobot_skin_3d_basis_z
			var dot_product := expected_forward.dot(practice_forward)
			if dot_product < 0.99 or not is_equal_approx(sign(dot_product), 1.0):
				return tr("The skin is not looking exactly at the projected mouse cursor position. Did you call the look_at() method on the skin?")
		return ""


	check_player_click_turns_gobot_skin_3d.subchecks += [
		check_world_plane,
		check_mouse_position,
		check_camera_ray_orientation,
		check_player_looks_at_mouse,
	]

	checks += [check_player_click_turns_gobot_skin_3d]
