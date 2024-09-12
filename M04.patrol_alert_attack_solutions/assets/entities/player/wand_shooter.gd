## Spawns 3D projectiles in the game world when the player presses the shoot button.
extends Node3D
@onready var wand_offset = %WandOffset

## The scene to instantiate for each projectile.
@export var projectile_scene: PackedScene = preload("res://assets/entities/projectile/player_fireball.tscn")
@export var ice_attack_scene : PackedScene = preload("res://assets/entities/projectile/ice_attack/ice_attack.tscn")
## Maximum random angle in degrees applied to the shot projectiles, controlling the gun's precision.
## A higher value will result in a wider spread of projectiles, making the gun less accurate.
## For example, a value of 10.0 would result in projectiles deviating up to 10 degrees from the intended direction.
@export_range(0.0, 90.0, 1.0) var random_angle_degrees := 10.0

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

@onready var _timer: Timer = $Timer

enum SPELLS {FIRE_BALL, ICE_SPIKES}
var current_spell : SPELLS = SPELLS.FIRE_BALL
@onready var spells_list = {
	SPELLS.FIRE_BALL: {"firerate": 3.0, "icon": %FireBallIcon},
	SPELLS.ICE_SPIKES: {"firerate": 10.0, "icon": %IceSpikesIcon}
}

func _unhandled_input(event):
	var e = event as InputEventMouseButton
	if e == null: return
	if !e.pressed: return
	var up = e.button_index == MOUSE_BUTTON_WHEEL_UP
	var down = e.button_index == MOUSE_BUTTON_WHEEL_DOWN
	var offset = int(down) - int(up)
	spells_list[current_spell].icon.active = false
	current_spell = posmod(current_spell + offset, SPELLS.size())
	spells_list[current_spell].icon.active = true
	
func _ready() -> void:
	set_fire_rate(fire_rate)
	spells_list[current_spell].icon.active = true

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and _timer.is_stopped():
		shoot()


## Clamps the fire rate and sets the weapon's cooldown timer wait time based on the fire rate.
func set_fire_rate(value: float) -> void:
	fire_rate = clamp(value, 0.1, 20.0)
	if _timer == null:
		return
	_timer.wait_time = 1.0 / fire_rate


## Shoots a projectile from the wand. It checks if the cool-down time has passed
## since the last shot, and if so, instantiates a new projectile and sets it up with
## the current transform, max range, and max projectile speed.
func shoot() -> void:
	_timer.start()
	match current_spell:
		SPELLS.FIRE_BALL:
			var projectile: Projectile3D = projectile_scene.instantiate()
			# Add the projectile as a sibling of the wand so it is not affected by the wand's transform.
			owner.add_sibling(projectile)
			projectile.global_transform = wand_offset.global_transform
			projectile.max_range = max_range
			projectile.speed = max_projectile_speed
		SPELLS.ICE_SPIKES:
			var ice_spell : Node3D = ice_attack_scene.instantiate()
			owner.add_sibling(ice_spell)
			ice_spell.global_transform = global_transform
			ice_spell.position -= ice_spell.global_transform.basis.z 
