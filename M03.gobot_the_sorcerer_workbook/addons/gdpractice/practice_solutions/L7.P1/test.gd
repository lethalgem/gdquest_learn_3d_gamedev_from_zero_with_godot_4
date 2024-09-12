extends "res://addons/gdpractice/tester/test.gd"

# Data points that are collected when a bullet is shot.
class ShootData:
	var shoot_action_is_pressed := false

	# The properties below refer to the state of the bullet that was shot
	# relative to the machine gun's properties.
	var bullet_range_matches := false
	var bullet_speed_matches := false
	var bullet_orientation_matches := false
	var bullet_position_matches := false

	var bullet_parent_is_practice_parent := false


# Data points that are checked only once for the whole practice.
class FixedData:
	var expected_bullets := 0

	var has_fire_rate_property := false
	var shot_bullet_count := 0
	

var fixed_data := FixedData.new()

# Reference to the practice's machine gun node
var machine_gun_node: Node3D = null

func _build_requirements() -> void:
	machine_gun_node = _practice.get_node_or_null("MachineGun")

	var machine_gun_node_requirement := Requirement.new()
	machine_gun_node_requirement.description = tr("The practice has a child instance of the machine gun scene.")
	machine_gun_node_requirement.checker = func () -> String:
		if machine_gun_node == null:
			return tr("The practice does not have a child instance of the machine gun scene. Did you remove or rename the machine gun scene instance from the practice?")
		return ""

	_add_properties_requirement([
		"bullet_scene", "max_range", "max_bullet_speed", "timer"
	], machine_gun_node)
	_add_actions_requirement(["shoot"])


func _setup_state() -> void:
	fixed_data.has_fire_rate_property = "fire_rate" in machine_gun_node
	if fixed_data.has_fire_rate_property:
		machine_gun_node.fire_rate = 5.0
	_solution.get_node("MachineGun").fire_rate = 5.0
	

func _setup_populate_test_space() -> void:
	_practice.get_parent().child_entered_tree.connect(func (node: Node) -> void:
		if not node.scene_file_path.ends_with("bullet.tscn"):
			return

		var shoot_data := ShootData.new()
		shoot_data.shoot_action_is_pressed = Input.is_action_pressed("shoot")

		# Note: the child enters the tree before initialization, so we need to wait to collect data.
		await get_tree().process_frame
		shoot_data.bullet_range_matches = is_equal_approx(node.max_range, machine_gun_node.max_range)
		shoot_data.bullet_speed_matches = is_equal_approx(node.speed, machine_gun_node.max_bullet_speed)
		shoot_data.bullet_orientation_matches = node.global_rotation.is_equal_approx(machine_gun_node.global_rotation)
		shoot_data.bullet_position_matches = node.global_position.is_equal_approx(machine_gun_node.global_position)
		shoot_data.bullet_parent_is_practice_parent = node.get_parent() == _practice.get_parent()

		_test_space.append(shoot_data)
	)
	_solution.get_parent().child_entered_tree.connect(func (node: Node):
		fixed_data.expected_bullets += 1
	)

	if not ('bullet_scene' in machine_gun_node) \
	or (machine_gun_node.bullet_scene == null):
		return
	var bullet_instance := (machine_gun_node.bullet_scene as PackedScene).instantiate()
	if not ('bullet_skin_scene' in bullet_instance) \
	or bullet_instance.bullet_skin_scene == null:
		return
	# Simulate shoot input
	await get_tree().create_timer(0.2).timeout
	Input.action_press("shoot")
	await get_tree().create_timer(0.7).timeout
	Input.action_release("shoot")
	await get_tree().create_timer(0.3).timeout


func _build_checks() -> void:
	var check_fire_rate_property := Check.new()
	check_fire_rate_property.description = tr("The machine gun has a property named fire_rate that controls the fire rate.")
	check_fire_rate_property.checker = func () -> String:
		if fixed_data.has_fire_rate_property == false:
			return tr("The machine gun has no fire_rate property. Did you forget to declare it?")
		return ""
	
	
	var check_fire_rate_property_type := Check.new()
	check_fire_rate_property_type.description = tr("The machine gun's fire_rate property is a float.")
	check_fire_rate_property_type.checker = func () -> String:
		if not machine_gun_node.fire_rate is float:
			return tr("The machine gun's fire_rate property is not a decimal number. It needs to be a float.")
		return ""

	var check_fire_rate_is_not_zero := Check.new()
	check_fire_rate_is_not_zero.description = tr("The machine gun's fire_rate property is not negative or zero.")
	check_fire_rate_is_not_zero.checker = func () -> String:
		if machine_gun_node.fire_rate == 0.0:
			return tr("The machine gun's fire_rate property is zero. It needs to be a positive number.")
		if machine_gun_node.fire_rate <= 0.0:
			return tr("The machine gun's fire_rate property is negative. It needs to be a positive number.")
		return ""
	check_fire_rate_is_not_zero.dependencies = [check_fire_rate_property_type]
	
	var check_bullet_scene_set := Check.new()
	check_bullet_scene_set.description = tr("The bullet scene should be set from the editor.")
	check_bullet_scene_set.checker = func () -> String:
		if machine_gun_node.bullet_scene == null:
			return tr("bullet_skin_scene is null, did you forget to load a bullet scene?")
		return ""

	var check_bullet_scene_is_correct_type := Check.new()
	check_bullet_scene_is_correct_type.description = tr("The machine gun's bullet scene has to be the an instance of PackerScene.")
	check_bullet_scene_is_correct_type.checker = func () -> String:
		if not (machine_gun_node.bullet_scene is PackedScene):
			return tr("bullet_skin_scene is not a PackedScene, did you assign the correct type?")
		var instance := (machine_gun_node.bullet_scene as PackedScene).instantiate()
		var script_name := (instance.get_script() as GDScript).resource_path
		return ""

	var check_bullet_scene_has_skin := Check.new()
	check_bullet_scene_has_skin.description = tr("The bullet scene has a skin scene set.")
	check_bullet_scene_has_skin.checker = func () -> String:
		if machine_gun_node.bullet_scene == null:
			return tr("there is no bullet scene")
		var instance = (machine_gun_node.bullet_scene as PackedScene).instantiate()
		if not ('bullet_skin_scene' in instance):
			return tr("It seems you've set a scene for the bullet_scene property, but it's not the correct scene. Did you use bullet.tscn?")
		if instance.bullet_skin_scene == null:
			return tr("It seems the bullet scene does not have a skin scene set. Did you open the scene and assign a skin?")
		return ""

	var check_fire_rate_affects_timer := Check.new()
	check_fire_rate_affects_timer.description = tr("The machine gun's fire_rate property affects the timer's wait_time.")
	check_fire_rate_affects_timer.checker = func () -> String:
		var start_fire_rate: float = machine_gun_node.fire_rate
		var start_wait_time: float = machine_gun_node.timer.wait_time
		for value: float in [0.5, 0.6, 0.7]:
			machine_gun_node.fire_rate = value
			if abs(machine_gun_node.timer.wait_time - 1.0 / value) > 0.01:
				return tr("The machine gun's fire_rate property does not affect the timer's wait_time. Make sure the timer's wait_time is set to 1 divided by the fire_rate.")

		machine_gun_node.fire_rate = start_fire_rate
		return ""
	check_fire_rate_affects_timer.dependencies = [check_fire_rate_is_not_zero]

	check_fire_rate_property.subchecks = [
		check_fire_rate_property_type,
		check_fire_rate_is_not_zero,
		check_fire_rate_affects_timer
	]

	var check_bullets_were_shot := Check.new()
	check_bullets_were_shot.description = tr("The machine gun shoots bullets.")
	check_bullets_were_shot.checker = func () -> String:
		if _test_space.size() == 0:
			return tr("The machine gun did not appear to shoot any bullets. Did you forget to add the bullets as children of the machine gun?")
		return ""

	var check_bullets_have_correct_properties := Check.new()
	check_bullets_have_correct_properties.description = tr("The max range and speed of the bullets match the machine gun's properties.")
	check_bullets_have_correct_properties.checker = func () -> String:
		if _test_space.size() == 0:
			return tr("The bullet's max_range property does not match the machine gun's max_range property.")
		for data: ShootData in _test_space:
			if not data.bullet_range_matches:
				return tr("The bullet's max_range property does not match the machine gun's max_range property.")
			if not data.bullet_speed_matches:
				return tr("The bullet's max_bullet_speed property does not match the machine gun's max_bullet_speed property.")
		return ""
	check_bullets_have_correct_properties.dependencies = [check_bullets_were_shot]

	var check_bullet_position_and_orientation := Check.new()
	check_bullet_position_and_orientation.description = tr("The bullets' spawn position and orientation match the machine gun's position and orientation.")
	check_bullet_position_and_orientation.checker = func () -> String:
		if _test_space.size() == 0:
			return tr("The bullet's orientation does not match the machine gun's orientation. Did you apply the machine gun's global rotation or global transform to the bullet?")
		for data: ShootData in _test_space:
			if not data.bullet_orientation_matches:
				return tr("The bullet's orientation does not match the machine gun's orientation. Did you apply the machine gun's global rotation or global transform to the bullet?")
			if not data.bullet_position_matches:
				return tr("The bullet's position does not match the machine gun's position. Did you apply the machine gun's global position or global transform to the bullet?")
		return ""
	
	var check_correct_bullet_count_was_shot := Check.new()
	check_correct_bullet_count_was_shot.description = tr("The machine gun shot the correct number of bullets based on the fire rate.")
	check_correct_bullet_count_was_shot.checker = func () -> String:
		if _test_space.size() != fixed_data.expected_bullets:
			return tr("The machine gun did not shoot the correct number of bullets. Make sure that you do check if the timer is stopped in physics process when checking for input and that you do start the timer in the shoot() function.")
		return ""
	check_correct_bullet_count_was_shot.dependencies = [check_fire_rate_property]

	checks += [
		check_fire_rate_property, 
		check_bullet_scene_set, 
		check_bullet_scene_is_correct_type, 
		check_bullet_scene_has_skin,
		check_bullets_were_shot, 
		check_bullets_have_correct_properties, 
		check_bullet_position_and_orientation, 
		check_correct_bullet_count_was_shot
	]
