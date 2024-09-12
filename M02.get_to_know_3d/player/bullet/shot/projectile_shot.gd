extends Node3D

@onready var sparkes = %Sparkes

func _ready():
	sparkes.emitting = true
	sparkes.finished.connect(queue_free)
