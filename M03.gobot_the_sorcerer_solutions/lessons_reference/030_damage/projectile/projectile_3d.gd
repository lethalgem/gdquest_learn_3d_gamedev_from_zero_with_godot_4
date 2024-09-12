#ANCHOR:class_name
class_name Projectile3D extends HitBox3D
#END:class_name

## The projectile visual effect scene, instantiated when the projectile spawns.
#ANCHOR:l060_01
#ANCHOR:var_projectile_vfx
@export var projectile_vfx: PackedScene = null
#END:var_projectile_vfx
## The impact visual effect scene, instantiated when the projectile hits something.
#ANCHOR:var_impact_vfx
@export var impact_vfx: PackedScene = null
#END:var_impact_vfx

#ANCHOR:vars_speed_range
## The speed of the projectile in meters per second.
var speed := 10.0
## The maximum range of the projectile in meters.
var max_range := 10.0
#END:vars_speed_range

#ANCHOR:var_visual
var _visual: ProjectileSkin3D = null
#END:var_visual
#ANCHOR:var_traveled_distance
var _traveled_distance := 0.0
#END:var_traveled_distance


#ANCHOR:ready_definition
func _ready() -> void:
#END:ready_definition
#ANCHOR:visual_instantiate
	_visual = projectile_vfx.instantiate()
	add_child(_visual)
	_visual.appear()
#END:visual_instantiate
#END:l060_01

#ANCHOR:signals_connect
	hit_hurt_box.connect(_on_hit)
#END:signals_connect


#ANCHOR:l060_02
#ANCHOR:physics_process_definition
func _physics_process(delta: float) -> void:
#END:physics_process_definition
#ANCHOR:motion
	var distance := speed * delta
	var motion := -transform.basis.z * distance

	position += motion
#END:motion
#ANCHOR:range_check
	_traveled_distance += distance
	if _traveled_distance > max_range:
		_destroy()
#END:range_check
#END:l060_02


#ANCHOR:l060_03
#ANCHOR:destroy_definition
func _destroy() -> void:
#END:destroy_definition
#ANCHOR:destroy_visuals
	set_physics_process(false)
	_visual.destroy()
	_visual.tree_exited.connect(queue_free)
#END:destroy_visuals
#END:l060_03

#ANCHOR:signals_disconnect
	hit_hurt_box.disconnect(_on_hit)
#END:signals_disconnect


#ANCHOR:func_on_hit
func _on_hit(_node: Node3D):
	var impact: Node3D = impact_vfx.instantiate()
	impact.transform = transform
	add_sibling(impact)

	_destroy()
#END:func_on_hit

