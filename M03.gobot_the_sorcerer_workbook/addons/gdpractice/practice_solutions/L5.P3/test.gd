extends "res://addons/gdpractice/tester/test.gd"

var expected_scene := _load("box.tscn", true)


class TestData:
	var created_child: Node3D = null
	var projected_mouse_position: Vector3 = Vector3.ZERO


func _build_requirements() -> void:
	_add_properties_requirement([
		"_camera_3d",
		"_world_plane",
		"mouse_position_2d",
	])


func _setup_state() -> void:
	var viewport := _practice.get_viewport()
	var starting_mouse_position := viewport.get_mouse_position()

	await get_tree().physics_frame

	var size := viewport.get_visible_rect().size
	var current_child_count := _practice.get_child_count()
	var tree := get_tree()
	for position: Vector2 in [size / 2, size / 3, 2 * size / 3]:

		viewport.warp_mouse(position)

		# Simulate clicking the left mouse button. Triggers
		# Input.is_action_just_pressed("left_click")
		#
		# NOTE: I couldn't get parsed input events to work (events sent to
		# _input() etc.), this may be a limitation of subviewports in Godot 4.2.
		await tree.physics_frame
		Input.action_press("left_click")
		await tree.create_timer(0.1).timeout
		Input.action_release("left_click")

		var new_child_count := _practice.get_child_count()
		var test_data := TestData.new()
		if new_child_count != current_child_count:
			test_data.created_child = _practice.get_child(new_child_count - 1)

		var mouse_position: Vector2 = _practice.mouse_position_2d
		var ray: Vector3 = _practice._camera_3d.project_ray_normal(mouse_position)
		test_data.projected_mouse_position = _practice._world_plane.intersects_ray(_practice._camera_3d.global_position, ray)

		_test_space.append(test_data)
		current_child_count = new_child_count

	viewport.warp_mouse(starting_mouse_position)


func _build_checks() -> void:
	var check_box_created_on_click := Check.new()
	check_box_created_on_click.description = tr("The box is instantiated at the mouse position when clicking the left mouse button.")

	var check_box_is_not_null := Check.new()
	check_box_is_not_null.description = tr("There is an added node as a child after a click.")
	check_box_is_not_null.checker = func () -> String:
		for data: TestData in _test_space:
			if data.created_child == null:
				return tr("We found no node added as a child after mouse clicks. Did you forget to add the instantiate the box or add it as a child of the practice node?")
		return ""

	var check_instantiated_node_is_box := Check.new()
	check_instantiated_node_is_box.description = tr("The added instance is an instance of the box.tscn scene.")
	check_instantiated_node_is_box.checker = func () -> String:
		for data: TestData in _test_space:
			if data.created_child.scene_file_path != expected_scene.resource_path:
				print(data.created_child.scene_file_path, expected_scene.resource_path)
				return tr("The added node is not an instance of the box.tscn scene. Did you load and instantiate the box.tscn scene from the practice folder?")
		return ""
	check_instantiated_node_is_box.dependencies += [check_box_is_not_null]

	var check_box_position := Check.new()
	check_box_position.description = tr("The box is instantiated at the mouse position.")
	check_box_position.checker = func () -> String:
		for data: TestData in _test_space:
			if data.created_child.global_position.distance_to(data.projected_mouse_position) > 0.1:
				return tr("The box is not instantiated at the mouse position. Did you set the global position of the instantiated box to the projected mouse position?")
		return ""
	check_box_position.dependencies += [check_box_is_not_null]

	check_box_created_on_click.subchecks = [check_box_is_not_null, check_instantiated_node_is_box, check_box_position]
	checks = [check_box_created_on_click]
