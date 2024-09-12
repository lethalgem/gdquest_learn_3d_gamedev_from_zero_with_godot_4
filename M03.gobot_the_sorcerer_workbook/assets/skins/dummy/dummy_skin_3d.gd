extends Node3D

## Controls how much the dummy material's emission is blended with the original material. It turns the model red.
var _emission_blend := 0.0: set = _set_emission_blend
var _tween_damage: Tween = null

@onready var _dummy_material: ShaderMaterial = %"dummy/RIG-Armature/Skeleton3D/dummy2".material_override


func play_damage_animation() -> void:
	if _tween_damage != null:
		_tween_damage.kill()

	_tween_damage = create_tween()
	_emission_blend = 1.0
	_tween_damage.tween_property(self, "_emission_blend", 0.0, 0.2)



func _set_emission_blend(value := 0.0) -> void:
	_emission_blend = clamp(value, 0.0, 1.0)
	_dummy_material.set_shader_parameter("emission_intensity", value)
