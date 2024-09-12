@tool
extends MobSkin3D

## Increasing this value makes the dummy shine red.
@export var red_intensity := 0.0: set = set_red_intensity

var _tween_damage: Tween = null

@onready var _dummy_model: MeshInstance3D = %dummy2


func _ready() -> void:
	# Ensure the material, which comes from a file, is unique to each mob instance.
	_dummy_model.material_override = _dummy_model.material_override.duplicate()


func play(animation_name: String) -> void:
	if animation_name == "stagger":
		if _tween_damage != null:
			_tween_damage.kill()

		_tween_damage = create_tween()
		_tween_damage.tween_method(set_red_intensity, 1.0, 0.0, 0.2)
		_tween_damage.finished.connect(func ():
			animation_finished.emit("stagger")
		)
	elif animation_name == "die":
		if _tween_damage != null:
			_tween_damage.kill()

		var tween_die := create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
		tween_die.set_parallel(true)
		tween_die.tween_property(self, "scale:y", scale.y * 1.4, 0.2)
		tween_die.tween_property(self, "scale:x", scale.x * 0.8, 0.2)
		tween_die.tween_property(self, "scale:x", scale.z * 0.8, 0.2)
		tween_die.set_parallel(false)
		tween_die.tween_property(self, "scale", Vector3.ZERO, 0.5)
		tween_die.finished.connect(func ():
			animation_finished.emit("die")
		)


# Controls how much the emission is blended in the shader.
# Animate it to flash the mob when taking damage.
func set_red_intensity(value := 0.0) -> void:
	red_intensity = max(value, 0.0)
	_dummy_model.material_override.set_shader_parameter("emission_intensity", red_intensity)
