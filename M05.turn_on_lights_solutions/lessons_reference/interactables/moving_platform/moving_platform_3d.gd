#ANCHOR: l8_tool
@tool
#END: l8_tool
class_name MovingPlatform3D extends Node3D

@export var end_marker: Marker3D = null
@export var linked_lever: Lever3D = null: set = set_linked_lever

@export var is_active := false: set = set_is_active

#ANCHOR: l8_export_animation
@export_group("Animation")
@export var pause_duration := 1.5
@export var move_duration := 2.0
#END: l8_export_animation

#ANCHOR: l9_export_appearance
@export_group("Appearance")
@export var color_active := Color("ffcb2e")
@export var color_inactive := Color("f6a6ff")
#END: l9_export_appearance

var _tween: Tween = null

@onready var _start_position := global_position
@onready var _platform: AnimatableBody3D = %AnimatableBody3D
@onready var _csg_box_3d: CSGBox3D = %CSGBox3D


func _ready() -> void:
	set_linked_lever(linked_lever)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := []
	if end_marker == null:
		warnings.append(
			"The platform needs an end marker to know where to move to. " +
			"It should be a node that extends Marker3D. Please assign one in the Inspector."
		)
	return warnings


func set_linked_lever(new_lever: Lever3D) -> void:
	#ANCHOR: l9_linked_lever_disconnect
	if linked_lever != null and linked_lever.switched.is_connected(set_is_active):
		linked_lever.switched.disconnect(set_is_active)
		#END: l9_linked_lever_disconnect

	#ANCHOR: l9_linked_lever_set_and_return
	linked_lever = new_lever
	if not is_inside_tree():
		return
		#END: l9_linked_lever_set_and_return

	#ANCHOR: l9_linked_lever_connect
	if linked_lever != null:
		linked_lever.switched.connect(set_is_active)
		set_is_active(linked_lever.is_active)
		#END: l9_linked_lever_connect


func set_is_active(new_value: bool) -> void:
	#ANCHOR: l8_is_active_assign_and_return
	is_active = new_value
	if not is_inside_tree() or end_marker == null:
		return
		#END: l8_is_active_assign_and_return

	#ANCHOR: l8_is_active_tween_kill_and_create
	if _tween and _tween.is_valid():
		_tween.kill()
		#END: l8_is_active_tween_kill_and_create
	#ANCHOR: l8_is_active_create_tween
	_tween = create_tween()
	#END: l8_is_active_create_tween

	#ANCHOR: l8_is_active_tween_loop
	if is_active:
		_tween.set_loops()
		_tween.tween_property(
			_platform,
			"global_position",
			end_marker.global_position,
			move_duration
		).set_delay(pause_duration)
		_tween.tween_property(
			_platform,
			"global_position",
			_start_position,
			move_duration
		).set_delay(pause_duration)
		#END: l8_is_active_tween_loop
	#ANCHOR: l9_is_active_tween_deactivate
	else:
		_tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(_platform, "global_position", _start_position, move_duration)
		#END: l9_is_active_tween_deactivate

	#ANCHOR: L9_tween_color
	var tween_color := create_tween()
	var color := color_active if is_active else color_inactive
	tween_color.tween_property(_csg_box_3d.material_override, "albedo_color", color, 0.2)
	#END: L9_tween_color
