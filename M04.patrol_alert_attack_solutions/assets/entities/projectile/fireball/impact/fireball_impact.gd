extends Node3D

@onready var fire_particles = %FireParticles
@onready var smoke_particles = %SmokeParticles
@onready var animation_player = %AnimationPlayer

func _ready():
	animation_player.play("default")
	await get_tree().create_timer(2.0).timeout
	queue_free()
