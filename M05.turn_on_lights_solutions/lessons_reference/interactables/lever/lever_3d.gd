#ANCHOR: l9_tool_class
@tool
class_name Lever3D extends Interactable3D
#END: l9_tool_class

signal switched(is_active: bool)

@export var is_active := false: set = set_is_active

#ANCHOR: l9_var_appearance
@export_group("Appearance")
@export var color_active := Color("ffcb2e")
@export var color_inactive := Color("cfddff")
#END: l9_var_appearance

# We already have a property named _tween in the parent Interactable3D class so
# we need to use a different name
var _tween_lever: Tween = null

@onready var _lever_handle: MeshInstance3D = $Lever3D/LeverHandle
@onready var _handle_tip_material: StandardMaterial3D = _lever_handle.get_surface_override_material(1)


func _ready() -> void:
	interacted_with.connect(func ():
		set_is_active(not is_active)
	)
	set_is_active(is_active)


func set_is_active(new_value: bool):
	#ANCHOR: l9_is_active_head
	if is_active != new_value:
		switched.emit(new_value)

	is_active = new_value

	if not is_inside_tree():
		return
		#END: l9_is_active_head

	#ANCHOR: l9_tween_setup_and_rotation
	if _tween_lever != null:
		_tween_lever.kill()
	_tween_lever = create_tween()

	var target_angle := -1.0 * PI / 3.0 if is_active else PI / 3.0
	_tween_lever.tween_property(_lever_handle, "rotation:z", target_angle, 0.2)
	#END: l9_tween_setup_and_rotation

	#ANCHOR: l9_tween_color
	var color := color_active if is_active else color_inactive
	_tween_lever.parallel().tween_property(_handle_tip_material, "albedo_color", color, 0.2)
	#END: l9_tween_color
