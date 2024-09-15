extends CharacterBody3D
@onready var _gobot_skin_3d: GobotSkin3D = %GobotSkin3D
@onready var _camera_3d: Camera3D = %Camera3D

## The maximum speed the player can move at in meters per second.
@export_range(3.0, 12.0, 0.1) var max_speed := 6.0
## Controls how quickly the player accelerates and turns on the ground.
@export_range(1.0, 50.0, 0.1) var steering_factor := 20.0

## Represents the game world's ground plane. Used to cast a ray from the
## camera to get the mouse position in 3D space.
var _world_plane := Plane(Vector3.UP)

func _physics_process(delta):
	# Calculate movement based on input and gravity
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)

	var desired_ground_velocity := direction * max_speed
	var steering_vector := desired_ground_velocity - velocity
	steering_vector.y = 0.0
	# We limit the steering amount to ensure the velocity can never overshoot the
	# desired velocity
	var steering_amount: float = min(steering_factor * delta, 1.0)
	velocity += steering_vector * steering_amount

	const GRAVITY := 40.0 * Vector3.DOWN
	velocity += GRAVITY * delta
	move_and_slide()

	# Update the skin animation based on movement
	if is_on_floor() and not direction.is_zero_approx():
		_gobot_skin_3d.run()
	elif not is_on_floor():
		_gobot_skin_3d.fall()
	else:
		_gobot_skin_3d.idle()

	_world_plane.d = global_position.y

	# Raycast to get the mouse position in 3D space and make the player look at it
	var mouse_position_2d := get_viewport().get_mouse_position()
	var mouse_ray := _camera_3d.project_ray_normal(mouse_position_2d)
	var world_mouse_position: Variant = _world_plane.intersects_ray(_camera_3d.global_position, mouse_ray)
	if world_mouse_position != null:
		_gobot_skin_3d.look_at(world_mouse_position)

	if input_vector.length() > 0.0:
		var skin_forward_vector := -1.0 * _gobot_skin_3d.global_basis.z
		_gobot_skin_3d.hips_rotation = skin_forward_vector.signed_angle_to(direction, Vector3.UP)
