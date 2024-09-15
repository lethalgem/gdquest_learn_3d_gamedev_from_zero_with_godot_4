class_name MovingProjectile3D extends Projectile3D

@export var impact_vfx: PackedScene = null

## The speed of the projectile in meters per second.
var speed := 10.0
## The maximum range of the projectile in meters.
var max_range := 10.0

# The distance the project has traveled so far.
var _traveled_distance := 0.0

func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := -transform.basis.z * distance

	position += motion

	_traveled_distance += distance
	if _traveled_distance > max_range:
		destroy()

func on_hit(_node: Node3D):
	var impact: Node3D = impact_vfx.instantiate()
	impact.transform = transform
	add_sibling(impact)

	destroy()
