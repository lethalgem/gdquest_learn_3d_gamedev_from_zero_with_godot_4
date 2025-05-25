class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.005
@export_range(0.001, 1.0) var joystick_sensitivity := 0.005
@export_category("Ground movement")
@export_range(1.0, 10.0, 0.1) var max_speed_jog := 4.0
@export_range(1.0, 15.0, 0.1) var max_speed_sprint := 7.0
@export_range(1.0, 100.0, 0.1) var acceleration_jog := 15.0
@export_range(1.0, 100.0, 0.1) var acceleration_sprint := 25.0
@export_range(1.0, 100.0, 0.1) var deceleration := 12.0
@export_category("Air movement")
@export_range(1.0, 50.0, 0.1) var gravity := 17.0
@export_range(1.0, 50.0, 0.1) var max_fall_speed := 20.0
@export_range(1.0, 20.0, 0.1) var jump_velocity := 8.0

@onready var _camera: Camera3D = %Camera3D
@onready var _neck: Node3D = %Neck
@onready var _neck_start_height: float = _neck.position.y

func _physics_process(delta: float) -> void:
	var input_direction_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var movement_direction_2d := input_direction_2d.rotated(-1.0 * _camera.rotation.y)
	var movement_direction_3d := Vector3(movement_direction_2d.x, 0.0, movement_direction_2d.y)
	var player_wants_to_move := movement_direction_2d.length() > 0.1
	if player_wants_to_move:
		var max_speed := max_speed_jog
		var acceleration := acceleration_jog
		if Input.is_action_pressed("sprint"):
			max_speed = max_speed_sprint
			acceleration = acceleration_sprint
		var velocity_ground_plane := Vector3(velocity.x, 0.0, velocity.z)
		var velocity_change := acceleration * delta
		velocity_ground_plane = velocity_ground_plane.move_toward(
			movement_direction_3d * max_speed, velocity_change
		)
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
	else:
		var velocity_ground_plane := Vector3(velocity.x, 0.0, velocity.z)
		var velocity_change := deceleration * delta
		velocity_ground_plane = velocity_ground_plane.move_toward(
			Vector3.ZERO, velocity_change
		)
		velocity.x = velocity_ground_plane.x
		velocity.z = velocity_ground_plane.z
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = jump_velocity
	
	var was_in_air := not is_on_floor()
	var fall_speed := absf(velocity.y)
	
	move_and_slide()
	
	var just_landed := was_in_air and is_on_floor()
	if just_landed:
		var impact_intensity := fall_speed / max_fall_speed
		
		var impact_tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		impact_tween.tween_property(_neck, "position:y", _neck.position.y - 0.2 * impact_intensity, 0.06)
		impact_tween.tween_property(_neck, "position:y", _neck_start_height, 0.1)

func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_button := event is InputEventMouseButton
	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("ui_cancel")
	
	if is_mouse_button and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if (event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var look_offset_2d: Vector2 = event.screen_relative * mouse_sensitivity
		_rotate_camera_by(look_offset_2d)

func _process(delta: float) -> void:
	var look_vector := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var look_offset_2d: Vector2 = look_vector * joystick_sensitivity * delta
	_rotate_camera_by(look_offset_2d)

func _rotate_camera_by(look_offset_2d: Vector2) -> void:
	_camera.rotation.y -= look_offset_2d.x
	_camera.rotation.x -= look_offset_2d.y
	_camera.rotation.y = wrapf(_camera.rotation.y, -PI, PI)
	
	const MAX_VERTICAL_ANGLE := PI / 3.0
	_camera.rotation.x = clampf(_camera.rotation.x, -1.0 * MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	
	_camera.orthonormalize()
