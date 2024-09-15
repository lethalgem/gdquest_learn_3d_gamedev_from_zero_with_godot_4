class_name StaticProjectile3D extends Projectile3D

## The duration of the projectile in seconds.
var duration := 1.0

# The distance the projectile spawns away.
var _offset := 0.0

func _physics_process(delta: float) -> void:
	var motion := -transform.basis.z * _offset

	position += motion
