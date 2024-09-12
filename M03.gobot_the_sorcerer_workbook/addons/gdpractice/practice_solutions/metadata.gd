@tool
extends "res://addons/gdpractice/metadata.gd"


func _init() -> void:
	list += [
		PracticeMetadata.new(
			"03_gobot_the_sorcerer_010_look_at_the_mouse",
			"Look at the mouse",
			preload("res://addons/gdpractice/practice_solutions/L5.P1/look_at_the_mouse.tscn")
		),
		PracticeMetadata.new(
			"03_gobot_the_sorcerer_020_move_item_to_mouse",
			"Move a box to the mouse cursor",
			preload("res://addons/gdpractice/practice_solutions/L5.P2/move_item_to_mouse.tscn")
		),
		PracticeMetadata.new(
			"03_gobot_the_sorcerer_030_instantiate_on_click",
			"Instantiate a scene on click",
			preload("res://addons/gdpractice/practice_solutions/L5.P3/instantiate_on_click.tscn")
		),
		PracticeMetadata.new(
			"03_gobot_the_sorcerer_040_moving_the_bullet",
			"Moving the bullet",
			preload("res://addons/gdpractice/practice_solutions/L6.P1/moving_the_bullet.tscn")
		),
		PracticeMetadata.new(
			"03_gobot_the_sorcerer_050_shooting_bullets",
			"Shooting bullets",
			preload("res://addons/gdpractice/practice_solutions/L7.P1/shooting_bullets.tscn")
		),
	]
