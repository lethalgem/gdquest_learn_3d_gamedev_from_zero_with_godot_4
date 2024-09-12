extends ProjectileSkin3D

const FIREBALL_EMISSION = preload("emission/fireball_emission.tscn")

@onready var _fire_particles: GPUParticles3D = %FireParticles
@onready var _smoke_particles: GPUParticles3D = %SmokeParticles
@onready var _magic_sparks: GPUParticles3D = %MagicSparks
@onready var _core: MeshInstance3D = %Core


func appear() -> void:
	var effect: Node3D = FIREBALL_EMISSION.instantiate()
	add_sibling(effect)
	effect.global_position = global_position
	effect.global_rotation = global_rotation


func destroy() -> void:
	_fire_particles.emitting = false
	_smoke_particles.emitting = false
	_magic_sparks.emitting = false
	
	var tween := create_tween()
	tween.tween_property(_core, "scale", Vector3.ZERO, 0.25)
	tween.tween_interval(1.0)
	tween.tween_callback(queue_free)
