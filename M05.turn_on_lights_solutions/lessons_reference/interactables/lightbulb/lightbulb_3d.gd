class_name Lightbulb3D extends Interactable3D

var is_active := false: set = set_is_active

var _tween_bulb: Tween = null
var _transparent := Color(1.0, 1.0, 1.0, 0.2)
var _light_black := Color(0.2, 0.2, 0.2, 1.0)

@onready var _bulb: MeshInstance3D = $lightbulb/Bulb
@onready var _omni_light_3d: OmniLight3D = %OmniLight3D


func interact() -> void:
	super()
	set_is_active(not is_active)


func set_is_active(new_value: bool) -> void:
	is_active = new_value
	var energy := 1.2 if is_active else 0.0
	var albedo_color := _light_black if is_active else _transparent

	if _tween_bulb and _tween_bulb.is_valid():
		_tween_bulb.kill()
	_tween_bulb = create_tween()

	if not is_active:
		_tween_bulb.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	_tween_bulb.set_parallel(true)
	_tween_bulb.tween_property(_bulb.material_override, "emission_energy_multiplier", energy, 0.5)
	_tween_bulb.tween_property(_bulb.material_override, "albedo_color", albedo_color, 0.5)
	_tween_bulb.tween_property(_omni_light_3d, "light_energy", energy, 0.5)
