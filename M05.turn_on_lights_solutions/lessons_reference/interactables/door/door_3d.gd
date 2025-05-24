@tool
class_name Door3D extends Interactable3D

var is_active := false: set = set_is_active

var _tween_door: Tween = null

@onready var _door_bottom: Node3D = $door/DoorBottom
@onready var _door_top: Node3D = $door/DoorTop

@onready var _static_body_collision_shape_3d: CollisionShape3D = %StaticBodyCollisionShape3D


func interact() -> void:
	super()
	set_is_active(not is_active)


func set_is_active(value: bool) -> void:
	#ANCHOR: is_active_toggle_active
	is_active = value
	_static_body_collision_shape_3d.disabled = is_active
	#END: is_active_toggle_active

	#ANCHOR: is_active_animation
	var top_value := 2.0 if is_active else 1.0
	var bottom_value := 0.0 if is_active else 1.0

	if _tween_door != null:
		_tween_door.kill()
	_tween_door = create_tween().set_parallel(true)

	_tween_door.set_ease(Tween.EASE_OUT)
	_tween_door.set_trans(Tween.TRANS_BACK if is_active else Tween.TRANS_BOUNCE)

	_tween_door.tween_property(_door_top, "position:y", top_value, 1.0)
	_tween_door.tween_property(_door_bottom, "position:y", bottom_value, 1.0)
	#END: is_active_animation
