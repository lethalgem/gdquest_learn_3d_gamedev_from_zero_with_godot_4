class_name Player3D extends CharacterBody3D

## Emitted when the player dies
signal died

## Controls how quickly the player accelerates and turns.
@export var steering_factor := 20.0
## The maximum speed the player can move at in meters per second.
@export var max_speed := 6.0
## The player's maximum and starting health.
@export var max_health := 5

@export var die_vfx_scene: PackedScene = null

## The current health of the player.
@onready var _health := max_health: set = _set_health

## This represents the game world's ground plane. We use it to cast a ray from
## the camera to the ground to get the mouse position in 3D space.
## We use this position to make the player look at the mouse.
## A plane is an infinite surface we can project the mouse cursor onto,
## unlike our game level geometry that has gaps.
var _ground_plane := Plane(Vector3.UP)

@onready var _gobot_skin_3d: GobotSkin3D = %GobotSkin3D
## The camera attached to the player. This camera is used to map the 2D mouse
## position into the 3D level.
@onready var _camera_3d: Camera3D = %Camera3D
@onready var _hurt_box_3d: HurtBox3D = %HurtBox3D
@onready var _health_bar_ui: HealthBarUI = %HealthBarUI


func _ready() -> void:
	_health_bar_ui.max_health = max_health
	_hurt_box_3d.took_hit.connect(func _on_hurtbox_took_hit(hit_box: HitBox3D) -> void:
		take_damage(hit_box.damage)
	)


func _physics_process(delta: float) -> void:
	# Calculate movement based on input and gravity.
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)

	var desired_ground_velocity := max_speed * direction
	var steering_vector := desired_ground_velocity - velocity
	steering_vector.y = 0.0
	# We limit the steering amount to ensure the velocity never overshoots the desired velocity.
	var steering_amount: float = min(steering_factor * delta, 1.0)
	velocity += steering_vector * steering_amount

	const GRAVITY := 40.0 * Vector3.DOWN
	velocity += GRAVITY * delta
	move_and_slide()

	# Update the skin animation based on movement.
	if is_on_floor() and not direction.is_zero_approx():
		_gobot_skin_3d.run()
	else:
		_gobot_skin_3d.idle()

	# Raycast to get the mouse position in 3D space and make the player look at it.
	var mouse_position_2d := get_viewport().get_mouse_position()
	var mouse_ray := _camera_3d.project_ray_normal(mouse_position_2d)
	var world_mouse_position: Variant = _ground_plane.intersects_ray(_camera_3d.global_position, mouse_ray)
	if world_mouse_position != null:
		_gobot_skin_3d.look_at(world_mouse_position)

	# Make the legs turn based on the ground movement.
	if input_vector.length() > 0.0:
		var skin_forward_vector := -1.0 * _gobot_skin_3d.global_basis.z
		_gobot_skin_3d.hips_rotation = skin_forward_vector.signed_angle_to(direction, Vector3.UP)


## Reduce the player's health by one and updates the health bar UI. If the health
## reaches zero, the player dies.
func take_damage(amount: int) -> void:
	_health = max(0, _health - amount)
	_gobot_skin_3d.hurt()
	if _health == 0:
		_die()


## Called when the player dies. Disables the player and plays a death sound effect.
func _die() -> void:
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	hide()
	if die_vfx_scene != null:
		var vfx: Node3D = die_vfx_scene.instantiate()
		add_sibling(vfx)
		vfx.global_position = global_position
	died.emit()


func _set_health(new_value: int) -> void:
	_health = clampi(new_value, 0, max_health)
	if _health_bar_ui == null:
		return
	_health_bar_ui.health = _health
