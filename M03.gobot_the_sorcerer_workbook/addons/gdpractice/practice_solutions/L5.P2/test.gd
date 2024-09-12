extends "res://addons/gdpractice/tester/test.gd"


class TestData:
	var mouse_pressed := false

	var practice_mouse_position_2d: Vector2
	var practice_mouse_ray: Vector3
	var practice_world_mouse_position: Variant
	var practice_box_position: Vector3

	var expected_mouse_position_2d: Vector2
	var expected_mouse_ray: Vector3
	var expected_world_mouse_position: Variant
	var expected_box_position: Vector3


func _build_requirements() -> void:
	_add_properties_requirement([
		"_camera_3d",
		"_box",
		"_world_plane",
		"mouse_position_2d",
		"mouse_ray",
		"world_mouse_position",
	])


func _setup_state() -> void:
	var viewport := _practice.get_viewport()
	var starting_mouse_position := viewport.get_mouse_position()

	await get_tree().physics_frame

	var size := viewport.get_visible_rect().size

	var left_click_event := InputEventMouseButton.new()
	left_click_event.button_index = MOUSE_BUTTON_LEFT
	left_click_event.pressed = true
	Input.parse_input_event(left_click_event)

	await get_tree().create_timer(0.1).timeout

	for p: Vector2 in [Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)]:
		viewport.warp_mouse(p)

		await get_tree().create_timer(0.1).timeout

		var test_data := _calculate_test_data(true)
		_test_space.append(test_data)

	var left_click_release_event := InputEventMouseButton.new()
	left_click_release_event.button_index = MOUSE_BUTTON_LEFT
	left_click_release_event.pressed = false
	Input.parse_input_event(left_click_release_event)

	await get_tree().create_timer(0.1).timeout

	viewport.warp_mouse(Vector2.ZERO)

	await get_tree().create_timer(0.1).timeout

	var test_data := _calculate_test_data(false)
	_test_space.append(test_data)

	viewport.warp_mouse(starting_mouse_position)


func _calculate_test_data(is_mouse_pressed: bool) -> TestData:
	var test_data := TestData.new()
	test_data.mouse_pressed = is_mouse_pressed

	test_data.practice_mouse_position_2d = _practice.mouse_position_2d
	test_data.practice_mouse_ray = _practice.mouse_ray
	test_data.practice_world_mouse_position = _practice.world_mouse_position
	test_data.practice_box_position = _practice._box.global_position

	test_data.expected_mouse_position_2d = _practice.get_viewport().get_mouse_position()
	test_data.expected_mouse_ray = _practice._camera_3d.project_ray_normal(test_data.expected_mouse_position_2d)
	test_data.expected_world_mouse_position = _practice._world_plane.intersects_ray(_practice._camera_3d.global_position, test_data.expected_mouse_ray)
	test_data.expected_box_position = test_data.expected_world_mouse_position
	return test_data


func _build_checks() -> void:
	var check_mouse_projection_is_ok := Check.new()
	check_mouse_projection_is_ok.description = tr("The player's skin looks at the world mouse position when the mouse moves.")


	var check_mouse_position := Check.new()
	check_mouse_position.description = tr("The mouse position variable is the mouse cursor position.")
	check_mouse_position.checker = func() -> String:
		for data: TestData in _test_space:
			# There are gotchas when capturing mouse positions. When releasing
			# the mouse button we cannot reliably capture the mouse position.
			# So, we skip the check when the mouse was not pressed.
			if not data.mouse_pressed:
				continue

			if data.practice_mouse_position_2d.distance_to(data.expected_mouse_position_2d) > 0.1:
				return tr("When we tested your code, we found that when we moved the mouse position to %s, your mouse_position_2d property had a value of %s instead. Did you get the mouse cursor position using the get_viewport().get_mouse_position() method? If so, please make sure to run the practice without moving the mouse cursor." % [data.practice_mouse_position_2d, data.expected_mouse_position_2d])
		return ""


	var check_camera_ray_orientation := Check.new()
	check_camera_ray_orientation.description = tr("The mouse ray is pointing towards the mouse cursor.")
	check_camera_ray_orientation.checker = func() -> String:
		for data: TestData in _test_space:
			if not data.mouse_pressed:
				continue

			var expected_direction := data.expected_mouse_ray.normalized()
			var practice_direction := data.practice_mouse_ray.normalized()
			var dot_product := expected_direction.dot(practice_direction)
			if dot_product < 0.99 or not is_equal_approx(sign(dot_product), 1.0):
				return tr("The mouse ray is not pointing towards the mouse cursor. Did you project the mouse cursor position using the Camera3D.project_ray_normal() method?")
		return ""
	check_camera_ray_orientation.dependencies = [check_mouse_position]


	var check_box_moves_to_mouse_on_click := Check.new()
	check_box_moves_to_mouse_on_click.description = tr("The box moves to the mouse position when the left mouse button is pressed.")
	check_box_moves_to_mouse_on_click.checker = func() -> String:
		# Checking if the box moves to the mouse position when the left mouse button is pressed.
		for data: TestData in _test_space:
			if data.mouse_pressed and not data.practice_box_position.is_equal_approx(data.expected_box_position):
				return tr("When the left mouse button is pressed, the box should move to the mouse position. Did you set the box's global_position to the world_mouse_position?")

		var previous: TestData = _test_space[0]
		for current: TestData in _test_space.slice(1):
			if current.mouse_pressed:
				previous = current
				continue

			if current.practice_box_position.distance_to(previous.expected_box_position) > 0.1:
				return tr("The box should only move when the left mouse button is pressed. Did you only move the box when the left mouse button is pressed?")
			previous = current
		return ""
	check_box_moves_to_mouse_on_click.dependencies = [check_mouse_projection_is_ok]


	check_mouse_projection_is_ok.subchecks += [
		check_mouse_position,
		check_camera_ray_orientation,
	]

	checks += [check_mouse_projection_is_ok, check_box_moves_to_mouse_on_click]
