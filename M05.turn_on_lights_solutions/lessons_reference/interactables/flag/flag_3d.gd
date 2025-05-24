extends Node3D

@onready var _area_3d: Area3D = %Area3D
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	_area_3d.body_entered.connect(func (body_that_entered: PhysicsBody3D) -> void:
		if not body_that_entered is PlayerFPSController:
			return

		body_that_entered.set_physics_process(false)
		await get_tree().create_timer(2.0).timeout
		_animation_player.play("fade_in")
		await _animation_player.animation_finished
		get_tree().quit()
	)
