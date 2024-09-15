@tool
class_name Projectile3D extends Area3D

@export var projectile_vfx: PackedScene = null: set = set_projectile_vfx

## The speed of the projectile in meters per second.
var speed := 10.0
## The maximum range of the projectile in meters.
var max_range := 10.0
## The rate of acceleration in meters per second^2.
var acceleration := 10.0

# The distance the project has traveled so far.
var _traveled_distance := 0.0

var _visual: ProjectileSkin3D = null

func _ready() -> void:
	set_projectile_vfx(projectile_vfx)
	if Engine.is_editor_hint():
		set_physics_process(false)

func set_projectile_vfx(new_projectile_scene: PackedScene) -> void:
	projectile_vfx = new_projectile_scene
	#If a visual is already displayed, remove it. This is necessary in the editor
	if _visual != null:
		_visual.queue_free()

	# If the visual is null, there is nothing to display, so we return early.
	if projectile_vfx == null:
		return

	# If the projectile is not inside the scene tree, then we won't be able to access the visual effect.
	# We should for the projectile's _ready() function to add the visual effect.
	if not is_inside_tree():
		return

	# Finally, we instantiate the visual effect and add it as a child of the projectile.
	_visual = projectile_vfx.instantiate()
	add_child(_visual)
	_visual.appear()

func _physics_process(delta: float) -> void:
	var distance := speed * delta +  acceleration * delta
	var motion := -transform.basis.z * distance

	position += motion

	_traveled_distance += distance
	if _traveled_distance > max_range:
		_destroy()

func _destroy() -> void:
	set_physics_process(false)
	_visual.destroy()
	_visual.tree_exited.connect(queue_free)
