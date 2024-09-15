extends Marker3D

@export var projectile_scene: PackedScene = null
## shots per second
@export_range(0.1, 20.0, 0.05) var fire_rate: float = 3.0: set = set_fire_rate
@export_range(5.0, 100.0, 0.1) var max_projectile_speed := 12.0
@export_range(1.0, 10.0, 0.1) var max_projectile_scale := 2.0
@export_range(2.0, 40.0, 0.1) var max_range := 12.0
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_random_angle := PI / 10.0

@onready var _timer: Timer = %Timer

func set_fire_rate(new_fire_rate: float):
	fire_rate = clamp(new_fire_rate, 0.1, 20.0)
	if _timer != null:
		_timer.wait_time = 1.0 / new_fire_rate

func _ready() -> void:
	set_fire_rate(fire_rate)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and _timer.is_stopped():
		shoot()

func shoot() -> void:
	var projectile: Projectile3D = projectile_scene.instantiate()
	# Add the projectile as a sibling of the player so it is not affected by the wand or the player's transform.
	owner.add_sibling(projectile)
	_timer.start()
	projectile.global_transform = global_transform
	projectile.max_range = max_range
	projectile.speed = max_projectile_speed
	projectile.max_scale = max_projectile_scale
	var angle := randf_range(-max_random_angle / 2.0, max_random_angle / 2.0)
	projectile.rotate_y(angle)
