extends "../../addons/godot_tours/tour.gd"

const GAME_CAMERA_PATH := "Game/Camera3D"
const GAME_DIRECTIONAL_LIGHT_PATH := "Game/DirectionalLight3D"
const GAME_WORLD_ENVIRONMENT_PATH := "Game/WorldEnvironment"
const PATH_WORLD_ENVIRONMENT_TRES := "res://level/vfx/world_environment.tres"

const RESOURCES := {
	bubble_background = preload("../assets/bubble-background.png"),
	gdquest_logo = preload("../assets/gdquest-logo.svg"),
	world_environment = preload(PATH_WORLD_ENVIRONMENT_TRES),
}

const CREDITS_FOOTER_GDQUEST := "[center]Godot Interactive Tours · Made by [url=https://www.gdquest.com/][b]GDQuest[/b][/url] · [url=https://github.com/GDQuest][b]Github page[/b][/url][/center]"


func _build() -> void:

	# Reset the view and buttons to a default state
	queue_command(func reset_to_defaults():
		var view_popup := interface.spatial_editor_toolbar_view_menu_button.get_popup()
		view_popup.toggle_item_checked(0)
		interface.spatial_editor_toolbar_snap_button.button_pressed = false
		interface.bottom_button_output.button_pressed = false
	)
	context_set_3d()
	bubble_set_title("")
	bubble_set_background(RESOURCES.bubble_background)
	bubble_add_texture(RESOURCES.gdquest_logo, 80.0)
	bubble_add_text([bbcode_wrap_font_size(gtr("[center][b]103. Introduction to 3D in Godot[/b][/center]"), 32)])
	bubble_add_text(
		[
			gtr("[center]In this first tour, we will add the elements necessary for a 3D game and learn to navigate the 3D view.[/center]"),
			gtr("[center]Let's get right into it![/center]")
		]
	)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.5))
	complete_step()

	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.0))
	scene_open("res://level/unfinished_game.tscn")
	spatial_editor_focus()
	spatial_editor_change_viewport_layout(ViewportLayouts.ONE)
	bubble_set_title(gtr("The unfinished game scene"))
	bubble_add_text(
		[
			gtr("I just opened the scene [b]unfinished_game.tscn[/b] for you."),
			gtr("This small game scene has a character, platforms, and a flag."),
			gtr("Run the scene by clicking the [b]Run Current Scene[/b] button at the top right of the editor or pressing [b]%s[/b] on your keyboard.") % shortcuts.run_current,
			gtr("You'll see a completely gray screen... Don't panic! It's to be expected. I'll explain why in the next step."),
			gtr("Press [b]%s[/b] or close the game window to stop the game.") % shortcuts.stop
		]
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	highlight_controls([interface.run_bar_play_current_button], true)
	complete_step()

	bubble_set_title(gtr("The gray screen"))
	bubble_add_text(
		[
			gtr("When running the game, the screen is completely gray because the scene currently lacks a camera."),
			gtr("In the 3D world, like in the real world, we need something like a pair of eyes or a virtual camera to tell the computer where to look and what to display."),
			gtr("In Godot, to add and control the game's 3D camera, we use the [b]Camera3D[/b] node."),
		]
	)
	complete_step()

	bubble_set_title(gtr("Add the camera node"))
	bubble_add_text(
		[
			gtr("Let's add a [b]Camera3D[/b] node to the scene."),
			gtr('To add the camera, select the [b]Game[/b] node in the Scene dock and click the [b]Add Child Node[/b] button at the top left. You can also press [b]%s+A[/b] on your keyboard to open the Add Node dialog. Search for the [b]Camera3D[/b] node and create it in the scene.') % shortcuts.ctrl,
			gtr("This creates and places the camera at the origin of the 3D game world."),
			gtr("Note that if you make a mistake at any point, you can press [b]%s+Z[/b] to undo the last action.") % shortcuts.ctrl,
		]
	)
	bubble_add_task(
		gtr("Add a [b]Camera3D[/b] as a child of the [b]Game[/b] node"),
		1,
		func add_camera_as_child_of_game_task(_task: Task) -> int:
			var camera := get_scene_node_by_path(GAME_CAMERA_PATH)
			return 1 if camera != null else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	highlight_scene_nodes_by_path(["Game"], -1, false)
	highlight_controls([interface.scene_dock_button_add], true)
	complete_step()

	bubble_set_title(gtr("The Camera3D node"))
	bubble_add_text([
			gtr("After creating the node, notice the camera icon in the 3D view."),
			gtr("It comes with a small tapered wireframe box that extends from it. This wireframe represents the direction in which the camera is looking.")
		]
	)
	bubble_add_texture(preload("../assets/camera_icon_wireframe.png"))
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Run the scene"))
	bubble_add_text(
		[
			gtr("Try running the scene now to see... something, at least! The camera is located at the world's origin, and it's facing a platform, so that's what you'll see."),
			gtr("The running game remains dark because there are no lights in the scene. We will add a light later. For now, let's learn how to place the camera behind the character by moving the view and manipulating 3D nodes."),
			gtr("Run the scene by clicking the [b]Run Current Scene[/b] button at the top right of the editor or pressing [b]%s[/b] on your keyboard. Press [b]%s[/b] or close the game window to stop the game.") % [shortcuts.run_current, shortcuts.stop]
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	highlight_controls([interface.run_bar_play_current_button], true)
	complete_step()

	bubble_set_title(gtr("How to navigate the 3D view"))
	bubble_add_text(
		[
			gtr("To move nodes in 3D, we often need to turn, pan, and zoom the view. Here's how you can do that in the 3D view:"),
			"[ul]" + gtr("To rotate the 3D view, hold the [b]Middle Mouse Button[/b] down and move the mouse.\n") +
			gtr("To pan the view and move around, hold the [b]Shift[/b] key and [b]Middle Mouse Button[/b] down, then move the mouse.\n") +
			gtr("To zoom in and out, use the mouse wheel.") + "[/ul]",
			gtr("Try moving, turning, and zooming the view to test the controls."),
		]
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Focus the camera node"))
	bubble_add_text(
		[
			gtr("When you rotate the view, it rotates around a point. This point is the last point of [b]focus[/b] you set in the editor. By default, it's located at the center of the view."),
			gtr("You can quickly align the view to a node and make that node the focus point by selecting a node and pressing the [b]%s[/b] key on your keyboard.") % shortcuts.focus,
			gtr("Ensure that the [b]Camera3D[/b] node is selected in the [b]Scene[/b] dock and press [b]%s[/b] to focus the view on the camera.") % shortcuts.focus,
			gtr("This will re-center the view on the camera. The view will rotate around this point until you change it again."),
			gtr("Note that, for the shortcut to work, the mouse cursor should be over the 3D view.")
		]
	)
	bubble_add_task_focus_node(GAME_CAMERA_PATH.get_file())
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_controls([interface.spatial_editor])
	highlight_scene_nodes_by_path([GAME_CAMERA_PATH])
	complete_step()

	bubble_set_title(gtr("Rotate the view around the camera"))
	bubble_add_text([
		gtr("Now that the camera node is in focus, try rotating the view. Hold the [b]Middle Mouse Button[/b] and drag to rotate the view around the camera.")])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Select the Move Mode"))
	bubble_add_text(
		[
			gtr("To move a 3D object, as in 2D, you can use the %s [b]Move Mode[/b] in the toolbar at the top. Click the Move Mode icon in the toolbar above the viewport to display only the 3D position manipulator. You can also press [b]%s[/b] on your keyboard to activate it.") % [bbcode_generate_icon_image_by_name("ToolMove"), shortcuts.move_mode],
		]
	)
	bubble_add_task_toggle_button(
		interface.spatial_editor_toolbar_move_button, true, "Switch to [b]Move Mode[/b]"
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_controls([interface.spatial_editor_toolbar_move_button])
	complete_step()

	bubble_set_title(gtr("The 3D position manipulator"))
	bubble_add_text(
		[
			gtr("The position manipulator has three axes you can click and drag to move the camera node along that axis. The red line corresponds to the X axis, the green line to the vertical Y axis, and the blue line to the Z axis."),
			gtr("You can also click and drag on the floating colored squares between axes to move the camera within the corresponding plane.")
		]
	)
	bubble_add_video(preload("../assets/video_move_node.ogv"))
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	complete_step()

	bubble_set_title(gtr("Move the camera"))
	bubble_add_text(
		[
			gtr("Click and drag on the position manipulator axes and squares to move the camera node behind the character, in the floating blue box."),
			gtr("Use the navigation tricks you learned previously to move the view as needed:"),
			"[ul]" + (gtr("Change the editor's focus point with [b]%s[/b].\n") % shortcuts.focus) +
			gtr("Rotate the view with the [b]Middle Mouse Click[/b].\n") +
			gtr("Pan the view with [b]Shift + Middle Mouse Click[/b].\n") +
			gtr("Zoom in and out with the [b]Mouse Wheel[/b].") + "[/ul]",
		]
	)
	bubble_add_texture(preload("../assets/camera_behind_player.png"))
	bubble_add_task_node_to_guide(Guide3DTaskParameters.new("Camera3D", Vector3(0, 0, -20), Guide3DCheckMode.IN_BOUNDING_BOX))
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The camera direction"))
	bubble_add_text(
		[
			gtr("Notice the tapered pink box that expands from the camera icon in the viewport. This box wireframe represents the direction in which the camera is looking."),
			gtr("There's a little purple triangle above the purple wireframe in the viewport. It indicates the up direction of the camera. It should be pointing up or the view will be inverted."),
			gtr("At the moment, the camera is looking away from the player character."),
			gtr("To look at the player character, we need to rotate the box wireframe so that it extends towards the player."),
		]
	)
	bubble_add_texture(preload("../assets/camera_icon_wireframe.png"))
	complete_step()

	bubble_set_title(gtr("Select the Rotate mode"))
	bubble_add_text(
		[
			gtr("Select the %s [b]Rotate Mode[/b] in the toolbar above the viewport to display the rotation manipulator.") % bbcode_generate_icon_image_by_name("ToolRotate"),
			gtr("This manipulator has three circles representing the rotations you can perform: you can turn the selected node around the [b]x[/b], [b]y[/b], and [b]z[/b] axes."),
			gtr("For example, clicking and dragging on the green circle will rotate the camera around the vertical axis, the y-axis.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	bubble_add_video(preload("../assets/video_rotate_node.ogv"))
	bubble_add_task_toggle_button(
		interface.spatial_editor_toolbar_rotate_button,
		true,
		"Turn the [b]Rotate Mode[/b] button ON."
	)
	highlight_controls([interface.spatial_editor_toolbar_rotate_button])
	complete_step()

	bubble_set_title(gtr("Make the camera look at the player"))
	bubble_add_text(
		[
			gtr("Using the Rotate mode, turn the camera to look towards the player. You can rotate it around the y axis by clicking and dragging the green circle on the rotation manipulator."),
			gtr("Your camera should be behind the player character and looking at it. You don't need to make the orientation perfect; you'll be able to adjust it later."),
			gtr("You can press [b]%s[/b] at any time to run the scene and see what the camera sees. Press [b]%s[/b] to stop the game.") % [shortcuts.run_current, shortcuts.stop],
			gtr("Don't worry about the fact everything is dark; we'll address that in a moment.")
		]
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_add_texture(preload("../assets/camera_looking_at_player.png"))
	highlight_controls([interface.spatial_editor])
	bubble_add_task(
		"Rotate the camera around the y axis to look at the player",
		1,
		func rotate_directional_light_task(_task: Task) -> int:
			var camera: Camera3D = get_scene_node_by_path(GAME_CAMERA_PATH)
			var angle: float = wrapf(abs(camera.global_rotation_degrees.y), 0.0, 360.0)
			return 1 if angle > 160.0 and angle < 200.0 else 0
	)
	complete_step()

	bubble_set_title(gtr("The camera preview"))
	bubble_add_text(
		[
			gtr("Running the scene to check the camera's view is cumbersome. Thankfully, we can use the camera preview to see what the camera sees in the editor."),
			gtr("You can toggle the camera preview by clicking the [b]Preview[/b] check box at the top left of the viewport."),
			gtr("When you turn on the preview, you should see the player character in the camera view. You can also press [b]%s+P[/b] on your keyboard to toggle the preview.") % shortcuts.ctrl
		]
	)
	bubble_add_task(
		"Turn on the camera preview",
		1,
		func check_camera_preview_task(_task: Task) -> int:
			return 1 if interface.spatial_editor_preview_check_boxes.front().button_pressed else 0
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	scene_select_nodes_by_path([GAME_CAMERA_PATH])
	var preview_check_boxes: Array[Control] = []
	preview_check_boxes.assign(interface.spatial_editor_preview_check_boxes)
	highlight_controls(preview_check_boxes)
	complete_step()

	bubble_set_title(gtr("Split the view in two"))
	bubble_add_text(
		[
			gtr("With a single view, we have to switch in and out of preview to edit the scene. That's not convenient, is it?"),
			gtr("We can split the view into two to see both simultaneously!"),
			gtr("To split the view, click the [b]View[/b] button in the toolbar and select one of the options."),
			gtr('Go ahead and split the view into two viewports vertically. In the View menu, the option is "2 Viewports (Alt)". You can also press [b]%s+Alt+2[/b] on your keyboard.' % shortcuts.ctrl)
		]
	)
	bubble_add_task(
		"Split the view into two vertical viewports",
		1,
		func split_view_in_two_task(_task: Task) -> int:
			var view_popup := interface.spatial_editor_toolbar_view_menu_button.get_popup()
			return 1 if view_popup.is_item_checked(2) else 0
	)
	highlight_controls([interface.spatial_editor_toolbar_view_menu_button])
	complete_step()

	bubble_set_title(gtr("Working with two views"))
	bubble_add_text(
		[
			gtr("Notice how the view is now split into two viewports. The left viewport shows the camera preview, and the right viewport shows the free view."),
			gtr("In the free view, you can move the camera around and see the scene from different angles."),
			gtr("Try moving and turning the camera with the %s Move Mode (%s) and the %s Rotate Mode (%s) to see the camera preview update in real-time.") % [bbcode_generate_icon_image_by_name("ToolMove"), shortcuts.move_mode, bbcode_generate_icon_image_by_name("ToolRotate"), shortcuts.rotate_mode],
		]
	)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Run the scene"))
	bubble_add_text(
		[
			gtr("Press [b]%s[/b] to play the scene again. You should see the player character and the platforms, with a pretty dark scene and a gray sky. Press [b]%s[/b] to close the running game.") % [shortcuts.run_current, shortcuts.stop]
		]
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	bubble_set_title(gtr("In 3D, you need light"))
	bubble_add_text(
		[
			gtr("A 3D game is composed of 3D geometry shaded by [b]materials[/b] and [b]light[/b]."),
			gtr("Our scene has 3D geometry and materials predefined, but currently, it does not have light."),
			gtr("It looks fine in the viewport because Godot provides default lighting to help us prototype scenes until we add our own lights."),
		]
	)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Turn off the default lights"))
	bubble_add_text(
		[
			gtr("To see the scene in the viewport as it looks in the game, we need to turn off the default lights."),
			gtr("In the toolbar, click the %s [b]Toggle preview sunlight[/b] and %s [b]Toggle preview environment[/b] buttons to turn off the default lights.") % [bbcode_generate_icon_image_by_name("PreviewSun"), bbcode_generate_icon_image_by_name("PreviewEnvironment")],
			gtr("The viewport should become dark and gray, as in the game.")
		]
	)
	highlight_controls([interface.spatial_editor_toolbar_sun_button, interface.spatial_editor_toolbar_environment_button])
	bubble_add_task(
		"Turn off the sun and environment preview",
		1,
		func preview_sun_off_task(_task: Task) -> int: return (
			0 if interface.spatial_editor_toolbar_sun_button.button_pressed or interface.spatial_editor_toolbar_environment_button.button_pressed else 1
		)
	)
	complete_step()

	bubble_set_title(gtr("The most common light types"))
	bubble_add_text(
		[
			gtr("Godot has three nodes representing different types of lights:"),
			"[ol]" + gtr("The [b]OmniLight3D[/b] simulates light bulbs. It lights a spherical area.\n") +
			gtr("The [b]SpotLight3D[/b] simulates a flashlight or spotlight. It illuminates a cone-shaped area.\n") +
			gtr("The [b]DirectionalLight3D[/b] node simulates the sun. It applies uniform directional lighting to the entire scene.\n") + "[/ol]",
			gtr("As our scene is an exterior, we will add a [b]DirectionalLight3D[/b] node to simulate sunlight."),
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	complete_step()

	bubble_set_title(gtr("Add a directional light"))
	bubble_add_text(
		[
			gtr("Select the [b]Game[/b] node in the Scene dock and add a [b]DirectionalLight3D[/b] node as a child of it."),
			gtr("You can press [b]%s+A[/b] on your keyboard to open the Add Node dialog. Search for the [b]DirectionalLight3D[/b] node and create it in the scene.") % shortcuts.ctrl
		]
	)
	bubble_add_task(
		"Add a [b]DirectionalLight3D[/b] node to the scene",
		1,
		func add_directional_light_as_child_of_game_task(_task: Task) -> int:
			var directional_light := get_scene_node_by_path(GAME_DIRECTIONAL_LIGHT_PATH)
			return 1 if directional_light != null else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	highlight_scene_nodes_by_path(["Game"], -1, false)
	highlight_controls([interface.scene_dock_button_add], true)
	complete_step()

	bubble_set_title(gtr("The directional light"))
	bubble_add_text(
		[
			gtr("At first, the light is aligned with the ground plane so it does not illuminate the floor. It illuminates the character from the front."),
			gtr("We'll rotate the light to angle it down and light up the character and the ground."),
			gtr("First, hover the right viewport with the mouse and focus the directional light by pressing the [b]%s[/b] key. This will center the view on the light.") % shortcuts.focus
		]
	)
	bubble_add_task_focus_node(GAME_DIRECTIONAL_LIGHT_PATH.get_file())
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	highlight_scene_nodes_by_path([GAME_DIRECTIONAL_LIGHT_PATH])
	complete_step()

	bubble_set_title(gtr("Activate the Rotate mode"))
	bubble_add_text(
		[
			gtr("We can use the [b]Rotate Mode[/b] in the toolbar to rotate the light. Click the icon or press [b]%s[/b] on your keyboard to activate the [b]Rotate Mode[/b].") % shortcuts.rotate_mode
		]
	)
	bubble_add_task_toggle_button(
		interface.spatial_editor_toolbar_rotate_button,
		true,
		"Turn the [b]Rotate Mode[/b] button ON."
	)
	highlight_controls([interface.spatial_editor_toolbar_rotate_button])
	complete_step()

	bubble_set_title(gtr("The rotation manipulator"))
	bubble_add_text(
		[
			gtr("We used the rotation manipulator before with the camera. It has has three circles representing the rotations you can perform: you can turn the selected node around the [b]x[/b], [b]y[/b], and [b]z[/b] axes."),
			gtr("Left click and drag on any of these three circles to rotate the light around the corresponding axis."),
			gtr("Left clicking and dragging anywhere else in the viewport will rotate the light parallel to the view's forward axis.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	complete_step()

	bubble_set_title(gtr("Rotate the directional light"))
	bubble_add_text(
		[
			gtr("The light direction is represented by the white wire arrow that's aligned with the ground plane by default."),
			gtr("Rotate the light by clicking and dragging on the red circle to rotate it around the [b]x[/b]-axis and angle it down."),
			gtr("If you still have the two viewports active, you should see the character and the ground get lit uniformly from above.")
		]
	)
	bubble_add_task(
		"Rotate the light to angle it down",
		1,
		func rotate_directional_light_task(_task: Task) -> int:
			var directional_light: DirectionalLight3D = get_scene_node_by_path(GAME_DIRECTIONAL_LIGHT_PATH)
			return 1 if directional_light.global_rotation.x < 0 else 0
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_add_video(preload("../assets/video_rotate_directional_light.ogv"))
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("To shade or not to shade"))
	bubble_add_text(
		[
			gtr("Notice how the player character does not cast a shadow in the camera preview on the left."),
			gtr("By default, lights in 3D games do not cast shadows because shadows have a rendering cost. Having too many shadow-casting lights can slow down the game, but having none doesn't give the visuals enough depth."),
			gtr("Let's see how to activate shadows on our [b]DirectionalLight3D[/b] to make it cast shadows in the game."),
		]
	)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Enable shadows on the directional light"))
	bubble_add_text(
		[
			gtr("Make sure you have the [b]DirectionalLight3D[/b] node selected. Then, in the [b]Inspector[/b], turn on the [b]Enable[/b] property highlighted in the [b]Shadow[/b] category. Shadows will appear behind the character and the flag."),
			gtr("There are a bunch of settings to tweak the quality and range of the shadows, but we'll learn all about that later in the course."),
		]
	)
	bubble_add_task(
		"Enable shadows on the [b]DirectionalLight3D[/b] node",
		1,
		func _enable_light_shadows_task(_task: Task) -> int:
			var directional_light: DirectionalLight3D = get_scene_node_by_path(GAME_DIRECTIONAL_LIGHT_PATH)
			return 1 if directional_light.shadow_enabled else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_RIGHT)
	scene_select_nodes_by_path([GAME_DIRECTIONAL_LIGHT_PATH])
	highlight_inspector_properties(["shadow_enabled"])
	complete_step()

	bubble_set_title(gtr("Run the scene"))
	bubble_add_text(
		[
			gtr("Run the scene again with [b]%s[/b] to see that the character is lit and casts a shadow on the ground. The game should look slightly better now.") % shortcuts.run_current,
			gtr("Press [b]%s[/b] to close the running game.") % shortcuts.stop,
			gtr("The scene still lacks a sky. We'll add one next.")
		]
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	bubble_set_title(gtr("The world environment"))
	bubble_add_text(
		[
			gtr("While we added a directional light, we still have lots of shaded areas in our level, and the background is all gray."),
			gtr("To control the background, we can use a [b]WorldEnvironment[/b] node. This node takes an [b]Environment[/b] resource and lets us define what the sky should look like. It also controls post-processing effects built into Godot, like fog, contrast, and more."),
			gtr("We won't create an environment from scratch now; we'll learn how to do that later in the course. For now, we'll use one I've prepared for you.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	complete_step()

	bubble_set_title(gtr("Add a WorldEnvironment node"))
	bubble_add_text(
		[
			gtr("Let's add a [b]WorldEnvironment[/b] node to the scene."),
			gtr("Select the [b]Game[/b] node in the Scene dock and add a new [b]WorldEnvironment[/b] node as a child of it. This node alone does nothing; it needs an [b]Environment[/b] resource to work."),
			gtr("We'll add it in the next step.")
		]
	)
	bubble_add_task(
		"Add a [b]WorldEnvironment[/b] node to the scene",
		1,
		func add_world_environment_as_child_of_game_task(_task: Task) -> int:
			var world_environment := get_scene_node_by_path(GAME_WORLD_ENVIRONMENT_PATH)
			return 1 if world_environment != null else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes_by_path(["Game"], -1, false)
	highlight_controls([interface.scene_dock_button_add], true)
	complete_step()

	bubble_set_title(gtr("Add the environment resource"))
	bubble_add_text(
		[
			gtr("With the [b]WorldEnvironment[/b] node selected, click and drag the [b]world_environment.tres[/b] file from the [b]FileSystem[/b] dock onto the [b]Environment[/b] property in the [b]Inspector[/b]."),
			gtr("It's an environment I've prepared for you. It has a soft purple sky and uses the fog effect to give the platforms depth.")
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	highlight_filesystem_paths([PATH_WORLD_ENVIRONMENT_TRES])
	scene_select_nodes_by_path([GAME_WORLD_ENVIRONMENT_PATH])
	highlight_inspector_properties(["environment"])
	bubble_add_task_set_node_property(
		GAME_WORLD_ENVIRONMENT_PATH.get_file(), "environment", RESOURCES.world_environment,
		"Set the [b]Environment[/b] property to [b]%s[/b]" % PATH_WORLD_ENVIRONMENT_TRES.get_file()
	)
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, PATH_WORLD_ENVIRONMENT_TRES),
		get_inspector_property_center.bind("environment")
	)
	complete_step()

	bubble_set_title(gtr("The ambient lighting"))
	bubble_add_text(
		[
			gtr("The sky brightens the scene and gives it a more appealing look. It uses a simple, uniform light that comes from all directions, called [b]ambient lighting[/b]."),
			gtr("It's a very efficient and performance-friendly way to light a scene. It also works great for stylized visuals, like the style we're going for in this course.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Expand the ambient light"))
	bubble_add_text(
		[
			gtr("Let's see how it works in the [b]Inspector[/b] dock. With the [b]WorldEnvironment[/b] node selected, in the Inspector, click on the [b]world_environment.tres[/b] resource to expand its properties. Then, expand the [b]Ambient Light[/b] category."),
			gtr("It reveals four properties: [b]Source[/b], [b]Color[/b], [b]Sky Contribution[/b], and [b]Energy[/b]."),
			gtr("The source of the ambient light is the purple sky, and it contributes to the scene's lighting. The sky colors are mixed with the [b]Color[/b] property based on the [b]Sky Contribution[/b] value. The [b]Energy[/b] property controls the intensity of the ambient light.")
		]
	)
	scene_select_nodes_by_path([GAME_WORLD_ENVIRONMENT_PATH])
	highlight_controls([interface.inspector_editor])
	complete_step()

	bubble_set_title(gtr("Tweak the ambient light"))
	bubble_add_text(
		[
			gtr("Take a moment to play with these properties and see how they affect the scene."),
			gtr("The [b]Color[/b] property is particularly fun to tweak! It tints all the platforms and the character with the color you choose."),
			gtr("Note that the Color property won't do anything if [b]Sky Contribution[/b] is set to [b]1.0[/b]. You need to lower the sky's contribution to see the effect.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	scene_select_nodes_by_path([GAME_WORLD_ENVIRONMENT_PATH])
	highlight_controls([interface.inspector_editor, interface.spatial_editor])
	complete_step()

	bubble_set_background(RESOURCES.bubble_background)
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.5))
	bubble_add_texture(RESOURCES.gdquest_logo, 80.0)
	bubble_set_title("")
	bubble_add_text(
		[
			gtr("That's it for this first tour! You've learned to navigate the 3D view, move and rotate nodes, and add light to a 3D scene."),
			gtr("You've also seen how 3D games require a camera and light to work and look good. It's just like capturing a video in real life: you need a camera and lights."),
			gtr("In the next few tours, we'll explore 3D geometry, materials, and the similarities and differences between 2D and 3D games.")
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	complete_step()
