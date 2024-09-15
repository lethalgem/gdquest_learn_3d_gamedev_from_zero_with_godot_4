@tool
class_name Projectile3D extends HitBox3D

@export var projectile_vfx: PackedScene = null: set = set_projectile_vfx

var _visual: ProjectileSkin3D = null

func _ready() -> void:
	set_projectile_vfx(projectile_vfx)
	if Engine.is_editor_hint():
		set_physics_process(false)
	hit_hurt_box.connect(on_hit)

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

func destroy() -> void:
	set_physics_process(false)
	_visual.destroy()
	_visual.tree_exited.connect(queue_free)
	hit_hurt_box.disconnect(on_hit)

func on_hit(_node: Node3D):
	pass
