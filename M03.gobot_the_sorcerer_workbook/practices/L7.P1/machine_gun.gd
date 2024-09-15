extends Node3D

@export var bullet_scene: PackedScene = null

@export_range(2.0, 40.0, 0.1) var max_range := 12.0
@export_range(5.0, 100.0, 0.1) var max_bullet_speed := 25.0
# Add an exported variable to control the fire rate of the wand.
@export_range(0.01, 100.0, 0.01) var fire_rate := 8.0 : set = set_fire_rate
# Use the timer node to control the attack cooldown, based on the fire rate.
@onready var timer: Timer = %Timer

func set_fire_rate(rate) -> void:
	fire_rate = clamp(rate, 0.01, 100.0)
	if timer == null:
		return
	timer.wait_time = 1.0 / rate
	pass

func _ready() -> void:
	set_fire_rate(fire_rate)
	pass

func _physics_process(_delta: float) -> void:
	# Check if the player is pressing the shoot button and the weapon is ready to fire.
	# If so, shoot a bullet.
	if Input.is_action_just_pressed("shoot") and timer.is_stopped() == true:
		shoot()

func shoot() -> void:
	timer.start()
	var bullet := bullet_scene.instantiate()
	# Add the bullet as a sibling of the weapon's owner so that it moves independently.
	owner.add_sibling(bullet)
	# Set the bullet's initial position and rotation to match the weapon's.
	bullet.global_transform = global_transform
	# Apply the bullet's speed and range based on the machine gun's properties.
	bullet.speed = max_bullet_speed
	bullet.max_range = max_range



#help i can't exit this code block.
#Either way, this is my attept at solving the challenge. However the bullet only shoots a
#single time despite supposedly starting the timer in shoot()
