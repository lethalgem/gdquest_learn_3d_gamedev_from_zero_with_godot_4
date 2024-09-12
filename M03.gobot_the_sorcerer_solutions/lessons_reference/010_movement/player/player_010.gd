#ANCHOR:extends
extends CharacterBody3D
#END:extends

#ANCHOR:exported_vars
## The maximum speed the player can move at in meters per second.
@export_range(3.0, 12.0, 0.1) var max_speed := 6.0
## Controls how quickly the player accelerates and turns on the ground.
@export_range(1.0, 50.0, 0.1) var steering_factor := 20.0
#END:exported_vars

## This represents the game world's ground plane. We use it to cast a ray from
## the camera to the ground to get the mouse position in 3D space.
## A plane is an infinite surface we can project the mouse cursor onto,
## unlike our game level geometry that has gaps.
#ANCHOR:var_world_plane
var _world_plane := Plane(Vector3.UP)
#END:var_world_plane

#ANCHOR:var_gobot_skin_3d
@onready var _gobot_skin_3d: GobotSkin3D = %GobotSkin3D
#END:var_gobot_skin_3d
#ANCHOR:var_camera_3d
@onready var _camera_3d: Camera3D = %Camera3D
#END:var_camera_3d


#ANCHOR:l_030
#ANCHOR:func_physics_process
func _physics_process(delta: float) -> void:
#END:func_physics_process
	# Calculate movement based on input and gravity.
#ANCHOR:input_vector
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
#END:input_vector
#ANCHOR:direction
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
#END:direction

#ANCHOR:steering
	var desired_ground_velocity := max_speed * direction
	var steering_vector := desired_ground_velocity - velocity
	steering_vector.y = 0.0
	# We limit the steering amount to ensure the velocity can never overshoots the
	# desired velocity.
	var steering_amount: float = min(steering_factor * delta, 1.0)
	velocity += steering_vector * steering_amount
#END:steering

#ANCHOR:gravity
	const GRAVITY := 40.0 * Vector3.DOWN
	velocity += GRAVITY * delta
#END:gravity
#ANCHOR:move_and_slide
	move_and_slide()
#END:move_and_slide

	# Update the skin animation based on movement.
#ANCHOR:animation
	if is_on_floor() and not direction.is_zero_approx():
		_gobot_skin_3d.run()
	else:
		_gobot_skin_3d.idle()
#END:animation
#END:l_030

#ANCHOR:move_world_plane
	_world_plane.d = global_position.y
#END:move_world_plane

	# Raycast to get the mouse position in 3D space and make the player look at it.
#ANCHOR:raycast
	var mouse_position_2d := get_viewport().get_mouse_position()
	var mouse_ray := _camera_3d.project_ray_normal(mouse_position_2d)
	var world_mouse_position: Variant = _world_plane.intersects_ray(_camera_3d.global_position, mouse_ray)
#END:raycast
#ANCHOR:look_at
	if world_mouse_position != null:
		_gobot_skin_3d.look_at(world_mouse_position)
#END:look_at

#ANCHOR:input_vector_length
	if input_vector.length() > 0.0:
#END:input_vector_length
#ANCHOR:hips_rotation
		var skin_forward_vector := -1.0 * _gobot_skin_3d.global_basis.z
		_gobot_skin_3d.hips_rotation = skin_forward_vector.signed_angle_to(direction, Vector3.UP)
#END:hips_rotation
