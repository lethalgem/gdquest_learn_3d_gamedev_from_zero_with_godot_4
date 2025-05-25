class_name PlayerFPSController extends CharacterBody3D

@export_range(0.001, 1.0) var mouse_sensitivity := 0.005
@export_range(0.001, 1.0) var joystick_sensitivity := 0.005

@onready var _camera: Camera3D = %Camera3D

var is_using_gamepad := false

func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_button := event is InputEventMouseButton
	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("ui_cancel")
	
	if is_mouse_button and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		is_using_gamepad = false
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if (event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var mouse_deadzone = 0.2
		if event.screen_relative.length() > mouse_deadzone:
			is_using_gamepad = false
			var look_offset_2d: Vector2 = event.screen_relative * mouse_sensitivity
			_rotate_camera_by(look_offset_2d)

func _process(delta: float) -> void:
	var look_vector := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	var joystick_deadzone = 0.2
	if look_vector.length() > joystick_deadzone:
		is_using_gamepad = true
		var look_offset_2d: Vector2 = look_vector * joystick_sensitivity * delta
		_rotate_camera_by(look_offset_2d)

func _rotate_camera_by(look_offset_2d: Vector2) -> void:
	_camera.rotation.y -= look_offset_2d.x
	_camera.rotation.x -= look_offset_2d.y
	_camera.rotation.y = wrapf(_camera.rotation.y, -PI, PI)
	
	const MAX_VERTICAL_ANGLE := PI / 3.0
	_camera.rotation.x = clampf(_camera.rotation.x, -1.0 * MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	
	_camera.orthonormalize()
