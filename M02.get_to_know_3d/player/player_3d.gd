@tool
class_name Player3D extends CharacterBody3D

## The camera controller scene to use for camera control. The Player3D
## instantiates this scene and sets it up.
@export var camera_controller_scene: PackedScene = null: set = set_camera_controller_scene
## The character skin scene to use for the player. The Player3D instantiates
## this scene and adds it as a child of the skin's pivot.
@export var skin_scene: PackedScene = null: set = set_skin_scene

@export_group("Movement")
## Character maximum run speed on the ground in meters per second.
@export var move_speed := 8.0
## Ground movement acceleration in meters per second squared.
@export var acceleration := 20.0
## When the player is on the ground and presses the jump button, the vertical
## velocity is set to this value.
@export var jump_impulse := 12.0
## Player model rotation speed in arbitrary units. Controls how fast the
## character skin orients to the movement or camera direction.
@export var rotation_speed := 12.0
## Minimum horizontal speed on the ground. This controls when the character skin's
## animation tree changes between the idle and running states.
@export var stopping_speed := 1.0

@export_group("Camera")
## Distance to place the camera in third person view compared to the player.
@export var camera_distance := 8.0

@export_group("Shooting")
## Speed of shot bullets in meters per second.
@export var bullet_speed := 10.0
## Time interval during which the player cannot shoot again after shooting.
@export var shoot_cooldown := 0.5: set = set_shoot_cooldown
## Maximum distance a bullet can travel before disappearing.
@export var bullet_range := 14.0

## Each frame, we find the height of the ground below the player and store it here.
## The camera uses this to keep a fixed height while the player jumps, for example.
var ground_height := 0.0

var _gravity := -30.0
var _was_on_floor_last_frame := false

var _camera_controller: CameraController3D = null: set = _set_camera_controller
var _skin: CharacterSkin = null: set = _set_skin

## The last movement or aim direction input by the player. We use this to orient
## the character model.
@onready var _last_input_direction := global_transform.basis.z
# We store the initial position of the player to reset to it when the player falls off the map.
@onready var _start_position := global_position

@onready var _skin_pivot: Node3D = %SkinPivot
@onready var _ground_shapecast: ShapeCast3D = %GroundShapeCast
@onready var _shoot_timer: Timer = %ShootTimer
@onready var _user_interface: CanvasLayer = $UserInterface
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var _dust_particles: GPUParticles3D = %DustParticles


func _ready() -> void:
	if camera_controller_scene != null:
		_camera_controller = camera_controller_scene.instantiate()
	if skin_scene != null:
		_skin = skin_scene.instantiate()

	# In the editor, we don't want to process physics or input or run any movement logic.
	if Engine.is_editor_hint():
		set_physics_process(false)
		return

	_shoot_timer.wait_time = shoot_cooldown

	Events.kill_plane_touched.connect(func on_kill_plane_touched() -> void:
		global_position = _start_position
		velocity = Vector3.ZERO
		_skin.is_moving = false
		set_physics_process(true)
	)
	Events.flag_reached.connect(func on_flag_reached() -> void:
		set_physics_process(false)
		_user_interface.visible = false
		_skin.is_moving = false
		_skin.play_victory_animation()
	)
	set_physics_process(_camera_controller != null and _skin != null)


func _physics_process(delta: float) -> void:
	# Detect the ground below the player and store its height. The camera uses this
	# to avoid clipping through the ground or moving up and down while the player jumps.
	if _ground_shapecast.get_collision_count() > 0:
		for collision_result in _ground_shapecast.collision_result:
			ground_height = max(ground_height, collision_result.point.y)
	else:
		ground_height = global_position.y + _ground_shapecast.target_position.y
	if global_position.y < ground_height:
		ground_height = global_position.y

	# Calculate movement input and align it to the camera's direction.
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.4)
	var forward := _camera_controller.camera.global_transform.basis.z
	var right := _camera_controller.camera.global_transform.basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x

	# To not orient the character too abruptly, we filter movement inputs we
	# consider when turning the skin. This also ensures we have a normalized
	# direction for the rotation basis.
	var is_aiming := Input.is_action_pressed("aim") and is_on_floor()
	_skin.is_aiming = is_aiming
	if is_aiming:
		_last_input_direction = (_camera_controller.global_transform.basis * Vector3.BACK).normalized()
	elif move_direction.length() > 0.2:
		_last_input_direction = move_direction.normalized()

	# Gradually orient the character skin to the last stored input direction.
	# This assumes the skin pivot is not scaled. Otherwise, we would need to
	# extract quaternions and scale information.
	var left_axis := Vector3.UP.cross(_last_input_direction)
	var new_orientation := Basis(left_axis, Vector3.UP, _last_input_direction)
	new_orientation = new_orientation.rotated(Vector3.UP, -rotation.y).orthonormalized()
	var new_skin_basis := _skin_pivot.transform.basis.slerp(new_orientation, rotation_speed * delta).orthonormalized()
	_skin_pivot.transform.basis = new_skin_basis

	# We separate out the y velocity to only interpolate the velocity in the
	# ground plane, and not affect the gravity.
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity + _gravity * delta

	_user_interface.visible = is_aiming
	if is_aiming:
		_camera_controller.set_pivot(_camera_controller.CameraPivot.OVER_SHOULDER)
	else:
		_camera_controller.set_pivot(_camera_controller.CameraPivot.THIRD_PERSON)

	if is_aiming and is_on_floor():
		if Input.is_action_pressed("attack") and _shoot_timer.is_stopped():
			shoot()

	# Character animations and visual effects.
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_just_jumping:
		velocity.y += jump_impulse
		_skin.jump()
		_jump_sound.play()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		_skin.set_moving(ground_speed > 0.0)

	_dust_particles.emitting = is_on_floor() && ground_speed > 0.0

	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()

	var position_before_moving := global_position
	_was_on_floor_last_frame = is_on_floor()
	move_and_slide()
	var position_after_moving := global_position

	# If the velocity is not 0 but the difference of positions after move_and_slide is 0,
	# the character might be stuck somewhere!
	# In this case, we move the character a bit along the wall normal to help it get unstuck.
	var delta_position := position_after_moving - position_before_moving
	if is_zero_approx(delta_position.length_squared()) and not is_zero_approx(velocity.length_squared()):
		global_position += get_wall_normal() * 0.1


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []
	if camera_controller_scene == null:
		warnings.append("The player needs a camera controller scene to function. Please assign one.")
	if skin_scene == null:
		warnings.append("The player needs a character skin scene to function. Please assign one.")
	return warnings


func set_shoot_cooldown(new_cooldown: float) -> void:
	shoot_cooldown = new_cooldown
	if _shoot_timer != null:
		_shoot_timer.wait_time = shoot_cooldown


func set_camera_controller_scene(new_scene: PackedScene) -> void:
	camera_controller_scene = new_scene
	if camera_controller_scene != null and is_inside_tree():
		_camera_controller = camera_controller_scene.instantiate()


func set_skin_scene(new_scene: PackedScene) -> void:
	skin_scene = new_scene
	if skin_scene != null and is_inside_tree():
		_skin = skin_scene.instantiate()


func shoot() -> void:
	_shoot_timer.start()
	var bullet := preload("bullet/bullet_3d.tscn").instantiate()
	bullet.shooter = self
	var origin: Vector3 = _skin.hand_anchor.global_position
	var aim_target := _camera_controller.get_aim_target()
	var aim_direction := (aim_target - origin).normalized()
	const max_rotation := PI / 80.0
	aim_direction = aim_direction.rotated(_skin_pivot.transform.basis.x, randf_range(-max_rotation, max_rotation))
	aim_direction = aim_direction.rotated(_skin_pivot.transform.basis.y, randf_range(-max_rotation, max_rotation))
	bullet.velocity = aim_direction * bullet_speed
	bullet.distance_limit = bullet_range
	add_sibling(bullet)
	bullet.global_position = origin

	var projectile_shot := preload("./bullet/shot/projectile_shot.tscn").instantiate()
	add_sibling(projectile_shot)
	projectile_shot.transform = _skin.hand_anchor.global_transform


func _set_camera_controller(new_camera_controller: CameraController3D) -> void:
	_camera_controller = new_camera_controller
	if _camera_controller == null or not is_inside_tree():
		return

	if not _camera_controller.is_inside_tree():
		add_child(_camera_controller)

	_camera_controller.setup(self)

	if Engine.is_editor_hint():
		return
	Events.kill_plane_touched.connect(func on_kill_plane_touched() -> void:
		_camera_controller.global_position = Vector3.ZERO
	)
	Events.flag_reached.connect(func on_flag_reached() -> void:
		_camera_controller.set_pivot(_camera_controller.CameraPivot.THIRD_PERSON)
	)


func _set_skin(new_skin: CharacterSkin) -> void:
	_skin = new_skin
	if _skin == null or not is_inside_tree():
		return

	if _skin.is_inside_tree():
		_skin.get_parent().remove_child(_skin)
	_skin_pivot.add_child(_skin)
