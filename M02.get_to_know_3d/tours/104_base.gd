extends "../../addons/godot_tours/tour.gd"

const FILESYSTEM_PATHS := {
	game = "res://level/game.tscn",
	start = "res://level/start.tscn",
	player = "res://player/player_3d.tscn",
	player_skin = "res://player/gdbot_skin.tscn",
	gdbot = "res://player/model/gdbot.glb",
	camera_controller = "res://player/camera_controller.tscn",
	checkerboard = "res://shared/checkboard.png",
	platforms = "res://level/platforms",
	platform_goal = "res://level/platforms/platform_goal.tscn",
	platform_short_ramp = "res://level/platforms/platform_short_ramp.tscn",
	platform_tiny = "res://level/platforms/platform_tiny.tscn",
	flag = "res://level/interactable/flag/flag_3d.tscn",
	moving_platform = "res://level/interactable/moving_platform/moving_platform_3d.tscn",
	moving_platform_script = "res://level/interactable/moving_platform/moving_platform_3d.gd",
	lever = "res://level/interactable/lever/lever_3d.tscn"
}

const RESOURCES := {
	player_skin = preload(FILESYSTEM_PATHS.player_skin),
	camera_controller = preload(FILESYSTEM_PATHS.camera_controller),
	checkerboard = preload(FILESYSTEM_PATHS.checkerboard),
	bubble_background = preload("assets/bubble-background.png"),
	gdquest_logo = preload("assets/gdquest-logo.svg"),
	uv_coordinates = preload("assets/uv_coordinates.png"),
	player_facing_platform = preload("assets/player_facing_platform.png"),
}

const NODE_PATHS := {
	game = "Game",
	player = "Game/Player3D",
	flag = "Game/Flag3D",
	moving_platform = "Game/MovingPlatform3D",
	lever = "Game/Lever3D",
	csgbox = "Game/CSGBox3D",
	platform_goal = "Game/PlatformGoal",
	platform_short_ramp = "Game/PlatformShortRamp",
	platform_tiny = "Game/PlatformTiny",
	marker = "Game/Marker3D"
}

const CREDITS_FOOTER_GDQUEST := "[center]Godot Interactive Tours · Made by [url=https://www.gdquest.com/][b]GDQuest[/b][/url] · [url=https://github.com/GDQuest][b]Github page[/b][/url][/center]"


func _add_intro_step(
	title_text: String,
	content_text: Array[String],
) -> void:
	queue_command(_close_bottom_panel)
	context_set_3d()

	bubble_set_title("")
	bubble_set_background(RESOURCES.bubble_background)
	bubble_add_texture(RESOURCES.gdquest_logo, 80.0)
	bubble_add_text([bbcode_wrap_font_size("[center][b]" + title_text + "[/b][/center]", 32)])
	var centered_content: Array[String] = []
	centered_content.assign(
		content_text.map(func(text: String): return "[center]" + text + "[/center]")
	)
	bubble_add_text(centered_content)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.5))
	spatial_editor_change_viewport_layout(ViewportLayouts.ONE)
	complete_step()
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.0))
