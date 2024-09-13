extends CharacterBody3D

func _physics_process(delta):
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
