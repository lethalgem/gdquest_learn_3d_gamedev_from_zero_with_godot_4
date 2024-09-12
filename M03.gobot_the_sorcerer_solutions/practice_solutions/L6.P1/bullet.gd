extends Area3D

# Constants are a way to define types locally. Doing this allows you
# to use BulletSkin as a type hint without registering
# the type throughout the project.
const BulletSkin = preload("bullet_skin.gd")

@export var bullet_skin_scene: PackedScene = preload("bullet_skin.tscn") # @export var bullet_skin_scene: PackedScene = null

var speed := 10.0
var max_range := 10.0
var traveled_distance := 0.0

var visual: BulletSkin = null


func _ready() -> void:
	# Store an instance of the skin in the visual variable,
	# add it to the scene and play its appear animation.
	visual = bullet_skin_scene.instantiate() # pass
	add_child(visual) #
	visual.appear() #


func _physics_process(delta: float) -> void:
	# Move the bullet forward and update the traveled distance.
	var distance := speed * delta # pass
	var motion := -transform.basis.z * distance #
	position += motion #

	traveled_distance += distance #
	
	# Destroy the bullet when it travels past the maximum range.
	if traveled_distance > max_range:
		set_physics_process(false) # pass
		visual.destroy() #
		visual.tree_exited.connect(queue_free) #
