extends Node3D

@export var bullet_scene: PackedScene = null

@export_range(2.0, 40.0, 0.1) var max_range := 12.0
@export_range(5.0, 100.0, 0.1) var max_bullet_speed := 25.0
# Add an exported variable to control the fire rate of the wand.

# Use the timer node to control the attack cooldown, based on the fire rate.
@onready var timer: Timer = %Timer


func _ready() -> void:
	# Don't forget to call the fire rate property setter again to initialize the timer.
	pass


func _physics_process(_delta: float) -> void:
	# Check if the player is pressing the shoot button and the weapon is ready to fire.
	# If so, shoot a bullet.
	pass




func shoot() -> void:
	var bullet: Node3D
	# Add the bullet as a sibling of the weapon's owner so that it moves independently.

	# Set the bullet's initial position and rotation to match the weapon's.
	# Apply the bullet's speed and range based on the machine gun's properties.
