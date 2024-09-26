@tool
extends "res://addons/gdpractice/metadata.gd"


func _init() -> void:
	list += [
		PracticeMetadata.new(
			"04_patrol_alert_attack_010_the_turret",
			"The turret",
			preload("res://addons/gdpractice/practice_solutions/L3.P1/the_turret.tscn")
		),
		PracticeMetadata.new(
			"04_patrol_alert_attack_020_fire",
			"Fire!",
			preload("res://addons/gdpractice/practice_solutions/L6.P1/fire.tscn")
		),
		PracticeMetadata.new(
			"04_patrol_alert_attack_030_follow_me",
			"Follow me",
			preload("res://addons/gdpractice/practice_solutions/L7.P1/follow_me.tscn")
		),
	]
