## Spawns 3D projectiles in the game world when the player presses the shoot button.
extends Node3D

## The scene to instantiate for each projectile.
@export var projectile_scene: PackedScene = null

## Maximum random angle in degrees applied to the shot projectiles, controlling the gun's precision.
## A higher value will result in a wider spread of projectiles, making the gun less accurate.
## For example, a value of 10.0 would result in projectiles deviating up to 10 degrees from the intended direction.
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_random_angle := PI / 10.0

## Maximum distance in units that a projectile can travel before it disappears.
## This value determines how far projectiles can travel before they are removed from the game world.
## For example, a value of 12.0 would result in projectiles disappearing after traveling 12 units.
@export_range(2.0, 40.0, 0.1) var max_range := 12.0

## The speed of the shot projectiles in units per second.
## This value determines how fast projectiles travel through the game world.
## For example, a value of 25.0 would result in projectiles moving at 25 units per second.
@export_range(5.0, 100.0, 0.1) var max_projectile_speed := 25.0
## The rate of fire of the gun in shots per second.
@export_range(0.1, 20.0, 0.05) var fire_rate := 3.0: set = set_fire_rate

@onready var _timer: Timer = %Timer


func _ready() -> void:
	set_fire_rate(fire_rate)


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and _timer.is_stopped():
		shoot()


## Clamps the fire rate and sets the weapon's cooldown timer wait time based on the fire rate.
func set_fire_rate(new_fire_rate: float) -> void:
	fire_rate = clamp(new_fire_rate, 0.1, 20.0)
	if _timer == null:
		return
	_timer.wait_time = 1.0 / fire_rate


## Shoots a projectile from the wand. It checks if the cool-down time has passed
## since the last shot, and if so, instantiates a new projectile and sets it up with
## the current transform, max range, and max projectile speed.
func shoot() -> void:
	_timer.start()
	var projectile: Projectile3D = projectile_scene.instantiate()
	# Add the projectile as a sibling of the player so it is not affected by the wand or the player's transform.
	owner.add_sibling(projectile)

	projectile.global_transform = global_transform
	projectile.max_range = max_range
	projectile.speed = max_projectile_speed
	var random_angle := randf_range(-max_random_angle / 2.0, max_random_angle / 2.0)
	projectile.rotate_y(random_angle)
