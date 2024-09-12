class_name Projectile3D extends HitBox3D

@export var projectile_vfx: PackedScene = null
@export var impact_vfx: PackedScene = null

var speed := 10.0
var max_range := 10.0

var _visual: ProjectileSkin3D = null
var _traveled_distance := 0.0


func _ready() -> void:
	_visual = projectile_vfx.instantiate()
	add_child(_visual)
	_visual.appear()

	hit_hurt_box.connect(_on_hit)


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

	hit_hurt_box.disconnect(_on_hit)


func _on_hit(_node: Node3D):
	var impact: Node3D = impact_vfx.instantiate()
	impact.transform = transform
	add_sibling(impact)

	_destroy()
