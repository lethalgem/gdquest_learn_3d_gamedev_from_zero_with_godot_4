class_name PlayerFPSController extends CharacterBody3D

func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_button := event is InputEventMouseButton
	var is_mouse_captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var is_escape_pressed := event.is_action_pressed("ui_cancel")
	
	if is_mouse_button and not is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif is_escape_pressed and is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
