class_name Mob3D extends CharacterBody3D

@onready var _dummy_skin: Node3D = %DummySkin
@onready var _hurt_box_3d: HurtBox3D = %HurtBox3D


func _ready() -> void:
	_hurt_box_3d.took_hit.connect(func _on_hurt_box_took_hit(hit_box: HitBox3D) -> void:
		_dummy_skin.play_damage_animation()
	)
