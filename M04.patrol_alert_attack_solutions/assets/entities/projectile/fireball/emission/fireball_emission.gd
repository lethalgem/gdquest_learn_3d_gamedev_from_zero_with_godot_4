extends GPUParticles3D


func _ready() -> void:
	emitting = true
	one_shot = true
	get_tree().create_timer(2.0).timeout.connect(queue_free)
