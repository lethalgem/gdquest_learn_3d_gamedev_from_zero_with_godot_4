class_name HealthBarUI extends Control

const HealthPointTextureRect := preload("health_point_texture_rect.tscn")

const TEXTURE_EMPTY := preload("health_point_bg.png")
const TEXTURE_FULL := preload("health_point.png")

var max_health := 0: set = set_max_health
var health := 0: set = set_health

@onready var _h_box_container: HBoxContainer = %HBoxContainer


func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health
	for texture_rect: TextureRect in _h_box_container.get_children():
		texture_rect.queue_free()

	for _index in range(max_health):
		_h_box_container.add_child(HealthPointTextureRect.instantiate())


func set_health(new_health: int) -> void:
	health = new_health
	for texture_rect: TextureRect in _h_box_container.get_children():
		texture_rect.texture = TEXTURE_FULL if health > texture_rect.get_index() else TEXTURE_EMPTY
