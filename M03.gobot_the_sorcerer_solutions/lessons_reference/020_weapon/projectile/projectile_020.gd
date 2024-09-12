#ANCHOR:class_name
extends Area3D
#END:class_name
#ANCHOR:without_class_name
const ProjectileSkin3D := preload("projectile_skin_020.gd")

## The projectile visual effect scene, instantiated when the projectile spawns.
@export var projectile_vfx: PackedScene = null

## The speed of the projectile in meters per second.
var speed := 25.0
## The maximum range of the projectile in meters.
var max_range := 12.0

var _visual: ProjectileSkin3D = null
var _traveled_distance := 0.0


func _ready() -> void:
	_visual = projectile_vfx.instantiate()
	add_child(_visual)
	_visual.appear()


func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := -transform.basis.z * distance

	position += motion
	_traveled_distance += distance
	if _traveled_distance > max_range:
		_destroy()


func _destroy() -> void:
	set_physics_process(false)
	_visual.destroy()
	_visual.tree_exited.connect(queue_free)
#END:without_class_name
