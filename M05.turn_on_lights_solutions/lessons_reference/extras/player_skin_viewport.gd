class_name FPSArmsView extends SubViewportContainer

var is_walking := false: set = set_is_walking

var vertical_velocity := 0.0
var angular_velocity := Vector3.ZERO

@onready var root: Node3D = %Root
@onready var _fps_arms: Node3D = %FPSArms

@onready var _animation_player: AnimationPlayer = _fps_arms.get_node("AnimationPlayer")


func _ready() -> void:
	_fps_arms.top_level = true


# This rotates and moves the arms back to lag behind the camera when the player moves.
func _process(delta: float) -> void:
	_fps_arms.global_position = root.global_position
	_fps_arms.global_rotation.x = root.global_rotation.x
	var target_rotation_y := root.global_rotation.y
	var factor := minf(delta * 10.0, 1.0)
	_fps_arms.global_rotation.y = lerp_angle(
		_fps_arms.global_rotation.y,
		target_rotation_y,
		factor
	)
	const MAX_ANGLE := PI / 12.0
	var angle_difference := wrapf(_fps_arms.global_rotation.y - target_rotation_y, -PI, PI)
	if abs(angle_difference) > MAX_ANGLE:
		var clamped_difference := clampf(angle_difference, -MAX_ANGLE, MAX_ANGLE)
		_fps_arms.global_rotation.y = wrapf(target_rotation_y + clamped_difference, -PI, PI)


func set_is_walking(new_value: bool) -> void:
	if is_walking == new_value:
		return

	is_walking = new_value
	if is_walking:
		_animation_player.play("Walk")
	else:
		_animation_player.play("Idle")
