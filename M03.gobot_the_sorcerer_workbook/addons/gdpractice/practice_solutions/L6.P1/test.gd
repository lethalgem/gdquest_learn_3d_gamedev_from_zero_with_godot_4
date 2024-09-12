extends "res://addons/gdpractice/tester/test.gd"

signal populate_test_space_finished


# Data points that are checked and stored for each frame of the practice.
class FrameData:
	var bullet_transform := Transform3D()
	var traveled_distance := 0.0


# Data points that are checked only once for the whole practice.
class FixedData:
	var travelled_distance_on_exit := 0.0
	var scale_at_start := Vector3.ONE
	var scale_at_end := Vector3.ONE
	var initial_basis_z := Vector3.ZERO
	var bullet_does_get_deleted := false
	var bullet_visual_variable_is_set := false
	var bullet_has_visual_instance := false
	var bullet_visual_instance_is_skin := false

	var bullet_speed := 0.0
	var bullet_max_range := 0.0
	var bullet_skin_scene: PackedScene = null

var fixed_data := FixedData.new()


func _build_requirements() -> void:
	var bullet := _practice.get_node_or_null("Bullet")

	var bullet_node_requirement := Requirement.new()
	bullet_node_requirement.description = tr("The practice has a child instance of the bullet scene.")
	bullet_node_requirement.checker = func () -> String:
		if bullet == null:
			return tr("The practice does not have a child instance of the bullet scene. Did you remove the bullet scene instance from the practice?")
		return ""
	
	_add_properties_requirement([
		"speed", "max_range", "traveled_distance", "bullet_skin_scene", "visual"
	], bullet)



func _setup_state() -> void:
	var practice_bullet = _practice.get_node("Bullet")
	var solution_bullet = _solution.get_node("Bullet")
	solution_bullet.speed = practice_bullet.speed
	solution_bullet.max_range = practice_bullet.max_range

	fixed_data.bullet_speed = practice_bullet.speed
	fixed_data.bullet_max_range = practice_bullet.max_range
	fixed_data.bullet_skin_scene = practice_bullet.bullet_skin_scene

	if practice_bullet.visual != null:
		fixed_data.scale_at_start = practice_bullet.visual.scale
		fixed_data.bullet_visual_variable_is_set = true
		var path = NodePath(practice_bullet.visual.name)
		if practice_bullet.has_node(path):
			fixed_data.bullet_has_visual_instance = true
			var visual_node = practice_bullet.get_node(path)
			fixed_data.bullet_visual_instance_is_skin = visual_node.scene_file_path.ends_with("bullet_skin.tscn")

	fixed_data.initial_basis_z = practice_bullet.basis.z


	

func _setup_populate_test_space() -> void:
	var practice_bullet: Node3D = _practice.get_node("Bullet")

	var duration: float = practice_bullet.max_range / practice_bullet.speed
	await _connect_timed(duration, get_tree().physics_frame, func collect_frame_data():
		var frame_data := FrameData.new()
		frame_data.bullet_transform = practice_bullet.transform
		frame_data.traveled_distance = practice_bullet.traveled_distance
		_test_space.append(frame_data)
	)

	if practice_bullet.visual != null:
		practice_bullet.visual.tree_exiting.connect(func ():
			fixed_data.bullet_does_get_deleted = true
			fixed_data.travelled_distance_on_exit = practice_bullet.traveled_distance
			if practice_bullet.visual != null:
				fixed_data.scale_at_end = practice_bullet.visual.scale
			populate_test_space_finished.emit()
		)
		# If the visuals don't disappear the signal may never be emitted so we back it up with a timeout.
		get_tree().create_timer(1.5).timeout.connect(func ():
			populate_test_space_finished.emit()
		)
		await populate_test_space_finished


func _build_checks() -> void:

	var check_skin_configurable := Check.new()
	check_skin_configurable.description = tr("The bullet_skin_scene property controls the skin")
	check_skin_configurable.checker = func () -> String:
		if fixed_data.bullet_skin_scene == null:
			return tr("The bullet does not have a scene assigned to the bullet_skin_scene property. Did you assign the bullet skin scene to the Bullet Skin property in the Inspector?")
		if not fixed_data.bullet_visual_instance_is_skin:
			return tr("The visual of the bullet does not appear to be an instance of the scene bullet_skin.tscn. Did you assign the scene bullet_skin.tscn to the bullet_skin property and instantiate it in the _ready() function?")
		return ""

	var check_skin_instantiated := Check.new()
	check_skin_instantiated.description = tr("The bullet has a skin instantiated and added as a child.")
	check_skin_instantiated.checker = func () -> String:
		if not fixed_data.bullet_visual_variable_is_set:
			return tr("The bullet does not the visual variable set. Did you assign an instance of the bullet skin to the visual property?")
		if not fixed_data.bullet_has_visual_instance:
			return tr("The bullet skin is not added as a child of the bullet. Did you add the bullet skin instance as a child of the bullet in the _ready() function")
		return ""

	var check_skin_appears := Check.new()
	check_skin_appears.description = tr("The bullet's skin plays its appear animation when the bullet is created.")
	check_skin_appears.checker = func () -> String:
		if fixed_data.scale_at_start == Vector3.ONE:
			return tr("The bullet's skin does not seem to play its appear animation when the bullet is created. Did you call the bullet skin's appear() method?")
		return ""

	var check_skin_disappears := Check.new()
	check_skin_disappears.description = tr("The bullet's skin plays its disappear animation when the bullet reached maximum range.")
	check_skin_disappears.checker = func () -> String:
		if fixed_data.scale_at_end == Vector3.ONE:
			return tr("The bullet's skin does not seem to play its disappear animation when the bullet is destroyed. Did you call the bullet skin's destroy() method? When calling it, be sure to turn off physics processing with set_process(false) to prevent the bullet from moving after it's destroyed.")
		return ""

	var check_bullet_moves_forward := Check.new()
	check_bullet_moves_forward.description = tr("The bullet moves forward in the direction it's facing (the local negative Z-axis).")
	check_bullet_moves_forward.checker = func () -> String:
		var is_bullet_moving_forward := func (frame_previous: FrameData, frame_current: FrameData) -> bool:
			var direction := frame_previous.bullet_transform.origin.direction_to(frame_current.bullet_transform.origin)
			var dot := direction.dot(-fixed_data.initial_basis_z)
			return dot > 0.99 and sign(direction) == sign(-fixed_data.initial_basis_z)

		if not _is_sliding_window_pass(is_bullet_moving_forward):
			return tr("The bullet does not move forward in the direction it's initially facing. Did you move the bullet in the direction of its basis.z?")
		return ""

	var check_bullet_dies := Check.new()
	check_bullet_dies.description = tr("The bullet gets destroyed upon reaching its maximum range.")
	check_bullet_dies.checker = func () -> String:
		if not fixed_data.bullet_does_get_deleted:
			return tr("The bullet does not get destroyed upon reaching its maximum range. Did you delete the bullet when it reaches its maximum range?")
		if fixed_data.travelled_distance_on_exit < fixed_data.bullet_max_range:
			return tr("The bullet gets destroyed before reaching its maximum range. Did you delete the bullet when it gets past its maximum range?")
		return ""

	checks = [check_skin_configurable, check_skin_instantiated, check_skin_appears, check_bullet_moves_forward, check_skin_disappears, check_bullet_dies]

