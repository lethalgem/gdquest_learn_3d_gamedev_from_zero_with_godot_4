#ANCHOR: l5_head
class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.005
@export_range(0.001, 5.0) var joystick_sensitivity := 0.05

# ANCHOR: L3_export_category
@export_category("Ground movement")
# END: L3_export_category
@export_range(1.0, 10.0, 0.1) var max_speed_jog := 4.0
@export_range(1.0, 15.0, 0.1) var max_speed_sprint := 7.0
@export_range(1.0, 100.0, 0.1) var acceleration_jog := 15.0
@export_range(1.0, 100.0, 0.1) var acceleration_sprint := 25.0
@export_range(1.0, 100.0, 0.1) var deceleration := 12.0
# L5.crouch
@export_range(1.0, 10.0, 0.1) var max_speed_crouch := 2.0

# ANCHOR: L4_export_category
@export_category("Air movement")
# END: L4_export_category
@export_range(1.0, 50.0, 0.1) var gravity := 17.0
@export_range(1.0, 50.0, 0.1) var max_fall_speed := 20.0
@export_range(1.0, 20.0, 0.1) var jump_velocity := 8.0

var is_crouching := false: set = set_is_crouching

@onready var _camera: Camera3D = %Camera3D
@onready var _neck: Node3D = %Neck

@onready var _collision_shape: CollisionShape3D = %CollisionShape3D
@onready var _crouch_ceiling_cast: ShapeCast3D = %CrouchCeilingCast

@onready var _collision_shape_start_height: float = _collision_shape.shape.height
@onready var _neck_start_height: float = _neck.position.y
#END: l5_head

@onready var _animation_player: AnimationPlayer = %FPSArmsModel.get_node("AnimationPlayer")


func _ready() -> void:
	_animation_player.playback_default_blend_time = 0.2


func _unhandled_input(event: InputEvent) -> void:
	#ANCHOR: l2_input_mouse_mode
	var is_mouse_button := event is InputEventMouseButton
	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("ui_cancel")

	if is_mouse_button and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#END: l2_input_mouse_mode

	#ANCHOR: l2_mouse_look
	if (event is InputEventMouseMotion and
		Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var look_offset_2d: Vector2 = event.screen_relative * mouse_sensitivity
		_rotate_camera_by(look_offset_2d)
	#END: l2_mouse_look


func _process(delta: float) -> void:
	#ANCHOR: l2_joystick_look
	var joystick_look_vector := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var look_offset_2d := joystick_look_vector * joystick_sensitivity * delta
	_rotate_camera_by(look_offset_2d)
	#END: l2_joystick_look


func _physics_process(delta: float) -> void:
	#ANCHOR: L3_input_direction
	var input_direction_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var movement_direction_2d := input_direction_2d.rotated(-1.0 * _camera.rotation.y)
	var movement_direction_3d := Vector3(movement_direction_2d.x, 0.0, movement_direction_2d.y)
	#END: L3_input_direction

	# Movement in the ground plane
	#ANCHOR: L3_player_is_moving_var
	var player_wants_to_move := movement_direction_2d.length() > 0.1
	if player_wants_to_move:
	#END: L3_player_is_moving_var
		#ANCHOR: L3_max_speed
		var max_speed := max_speed_jog
		var acceleration := acceleration_jog
		if Input.is_action_pressed("sprint"):
			max_speed = max_speed_sprint
			acceleration = acceleration_sprint
		#END: L3_max_speed
		#ANCHOR: L5_crouch_speed
		if is_crouching:
			max_speed = max_speed_crouch
			#END: L5_crouch_speed

		#ANCHOR: L3_acceleration
		var velocity_ground_plane := Vector3(velocity.x, 0.0, velocity.z)
		var velocity_change := acceleration * delta
		velocity_ground_plane = velocity_ground_plane.move_toward(
			movement_direction_3d * max_speed, velocity_change
		)
		#ANCHOR: L3_update_velocity
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
		#END: L3_update_velocity
		# END: L3_acceleration
	# Drag when the player stops pressing movement keys
	#ANCHOR: L3_deceleration
	else:
		var velocity_ground_plane := Vector3(velocity.x, 0.0, velocity.z)
		velocity_ground_plane = velocity_ground_plane.move_toward(Vector3.ZERO, deceleration * delta)
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
		# END: L3_deceleration

	# Crouching
	#ANCHOR: l5_crouch_input
	if is_on_floor():
		set_is_crouching(Input.is_action_pressed("crouching"))
		#END: l5_crouch_input

	# Jumping and falling
	#ANCHOR: l4_gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	#END: l4_gravity
	#ANCHOR: l4_jump_input
	if is_on_floor() and Input.is_action_just_pressed("jump") and not is_crouching:
		velocity.y = jump_velocity
	#END: l4_jump_input

	#ANCHOR: l4_was_in_air
	var was_in_air := not is_on_floor()
	#END: l4_was_in_air
	#ANCHOR: l4_fall_speed
	var fall_speed := absf(velocity.y)
	#END: l4_fall_speed

	#ANCHOR: L3_move_and_slide
	move_and_slide()
	#END: L3_move_and_slide

	#ANCHOR: L4_just_landed
	var just_landed := was_in_air and is_on_floor()
	#END: L4_just_landed
	#ANCHOR: l4_just_landed_condition
	if just_landed:
		#END: l4_just_landed_condition
		#ANCHOR: l4_landing_animation
		var impact_intensity := fall_speed / max_fall_speed

		var impact_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		impact_tween.tween_property(_neck, "position:y", _neck.position.y - 0.2 * impact_intensity, 0.06)
		impact_tween.tween_property(_neck, "position:y", _neck_start_height, 0.1)
		#END: l4_landing_animation

	#ANCHOR: l10_animation
	if is_on_floor() and player_wants_to_move:
		_animation_player.play("Walk")
		_animation_player.speed_scale = 0.5 + velocity.length() / max_speed_sprint
	elif _animation_player.current_animation != "Idle":
		_animation_player.play("Idle")
		_animation_player.speed_scale = 1.0
		#END: l10_animation


func set_is_crouching(new_value: bool) -> void:
	#ANCHOR: l5_crouch_equal_check
	if is_crouching == new_value:
		return
	#END: l5_crouch_equal_check

	#ANCHOR: l5_crouch_ceiling_cast
	if new_value == false:
		_crouch_ceiling_cast.force_shapecast_update()
		if _crouch_ceiling_cast.is_colliding():
			return
	#END: l5_crouch_ceiling_cast

	#ANCHOR: l5_crouch_set
	is_crouching = new_value
	#END: l5_crouch_set

	# Update the collision shape's height and position immediately
	#ANCHOR: l5_crouch_collision_shape
	if is_crouching:
		_collision_shape.shape.height = _collision_shape_start_height / 2.0
	else:
		_collision_shape.shape.height = _collision_shape_start_height
	_collision_shape.position.y = _collision_shape.shape.height / 2.0
	#END: l5_crouch_collision_shape

	# Animate the Neck node, which controls the camera, moving up and down
	# depending on the crouching state
	#ANCHOR: l5_crouch_neck_animation
	var target_neck_height := 0.0
	if is_crouching:
		target_neck_height = _neck_start_height * 0.7
	else:
		target_neck_height = _neck_start_height
	var crouch_tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	crouch_tween.tween_property(_neck, "position:y", target_neck_height, 0.25)
	#END: l5_crouch_neck_animation


## This function turns the camera according to a 2D direction vector.
## The vector's x component controls looking left and right (rotating around the
## y-axis), and the y component controls looking up and down (rotating around
## the x-axis).
func _rotate_camera_by(look_offset_2d: Vector2) -> void:
	#ANCHOR: l2_rotate_camera
	_camera.rotation.y -= look_offset_2d.x
	_camera.rotation.x -= look_offset_2d.y
	_camera.rotation.y = wrapf(_camera.rotation.y, -PI, PI)
	#END: l2_rotate_camera

	#ANCHOR: l2_clamp_camera
	const MAX_VERTICAL_ANGLE := PI / 3.0
	_camera.rotation.x = clampf(_camera.rotation.x, -1.0 * MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	#END: l2_clamp_camera
	#ANCHOR: l2_orthonormalize_camera
	_camera.orthonormalize()
	#END: l2_orthonormalize_camera
