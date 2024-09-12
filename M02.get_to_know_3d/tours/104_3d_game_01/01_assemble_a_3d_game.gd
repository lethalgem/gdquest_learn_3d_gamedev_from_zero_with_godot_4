extends "../104_base.gd"


func _build() -> void:

	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	scene_open(FILESYSTEM_PATHS.game)
	_add_intro_step(
		gtr("104.a. Assemble a 3D game"),
		[
			gtr("In this tour series, you will assemble a 3D game from premade parts."),
			gtr("First we will go over the little demo you will be creating. Then, later in the course, you will learn to code these mechanics and more, yourself."),
			gtr("In this first part of the series, you will find out how to create platforms with [b]CSG boxes[/b], how 3D character controllers are set up, and [b]3D materials[/b]."),
		]
	)

	bubble_set_title(gtr("The game demo"))
	bubble_add_text([
			gtr("I've opened the finished demo scene for you, [b]%s[/b]. Let's get started with a quick overview of what you'll assemble.") % FILESYSTEM_PATHS.game.get_file(),
			gtr("Don't hesitate to rotate the view at any time with the [b]Middle Mouse Button[/b], pan the view with [b]Shift + Middle Mouse Button[/b], and zoom in and out with the [b]Mouse Wheel[/b]."),
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.BOTTOM_LEFT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The player"))
	bubble_add_text(
		[
			gtr("In this demo, we have a player character with a third-person controller. It's made of three parts:"),
			"[ol]" + gtr("The [b]player controller[/b] is a virtual controller that listens to player input and moves the character. It's a physical shape that moves, jumps, and handles collisions. It's the Player3D scene instance in the Scene dock.\n") +
			gtr("The [b]camera rig[/b] is a virtual camera that follows the player. It also has a script that allows the player to rotate the camera. You can find it in the Inspector dock.\n") +
			gtr("The [b]character skin[/b] is the 3D model of the player. It's a robot in this demo. Like the camera rig, you can find it in the Inspector.") + "[/ol]",
			gtr("This composition is typical in 3D games where you could reuse the controller with different character skins. You could reuse the camera rig on a vehicle, for example.")
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.BOTTOM_LEFT)
	spatial_editor_focus_node_by_paths([NODE_PATHS.player])
	highlight_scene_nodes_by_path([NODE_PATHS.player])
	highlight_inspector_properties(["camera_controller_scene", "skin_scene"])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The flag and level end"))
	bubble_add_text(
		[
			gtr("The game has a goal represented by the orange flag that you need to reach. It marks the end of the level. There's a gap between the player and the flag, so when starting the game, the flag is not reachable."),
			gtr("Pan and rotate the view if needed to locate the flag and the gap.")
		]
	)
	spatial_editor_focus_node_by_paths(
		[NODE_PATHS.flag]
	)
	scene_deselect_all_nodes()
	highlight_controls(interface.spatial_editor_surfaces)
	complete_step()

	bubble_set_title(gtr("The platform and lever"))
	bubble_add_text(
		[
			gtr("When the player walks up the terrain, they find a pink stationary platform and a yellow lever. The lever is out of reach, so to activate it, the player needs to aim and shoot at it."),
		]
	)
	spatial_editor_focus_node_by_paths([NODE_PATHS.lever])
	scene_deselect_all_nodes()
	highlight_controls(interface.spatial_editor_surfaces)
	complete_step()

	bubble_set_title(gtr("Select the %s node") % NODE_PATHS.lever.get_file())
	bubble_add_text(
		[
			gtr("Activating the lever turns on the gears and the moving platform and allows the player to cross the gap and reach the end of the level."),
			(
				gtr(
					"We can simulate activating the lever in the editor. First, select the [b]%s[/b] node in the [b]Scene[/b] dock."
				)
				% NODE_PATHS.lever.get_file()
			)
		]
	)
	bubble_add_task_select_nodes_by_path([NODE_PATHS.lever])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	highlight_scene_nodes_by_path([NODE_PATHS.lever])
	complete_step()

	bubble_set_title(gtr("Activate the lever"))
	bubble_add_text(
		[
			gtr("In the Inspector, turn on the [b]Is Active[/b] property of the [b]Lever3D[/b] node. You'll see the lever animate, the gears turn, and the platform move. It's magical!"),
			gtr("To achieve this, we use Godot's [b]Tool Mode[/b], a feature to run any game code we'd like in the editor."),
			gtr("The Tool Mode allows us to preview and test level segments without running the game. We'll learn more about this later in the course.")
		]
	)
	bubble_add_task_set_node_property(NODE_PATHS.lever.get_file(), "is_active", true)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_RIGHT)
	highlight_inspector_properties(["is_active"])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Try it now"))
	bubble_add_text(
		[
			gtr("Try running the game now by clicking the [b]Run Current Scene[/b] button at the top right. You can also press [b]%s[/b] on your keyboard. Then, click on the game window to focus it.") % shortcuts.run_current,
			gtr("Try getting to the flag with these controls:"),
			"[ul]" + gtr("Use the [b]WASD[/b] keys to move the player.\n") +
			gtr("Move the mouse to rotate the camera.\n") +
			gtr("Press the space bar to jump.\n") +
			gtr("Right-click to aim. While aiming, left-click to shoot.") + "[/ul]",
			gtr("To close the game, reach the goal or press [b]%s[/b]. You can also press [b]Esc[/b] to release the mouse cursor from the game window and close it.") % shortcuts.stop
		]
	)
	queue_command(func make_lever_inactive():
		var lever = get_scene_node_by_path(NODE_PATHS.lever)
		if lever != null:
			lever.is_active = false
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	bubble_set_title(gtr("Open the start scene"))
	bubble_add_text(
		[
			gtr("Now that you know what we're trying to achieve, let's start assembling the game ourselves."),
			gtr("Open the [b]start.tscn[/b] scene in the FileSystem dock.")
		]
	)
	bubble_add_task_open_scene(FILESYSTEM_PATHS.start)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.BOTTOM_LEFT)
	highlight_filesystem_paths([FILESYSTEM_PATHS.start])
	complete_step()

	bubble_set_title(gtr("The start scene"))
	bubble_add_text(
		[
			gtr("Apart from light, the scene is empty. You can see in the Scene dock that I only added a directional light and a copy of the world environment for light. You learned how to do that in the previous tour (103: Introduction to 3D in Godot)."),
			gtr("Now, let's start by adding the player.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	highlight_scene_nodes_by_name(["DirectionalLight3D", "WorldEnvironment"])
	highlight_controls(interface.spatial_editor_surfaces)
	complete_step()

	bubble_set_title(gtr("Add the player character controller"))
	bubble_add_text(
		[
			gtr(
				"Click and drag the scene [b]%s[/b] onto the viewport to instantiate it. The scene is a virtual controller without a 3D model or camera."
			) % FILESYSTEM_PATHS.player.get_file(),
			gtr("It's a hidden 3D capsule that listens to player input and moves the character and handles collisions. That's why it's invisible. We will add the character skin shortly."),
			gtr("When you click and drag a 3D scene onto the Viewport, it automatically aligns to collision shapes. In this case, it aligns to the grid you can see in the Viewport by default."),
			gtr("This grid acts as a virtual ground in the editor. It doesn't exist in the running game.")
		]
	)
	bubble_add_task_instantiate_scene(
		FILESYSTEM_PATHS.player,
		NODE_PATHS.player.get_file(),
		NODE_PATHS.game,
		(
			gtr("Click and drag the [b]%s[/b] scene file from the [b]FileSystem[/b] dock onto the viewport"
			)
			% FILESYSTEM_PATHS.player.get_file()
		)
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	highlight_filesystem_paths([FILESYSTEM_PATHS.player])
	highlight_controls(interface.spatial_editor_surfaces)
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.player),
		func() -> Vector2: return interface.spatial_editor.get_global_rect().get_center()
	)
	complete_step()

	bubble_set_title(gtr("Reset the player's position"))
	bubble_add_text(
		[
			gtr("When you drag and drop a scene into the viewport, it's instantiated where you drop it. Now, we want to reset the player's position to the world's origin, [b](0, 0, 0)[/b]."),
			gtr("In the previous tour, we moved the [b]Camera3D[/b] node using the %s Move Mode. To move nodes to precise locations, we can use the [b]Inspector[/b] dock." % bbcode_generate_icon_image_by_name("ToolMove")),
			gtr("Let's set the [b]Position[/b] property of the [b]%s[/b] instance to the world's origin.") % FILESYSTEM_PATHS.player.get_file(),
			gtr("You can find the Position property in the [b]Transform[/b] category in the Inspector."),
			gtr(
				"I already selected the [b]%s[/b] node for you. You can manually set the position in the [b]Inspector[/b] dock to [b](0, 0, 0)[/b] or click the %s loop icon at the right of the Inspector to reset the position."
			) % [NODE_PATHS.player.get_file(), bbcode_generate_icon_image_by_name("Reload")]
		]
	)
	bubble_add_task_set_node_property(NODE_PATHS.player.get_file(), "position", Vector3.ZERO)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_RIGHT)
	scene_select_nodes_by_path([NODE_PATHS.player])
	highlight_inspector_properties(["position"])
	complete_step()

	bubble_set_title(gtr("The separation of concerns"))
	bubble_add_text(
		[
			gtr("In 3D, it's common to separate the virtual controller, the camera rig, and the character skin (the character's 3D model)."),
			gtr("This composition allows gamedevs to easily reuse skins and controller code in the project or across projects."),
			gtr("It's also used to separate concerns and make the code easier to manage. Each component has its own script file, which helps to tackle each component individually instead of mixing all the functionality in a single file."),
			gtr("In this project, the player controller has two properties in the Inspector: [b]Skin Scene[/b] and [b]Camera Controller Scene[/b]. They let us specify the character skin and the camera rig."),
			gtr("Next, we'll add the character's skin.")
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	highlight_inspector_properties(["camera_controller_scene", "skin_scene"])
	complete_step()

	bubble_set_title(gtr("Add the robot skin"))
	bubble_add_text(
		[
			(
				gtr(
					"With the [b]%s[/b] instance selected, drag and drop the [b]%s[/b] scene file from the [b]FileSystem[/b] dock onto the [b]Skin Scene[/b] property in the [b]Inspector[/b] dock."
				)
				% [NODE_PATHS.player.get_file(), FILESYSTEM_PATHS.player_skin.get_file()]),
			gtr("The player script, [b]player_3d.gd[/b], instantiates the skin scene as a child of the player and displays the robot in the viewport. Again, this is thanks to the engine's tool mode, which lets us run game code directly in the editor."),
		]
	)
	bubble_add_task_set_node_property(
		NODE_PATHS.player.get_file(),
		"skin_scene",
		RESOURCES.player_skin,
		gtr("Assign the robot skin to the player character controller")
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	scene_select_nodes_by_path([NODE_PATHS.player])
	highlight_inspector_properties(["skin_scene"])
	highlight_filesystem_paths([FILESYSTEM_PATHS.player_skin])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.player_skin),
		get_inspector_property_center.bind("skin_scene")
	)
	complete_step()

	bubble_set_title(gtr("The robot model"))
	bubble_add_text(
		[
			gtr("You can now see the robot in the viewport."),
			gtr("It's a 3D model created using the open-source 3D creation software Blender. We'll learn to bring 3D models from Blender to Godot later in the course."),
		]
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The robot is not in the scene dock"))
	bubble_add_text([
			gtr("You may be surprised that the skin instance doesn't appear in the Scene dock as a child of the %s node.") % NODE_PATHS.player.get_file(),
			gtr("That's because scenes instantiated in scripts aren't shown or saved in scenes by default. This way, you can see your code's effect in the editor without making unwanted additions to your scene files.")
	])
	highlight_controls([interface.scene_dock])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	complete_step()

	interface.scene_import_settings_window.visibility_changed.connect(
		_on_scene_import_settings_window_visibility_changed
	)
	bubble_set_title(gtr("The robot comes from an imported 3D file"))
	bubble_add_text(
		[
			gtr("The robot skin is a 3D model file imported in Godot. Our artist Tibo exported it as a [b].glb[/b] file, a format that includes the 3D model and animations. It can also include images and other data."),
			gtr("Godot imports 3D model files as scenes you can inherit from, instantiate, and animate."),
			gtr("You can open the import settings window and see all the options by double-clicking the file in the [b]FileSystem[/b] dock.")
		]
	)
	bubble_add_task(
		gtr("Open the import settings for the [b]%s[/b] file" % FILESYSTEM_PATHS.gdbot.get_file()),
		1,
		func gdbot_import_settings(task: Task) -> int: return (
			1
			if (
				task.is_done()
				or (
					interface.scene_import_settings_window.visible
					and interface.scene_import_settings_window.title.ends_with(
						"'%s'" % FILESYSTEM_PATHS.gdbot.get_file()
					)
				)
			)
			else 0
		)
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.CENTER_RIGHT)
	highlight_filesystem_paths([FILESYSTEM_PATHS.gdbot])
	complete_step()

	bubble_set_title(gtr("The advanced import window"))
	bubble_add_text(
		[
			gtr("When you double-click the [b]gdbot.glb[/b] file, the advanced import settings window opens. It lists all the nodes and resources Godot extracts from the 3D file and gives you a preview of the 3D model and animations."),
			gtr("For many 3D models, you don't have to worry about the advanced settings. Actually, we didn't use it for this project. But for more complex files, you can use this window to fine-tune what gets extracted from the file and how, so it's good to know it exists."),
			gtr("Notice that the robot is gray in the window. Most models will come with nicer colors and shading."),
			gtr("We often use a different workflow in GDQuest projects, so we tend to import 3D models without materials. That's why this robot is gray in the import window.")
		]
	)
	highlight_controls([interface.scene_import_settings])
	complete_step()

	bubble_set_title(gtr("Close the import settings"))
	bubble_add_text(
		[
			gtr("Let's close the Advanced Import Settings window and continue with the tour."),
			gtr("You can close the window by clicking the [b]Close[/b] button at the bottom.")
		]
	)
	bubble_add_task(
		gtr("Close the import settings window"),
		1,
		func close_import_settings(task: Task) -> int: return 1 if not interface.scene_import_settings_window.visible else 0
	)
	highlight_controls([interface.scene_import_settings_cancel_button])
	complete_step()

	bubble_set_title(gtr("Add the camera controller"))
	bubble_add_text(
		[
			gtr("The last piece we need to see anything in the running game is a camera."),
			gtr("In the 103 tour, we added a [b]Camera3D[/b] node to the scene. But for the player to control the camera, we need more than that: we code what we call a [b]camera rig[/b]. Like the rigs in movies, it's a virtual camera that follows the player and rotates around it, using code."),
			gtr("We've prepared a scene for the camera rig with code to follow the player controller and rotate around it."),
			gtr(
				"Click and drag the [b]%s[/b] scene onto the [b]Camera Controller Scene[/b] property in the [b]Inspector[/b] dock. The player controller will instantiate the camera rig as a child of it."
			) % [FILESYSTEM_PATHS.camera_controller.get_file()]
		]
	)
	bubble_add_task_set_node_property(
		NODE_PATHS.player.get_file(),
		"camera_controller_scene",
		RESOURCES.camera_controller,
		gtr("Assign the camera controller to the player character controller")
	)
	scene_select_nodes_by_path([NODE_PATHS.player])
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	highlight_inspector_properties(["camera_controller_scene"])
	highlight_filesystem_paths([FILESYSTEM_PATHS.camera_controller])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.camera_controller),
		get_inspector_property_center.bind("camera_controller_scene")
	)
	complete_step()

	bubble_set_title(gtr("Run the scene"))
	bubble_add_text(
		[
			gtr("You can run the scene again by clicking the Play Edited Scene button or pressing [b]%s[/b] on your keyboard.") % shortcuts.run_current,
			gtr("You will see the character fall indefinitely into the fog and fade. Great! It's working as expected."),
			gtr("We currently don't have a physical ground for the character to stand on, which is why it falls into the fog. We'll add that next."
			)
		]
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_RIGHT)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	bubble_set_title(gtr("Adding a platform"))
	bubble_add_text(
		[
			gtr("We often use [b]Constructive Solid Geometry[/b], or [b]CSG[/b] in short, to build a ground for the player to stand on and to prototype game levels."),
			gtr("CSG is 3D geometry we can easily use in the editor to create platforms, carve holes and more. It can also generate collision shapes for us, making it easier to design levels."),
			gtr("Game engines like the Source Engine (the engine behind the critically acclaimed FPS game Half-Life) and the Unreal Engine also use CSG for level design and prototyping.")
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	complete_step()

	bubble_set_title(gtr("Add a CSG box"))
	bubble_add_text(
		[
			gtr("We can create a box shape that will serve as a ground platform for the player."),
			gtr("Select the [b]Game[/b] node and create a new [b]CSGBox3D[/b] node as a child of it. It will create an editable box at the center of the game, at the player's feet."),
			gtr("The box is small by default, so we're going to increase its size.")
		]
	)
	bubble_add_task(
		gtr("Add a [b]CSGBox3D[/b] node as a child of the Game node"),
		1,
		func add_csgbox(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var node := scene_root.get_node_or_null("CSGBox3D")
			return 1 if node != null and node is CSGBox3D else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_LEFT)
	highlight_controls([interface.scene_dock])
	complete_step()

	bubble_set_title(gtr("Turn on grid snapping"))
	bubble_add_text(
		[
			gtr("There's nothing like grid snapping to quickly align and resize the box. It allows us to move and resize nodes in 1-meter increments, work in broad strokes, and align things quickly."),
			gtr("Click the [b]Use Snap[/b] icon in the toolbar at the top of the viewport to turn on grid snapping. You can also press [b]Y[/b] on your keyboard to toggle it."
			)
		]
	)
	bubble_add_task_toggle_button(
		interface.spatial_editor_toolbar_snap_button, true, gtr("Turn on grid snapping")
	)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	highlight_controls([interface.spatial_editor_toolbar_snap_button])
	complete_step()

	bubble_set_title(gtr("Resize the box"))
	bubble_add_text(
		[
			gtr("Click and drag on the orange dots to resize the box. Press the [b]Alt[/b] key while dragging to resize the box symmetrically."),
			gtr("At any point, you can press [b]%s+Z[/b] to undo the last action or [b]%s+Y[/b] to redo it.") % [shortcuts.ctrl, shortcuts.ctrl],
			gtr("Make the box larger, longer, and taller to create a platform for the player to stand on."
			)
		]
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	spatial_editor_focus_node_by_paths([NODE_PATHS.csgbox])
	highlight_controls([interface.spatial_editor, interface.spatial_editor_toolbar_select_button])
	bubble_add_task(
		"Make the box a bit larger and taller",
		1,
		func rotate_directional_light_task(_task: Task) -> int:
			var csg_box: CSGBox3D = get_scene_node_by_path(NODE_PATHS.csgbox)
			var was_resized := (csg_box.size.x > 1.0 or csg_box.size.z > 1.0) and csg_box.size.y > 1.0
			return 1 if was_resized else 0
	)
	complete_step()

	bubble_set_title(gtr("Resize the box using the Inspector"))
	bubble_add_text(
		[
			gtr("Alternatively, you can use the [b]Size[/b] property in the [b]Inspector[/b] dock to change the size of the box. That's what the interactive dots in the viewport do behind the scenes."),
			gtr("Using the [b]Inspector[/b], resize the box to be 10 meters wide, 20 meters tall, and 10 meters deep."),
			gtr("Don't worry if you can't see the player anymore. We'll get to this next."),
		]
	)
	bubble_add_task_set_node_property(
		NODE_PATHS.csgbox.get_file(), "size", Vector3(10.0, 20.0, 10.0)
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	scene_select_nodes_by_path([NODE_PATHS.csgbox])
	highlight_inspector_properties(["size"])
	complete_step()

	bubble_set_title(gtr("Move the platform"))
	bubble_add_text(
		[
			gtr("Great job! Now, let's make sure that the platform is below the player."),
			gtr("Using the move manipulator, move the newly created platform as needed. You can use the move manipulator in the %s Select Mode (%s) or the %s Move Mode (%s).") % [bbcode_generate_icon_image_by_name("ToolSelect"), shortcuts.select_mode, bbcode_generate_icon_image_by_name("ToolMove"), shortcuts.move_mode],
			gtr("To move the platform down, click and drag on the green vertical axis of the move manipulator."),
			gtr("Remember that you can rotate the view with the [b]Middle Mouse Button[/b], move the view with [b]Shift + Middle Mouse Button[/b], and zoom in and out with the [b]Mouse Wheel[/b].")
		]
	)
	var guide_parameters := Guide3DTaskParameters.new(
		NODE_PATHS.csgbox.get_file(),
		Vector3(0.0, -10, 0.0),
	)
	guide_parameters.box_size = Vector3(10.0, 20.0, 10.0)
	bubble_add_task_node_to_guide(guide_parameters)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Run the game"))
	bubble_add_text(
		[
			gtr("Press [b]%s[/b] or click the [b]Run Current Scene[/b] button to run the game.") % shortcuts.run_current,
			gtr("You'll see your character fall through the platform. This is normal! We have yet to activate collisions on our [b]%s[/b] node. So, there's nothing to stop the player from falling through the platform."
			) % NODE_PATHS.csgbox.get_file(),
			gtr("We'll fix that next.")
		]
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	bubble_set_title(gtr("Add collisions to the platform"))
	bubble_add_text(
		[
			gtr("Adding collisions is as simple as turning on a checkbox in the Inspector. With the [b]CSGBox3D[/b] node selected, find the [b]Use Collision[/b] property in the Inspector and turn it on."
			)
		]
	)
	bubble_add_task_set_node_property(
		NODE_PATHS.csgbox.get_file(),
		"use_collision",
		true,
		gtr("Turn on the [b]Use Collision[/b] property in the [b]Inspector[/b]")
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	scene_select_nodes_by_path([NODE_PATHS.csgbox])
	highlight_inspector_properties(["use_collision"])
	complete_step()

	bubble_set_title(gtr("Run the game"))
	bubble_add_text(
		[
			gtr("And that's it! The platform now has static body collisions. Press [b]%s[/b] or click the [b]Run Current Scene[/b] button to run the game again. You'll see that your player now stands on the platform.") % shortcuts.run_current,
			gtr("If you click the game window, you can also move the character and control the camera. The controls are:"),
			"[ul]" + gtr("Use the WASD keys to move the player.\n") +
			gtr("Move the mouse to rotate the camera.\n") +
			gtr("Press the space bar to jump.\n") +
			gtr("Right-click to aim. While aiming, left-click to shoot.") + "[/ul]",
			gtr("You can press [b]Esc[/b] anytime to free the mouse from the game window and press [b]%s[/b] or close the game window to close the running game.") % shortcuts.stop
		]
	)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	bubble_set_background(RESOURCES.bubble_background)
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.5))
	bubble_add_texture(RESOURCES.gdquest_logo, 80.0)
	bubble_set_title("")
	bubble_add_text(
		[
			gtr("You've created your first platform with collisions. Congratulations!"),
			gtr("You learned that:"),
			"[ul]" + gtr("We usually separate the player controller, camera rig, and character skin to separate concerns and reuse code.\n") +
			gtr("You can create 3D geometry to prototype levels with CSG nodes.\n") +
			gtr("You can use grid snapping to align and resize nodes quickly.") + "[/ul]",
			gtr("In the next tour, you'll create your first material and apply it to the platform.")
		]
	)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	complete_step()


func _on_scene_import_settings_window_visibility_changed() -> void:
	var editor_scale := EditorInterface.get_editor_scale()
	if interface.scene_import_settings_window.visible:
		var window_size := Vector2(800, 400)
		if EditorInterface.get_base_control().size.x > 1600:
			window_size = Vector2(960, 540)
		interface.scene_import_settings_window.size = window_size * editor_scale
		interface.scene_import_settings_window.position = Vector2(
			80 * editor_scale,
			EditorInterface.get_base_control().size.y / 2.0 - interface.scene_import_settings_window.size.y / 2.0
		)
