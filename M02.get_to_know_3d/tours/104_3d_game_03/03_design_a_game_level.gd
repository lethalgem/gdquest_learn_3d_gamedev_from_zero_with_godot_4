extends "../104_base.gd"


func _build() -> void:
	scene_open(FILESYSTEM_PATHS.start)
	_add_intro_step(
		gtr("104.c. Design a game level"),
		[
			gtr("So far, we have a player character walking on a single platform... and that's it! The game could be more exciting."),
			gtr("In this tour, you'll assemble a small level and give the player a goal and something to do."),
			gtr("I'll guide you through assembling a little level with a lever and a moving platform. After the tour, you can add more and play with the provided assets.")
		]
	)

	bubble_set_title(gtr("Designing a level"))
	bubble_add_text([
		gtr("When you create a level, the first thing to consider is how to guide the player through it."),
		gtr("You can achieve this by creating corridors and paths that draw the player's eye to landmarks."),
		gtr("Whether it's walls, lights, or platforms, the elements you use should form a visual path that the player can follow easily with the in-game camera."),
		gtr("In this tour, you'll place a flag in the player's line of sight and create a moving platform to take them to the flag.")
	])
	spatial_editor_focus_node_by_paths([NODE_PATHS.player])
	complete_step()

	bubble_set_title(gtr("The premade platforms"))
	bubble_add_text([
		gtr("Look at the [b]%s[/b] folder in the [b]FileSystem[/b] dock. It contains three scenes representing platforms: [b]%s[/b], [b]%s[/b], and [b]%s[/b].") % [FILESYSTEM_PATHS.platforms.replace("res://", ""), FILESYSTEM_PATHS.platform_goal.get_file(), FILESYSTEM_PATHS.platform_short_ramp.get_file(), FILESYSTEM_PATHS.platform_tiny.get_file()]
	])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.BOTTOM_LEFT)
	highlight_filesystem_paths([FILESYSTEM_PATHS.platforms, FILESYSTEM_PATHS.platform_goal, FILESYSTEM_PATHS.platform_short_ramp, FILESYSTEM_PATHS.platform_tiny])
	
	complete_step()

	bubble_set_title(gtr("Add the goal platform"))
	bubble_add_text([
		gtr("Drag and drop [b]%s[/b] onto the [b]Game[/b] node in the [b]Scene[/b] dock to instantiate the scene as a child of the [b]Game[/b] node. This will create the instance at the center of the game world and make it easier to place it.") % FILESYSTEM_PATHS.platform_goal.get_file(),
		gtr("For large pieces like platforms, instantiating nodes in the [b]Scene[/b] dock can be easier than dragging and dropping them into the viewport, as they otherwise try to snap to geometry present in the viewport and can move down into the fog or up into the sky.")
	])
	bubble_add_task_instantiate_scene(
		FILESYSTEM_PATHS.platform_goal, NODE_PATHS.platform_goal.get_file(), NODE_PATHS.game
	)
	highlight_controls([interface.scene_dock])
	highlight_filesystem_paths([FILESYSTEM_PATHS.platform_goal])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.platform_goal),
		get_tree_item_center_by_path.bind(interface.scene_tree, NODE_PATHS.game)
	)
	complete_step()

	bubble_set_title(gtr("Activate Select mode"))
	bubble_add_text([
		gtr("Next, you'll move the platform away from the player's starting position."),
		gtr("Activate the %s [b]Select Mode[/b] if needed by clicking the arrow icon in the toolbar or pressing the [b]%s[/b] key.") % [bbcode_generate_icon_image_by_name("ToolSelect"), shortcuts.select_mode],
		gtr("With this mode active, you can move or rotate any node in the 3D view.")
	])
	bubble_add_task_toggle_button(
		interface.spatial_editor_toolbar_select_button, true, gtr("Activate the [b]Select Mode[/b]")
	)
	highlight_controls([interface.spatial_editor_toolbar_select_button])
	complete_step()

	bubble_set_title(gtr("The platform's position"))
	bubble_add_text([
		gtr("The camera will start behind the game character when you run the scene. The player should see the platform in the distance."),
		gtr("Also, they should not be able to reach the goal with a jump, otherwise, the moving platform we'll add later will be useless."),
	])
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	complete_step()

	bubble_set_title(gtr("Move the platform"))
	bubble_add_text([
		gtr("So, move the platform back and up to the designated area, creating a gap between the starting and goal platforms. You may need to zoom, rotate, or pan the view to see it."),
		gtr("You can test the level anytime by clicking the [b]Run Edited Scene[/b] button at the top right of the editor or pressing [b]%s[/b] on your keyboard.") % shortcuts.run_current,
		gtr("This is the view we're aiming for when running the game:")
	])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_texture(RESOURCES.player_facing_platform, 300.0)
	var guide_parameters := Guide3DTaskParameters.new(
		NODE_PATHS.platform_goal.get_file(),
		Vector3(0.0, 2.0, 23.0),
	)
	guide_parameters.box_size = Vector3(10.0, 23.0, 16.0)
	guide_parameters.box_offset = Vector3(0.0, 4.0 - guide_parameters.box_size.y, guide_parameters.box_size.z) / 2.0
	guide_parameters.position_margin = 0.5
	bubble_add_task_node_to_guide(guide_parameters)
	scene_select_nodes_by_path([NODE_PATHS.platform_goal])
	highlight_controls(interface.spatial_editor_surfaces)
	complete_step()

	bubble_set_title(gtr("Focus the platform"))
	bubble_add_text([
		gtr("At the top of the goal platform, we will place the flag. When the player reaches the flag, they will complete the level."),
		gtr("With the PlatformGoal instance selected in the Scene dock, press the [b]%s[/b] key to focus the platform and move the view to it. This will make placing the flag on top of the platform easier.") % shortcuts.focus
	])
	bubble_add_task_focus_node(NODE_PATHS.platform_goal.get_file())
	highlight_scene_nodes_by_path([NODE_PATHS.platform_goal])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Place the flag"))
	bubble_add_text([
		gtr("Click and drag the scene [b]flag_3d.tscn[/b] from the [b]FileSystem[/b] dock to the center of the platform."),
		gtr("You might need to rotate the view to look at the platform from above. Use the [b]Middle Mouse Button[/b] to do so."),
		gtr("When you click and drag the flag in the game view, it will snap to the platform."),
		gtr("After instantiating the flag, click it in the Scene dock or in the viewport to select it. You can then move it around with the [b]Select Mode[/b] active.")
	])
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.flag.get_file(),
		Vector3(0.0, 4.0, 36.0),
	)
	guide_parameters.box_offset = Vector3(0.0, 2.0, 0.0)
	guide_parameters.box_size = Vector3(1.0, 4.0, 1.0)
	guide_parameters.position_margin = 0.5
	bubble_add_task_node_to_guide(guide_parameters)
	highlight_filesystem_paths([FILESYSTEM_PATHS.flag])
	highlight_controls([interface.spatial_editor, interface.inspector_editor])
	complete_step()

	bubble_set_title(gtr("Focus the player"))
	bubble_add_text([
		gtr("Let's add another platform to guide the player towards the flag. First, select the [b]Player3D[/b] node in the Scene dock and press the [b]%s[/b] key to focus the view back on the player.") % shortcuts.focus,
		gtr("The focus feature is handy when you need to jump to different parts of the game level quickly.")
	])
	bubble_add_task_focus_node(NODE_PATHS.player.get_file())
	highlight_scene_nodes_by_path([NODE_PATHS.player])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Add a platform with a ramp"))
	bubble_add_text([
		gtr("In the [b]level/platforms[/b] folder, you'll find a platform with a ramp: [b]%s[/b]. Instantiate it as a child of the [b]%s[/b] node."	% [FILESYSTEM_PATHS.platform_short_ramp.get_file(), NODE_PATHS.game])
	])
	bubble_add_task_instantiate_scene(
		FILESYSTEM_PATHS.platform_short_ramp,
		NODE_PATHS.platform_short_ramp.get_file(),
		NODE_PATHS.game
	)
	highlight_filesystem_paths([FILESYSTEM_PATHS.platform_short_ramp])
	highlight_controls([interface.scene_dock])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.platform_short_ramp),
		get_tree_item_center_by_path.bind(interface.scene_tree, NODE_PATHS.game)
	)
	complete_step()

	bubble_set_title(gtr("Move the platform"))
	bubble_add_text([
		gtr("Using the [b]Select Mode[/b] (%s), move [b]%s[/b] to touch the edge of the starting platform in front of the player. The ramp should invite the player to move forward and up.") % [shortcuts.select_mode, NODE_PATHS.platform_short_ramp.get_file()]
	])
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.platform_short_ramp.get_file(),
		5.0 * Vector3.BACK,
	)
	guide_parameters.box_size = Vector3(4.0, 21.0, 7.0)
	guide_parameters.box_offset = Vector3(0.0, 2.0 - guide_parameters.box_size.y / 2.0, guide_parameters.box_size.z / 2.0)
	bubble_add_task_node_to_guide(guide_parameters)
	scene_select_nodes_by_path([NODE_PATHS.platform_short_ramp])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Moving the flag and platform back"))
	bubble_add_text([
		gtr("When designing levels, you constantly need to adjust the position of elements to guide the player."),
		gtr("Let's say that we find the flag to be too close to the player's starting position. Let's move it back to give the player a better view of the goal."),
	])
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	complete_step()

	bubble_set_title(gtr("Change to the top view"))
	bubble_add_text([
		gtr("Working only from a perspective view can be challenging when you want to select multiple nodes and move them."),
		gtr("The dropdown menu at the top left corner of the viewport allows you to quickly change how you view the scene."),
		gtr("At the top of this menu, you'll see a list of views you can select from: top, bottom, left, right, etc."),
		gtr("You can alternatively press the corresponding keypad numbers to quickly switch the view. If you have a keypad on your computer, press [b]%s[/b] (number 7 on your keypad) to jump to the top view. Otherwise, open the dropdown menu and select [b]Top View[/b].") % shortcuts.top_view
	])
	bubble_add_task(
		gtr("Change the view to the top view"),
		1,
		func camera_top_view(_task: Task) -> int: return (
			1
			if interface.spatial_editor_cameras.front().rotation.is_equal_approx(
				PI / 2.0 * Vector3.LEFT
			)
			else 0
		)
	)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	# NOTE: there's absolutely no way I can see that we can highlight the popup-menu entry
	highlight_controls([interface.spatial_editor_surfaces_menu_buttons.front()])
	complete_step()

	bubble_set_title(gtr("Focus the flag"))
	bubble_add_text([
		gtr("To move the view to the platform and the flag quickly, you can focus the view on the flag instance."),
		gtr("Select the flag in the [b]Scene[/b] dock and, with the mouse cursor over the viewport, press the [b]%s[/b] key to focus the flag.") % shortcuts.focus
	])
	bubble_add_task_focus_node(NODE_PATHS.flag.get_file())
	highlight_scene_nodes_by_path([NODE_PATHS.flag])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Select the platform and the flag"))
	bubble_add_text([
		gtr("You can select platforms and everything placed above them from the top view more easily."),
		gtr("Left-click and drag in the viewport to create a box selection and select everything within it. Make sure your selection covers the platform and the flag."),
		gtr("You can pan the view by holding Shift and dragging the middle mouse button if needed."),
		gtr("If you inadvertently rotate out of the top view, use the menu at the top-left of the viewport or press [b]%s[/b] again to jump back to it.") % shortcuts.top_view
	])
	bubble_add_task_select_nodes_by_path([NODE_PATHS.platform_goal, NODE_PATHS.flag], gtr("Box-select the platform and the flag"))
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Move the platform and the flag"))
	bubble_add_text([
		gtr("When multiple nodes are selected, with the %s [b]Select Mode[/b] active (%s), you can move all selected nodes at once.") % [bbcode_generate_icon_image_by_name("ToolSelect"), shortcuts.select_mode],
		gtr("In the top view, the move manipulator only allows you to move the selection in the XZ plane (you cannot move the selection up and down). It's perfect for assessing gaps."),
		gtr("Move the platform and the flag down to the designated area."),
		gtr("Once you are done, you can use the middle mouse button to rotate the view and change back to the perspective mode.")
	])
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.platform_goal.get_file(),
		Vector3(0.0, 2.0, 28.0),
	)
	guide_parameters.box_size = Vector3(10.0, 23.0, 16.0)
	guide_parameters.box_offset = Vector3(0.0, 4.0 - guide_parameters.box_size.y, guide_parameters.box_size.z) / 2.0
	bubble_add_task_node_to_guide(guide_parameters)

	var guide_parameters_2 := Guide3DTaskParameters.new(
		NODE_PATHS.flag.get_file(),
		Vector3(0.0, 4.0, 41.0),
	)
	guide_parameters_2.box_offset = Vector3(0.0, 2.0, 0.0)
	guide_parameters_2.box_size = Vector3(1.0, 4.0, 1.0)
	bubble_add_task_node_to_guide(guide_parameters_2)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Add a moving platform"))
	bubble_add_text([
		gtr("Next, we want to create a moving platform to cross the gap and take the player from the starting platform to the flag."),
		gtr("For that, instantiate the [b]%s[/b] into the scene as a child of the [b]%s[/b] node.") % [FILESYSTEM_PATHS.moving_platform.get_file(), NODE_PATHS.game],
		gtr("The platform may end up outside the view as Godot will place it at the world's origin, where the player character is. We'll focus the platform and move it to the edge of the platform through which the player will access it next."),
		gtr("You may notice a warning sign next to the [b]MovingPlatform3D[/b] instance in the Scene dock. We'll cover that later. For now, you can hover the icon and read the caption.")
	])
	bubble_add_task_instantiate_scene(
		FILESYSTEM_PATHS.moving_platform, NODE_PATHS.moving_platform.get_file(), NODE_PATHS.game
	)
	highlight_filesystem_paths([FILESYSTEM_PATHS.moving_platform])
	highlight_controls([interface.scene_dock])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.moving_platform),
		get_tree_item_center_by_path.bind(interface.scene_tree, NODE_PATHS.game)
	)
	complete_step()

	bubble_set_title(gtr("Focus the moving platform"))
	bubble_add_text([
		gtr("Let's focus the view on the moving platform to prepare to move it. Select it if needed and press the [b]%s[/b] key with the mouse cursor over the viewport.") % shortcuts.focus
	])
	bubble_add_task_focus_node(NODE_PATHS.moving_platform.get_file())
	highlight_scene_nodes_by_path([NODE_PATHS.moving_platform])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Move the moving platform"))
	bubble_add_text([
		gtr("Now, we want to move the moving platform so it touches the edge of the platform with the short ramp. This will invite the player to step on it and move towards the flag."),
		gtr("When moving an object, with snapping on, press the Shift key to snap to 0.1-meter increments instead of 1 meter. This helps to align objects more precisely without turning off snapping."),
		gtr("You'll need to use the perspective view to move the platform up and down. Use the Middle Mouse Button to rotate the view if you're still in the top view.")
	])
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.moving_platform.get_file(),
		Vector3(0.0, 2.0, 13.5),
	)
	guide_parameters.box_size = Vector3(4.0, 0.4, 3.0)
	guide_parameters.box_offset = 0.2 * Vector3.DOWN
	bubble_add_task_node_to_guide(guide_parameters)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The moving platform's properties"))
	bubble_add_text([
		gtr("With the [b]%s[/b] node selected, look at the properties in the Inspector.") % NODE_PATHS.moving_platform.get_file(),
		gtr("We exported two in the script:"),
		"[ol]" +
		gtr("The [b]Linked Lever[/b]: a reference to a [b]Lever3D[/b] scene instance that will activate the moving platform.\n") +
		gtr("The [b]End Marker[/b]: a [b]Marker3D[/b] node to which the platform will move when active.") + "[/ol]",
		gtr("Both of these properties let you link the moving platform to other nodes in the level scene. It's a powerful way to connect nodes and create interactions between them."),
		gtr("When the player activates the linked lever, the moving platform will be activated and move between its starting position and the end marker.")
	])
	scene_select_nodes_by_path([NODE_PATHS.moving_platform])
	highlight_scene_nodes_by_path([NODE_PATHS.moving_platform])
	highlight_inspector_properties(["linked_lever", "end_marker"])
	complete_step()

	bubble_set_title(gtr("Create a platform for the lever"))
	bubble_add_text([
		gtr("First, let's create a lever to activate the platform. We want it to be inaccessible to the player, so they must shoot at the lever to activate the moving platform."),
		gtr("We've prepared a thin and tall platform to place the lever far enough from the player. Instantiate the scene [b]platform_tiny.tscn[/b] as a child of the [b]Game[/b] node."),
		gtr("Now, toggle the views as needed to place this new platform in the designated area to the left of the gap that separates the starting platform from the flag.")
	])
	bubble_add_task_instantiate_scene(
		FILESYSTEM_PATHS.platform_tiny, NODE_PATHS.platform_tiny.get_file(), NODE_PATHS.game
	)
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.platform_tiny.get_file(),
		Vector3(6.0, -8.5, 20.0),
	)
	guide_parameters.box_size = Vector3(2.0, 21.0, 2.0)
	bubble_add_task_node_to_guide(guide_parameters)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.scene_dock, interface.spatial_editor])
	highlight_filesystem_paths([FILESYSTEM_PATHS.platform_tiny])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.platform_tiny),
		get_tree_item_center_by_path.bind(interface.scene_tree, NODE_PATHS.game)
	)
	complete_step()

	bubble_set_title(gtr("Place the lever"))
	bubble_add_text([
		gtr("Now, place an instance of the scene [b]%s[/b] on the tiny platform. It should be close enough for the player to shoot at when they stand on the moving platform.") % FILESYSTEM_PATHS.lever.get_file(),
		gtr("If you place the lever in the wrong location, you can use the [b]Select Mode[/b] (%s) to move it around.") % shortcuts.select_mode
	])
	bubble_add_task_instantiate_scene(
		FILESYSTEM_PATHS.lever, NODE_PATHS.lever.get_file(), NODE_PATHS.game
	)
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.lever.get_file(),
		Vector3(6.0, 2.0, 20.0),
	)
	guide_parameters.box_offset = Vector3(-0.35, 0.5, 0.0)
	guide_parameters.box_size = Vector3(2.0, 1.0, 0.5)
	bubble_add_task_node_to_guide(guide_parameters)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_filesystem_paths([FILESYSTEM_PATHS.lever])
	highlight_controls([interface.scene_dock, interface.spatial_editor])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.lever),
		get_control_global_center.bind(interface.spatial_editor),
	)
	complete_step()

	bubble_set_title(gtr("Select the moving platform"))
	bubble_add_text([
		gtr("Next, we need to link the moving platform to the lever. It has an exported property called [b]Linked Lever[/b] to which we can assign the lever scene instance."),
		gtr("Select the [b]%s[/b] in the [b]Scene[/b] dock.") % NODE_PATHS.moving_platform.get_file()
	])
	bubble_add_task_select_nodes_by_path([NODE_PATHS.moving_platform])
	highlight_scene_nodes_by_path([NODE_PATHS.moving_platform])
	complete_step()

	bubble_set_title(gtr("Connect the platform and the lever"))
	bubble_add_text([
		gtr("Let's connect the moving platform to the lever. Click the [b]Assign[/b] button next to the [b]Linked Lever[/b] property in the [b]Inspector[/b] dock."),
		gtr("This opens the [b]Select a Node[/b] popup."),
		gtr("In the [b]Select a Node[/b] popup, you can see that only [b]Lever3D[/b] is accessible. Notice the [b]Allowed: Lever3D[/b] label at the top of the window."),
		gtr("Godot filters nodes in the scene based on the property type used in the [b]%s[/b] script. That's another advantage of using type hints in GDScript!") % NODE_PATHS.moving_platform.get_file(),
		gtr("Double-click the [b]%s[/b] node to assign it to the moving platform's [b]Linked Lever[/b] property.") % NODE_PATHS.lever.get_file()
	])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_inspector_properties(["linked_lever"])
	bubble_add_task_set_node_property(
		NODE_PATHS.moving_platform.get_file(), "linked_lever", NODE_PATHS.lever
	)
	complete_step()

	bubble_set_title(gtr("Add the end marker"))
	bubble_add_text([
		gtr("The moving platform needs an end marker to move to. Select the [b]%s[/b] node and add a [b]%s[/b] node as a child of it.") % [NODE_PATHS.game, NODE_PATHS.marker.get_file()],
		gtr("A marker is a simple 3D node with a position, rotation, and scale that also draws a little gizmo in the view.")
	])
	bubble_add_task(
		gtr("Add a [b]%s[/b] as child of the [b]%s[/b] node") % [NODE_PATHS.marker.get_file(), NODE_PATHS.game],
		1,
		func add_marker(_task: Task) -> int:
			var marker := get_scene_node_by_path(NODE_PATHS.marker)
			return 1 if marker != null and marker is Marker3D else 0
	)
	highlight_scene_nodes_by_path([NODE_PATHS.game])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	complete_step()

	bubble_set_title(gtr("Make sure gizmos are turned on"))
	bubble_add_text([
		gtr("In the previous tour, we turned off the [b]View Gizmos[/b] viewport option. But the [b]Marker3D[/b] node uses a gizmo to display its position in the 3D view."),
		gtr("So, we need to re-enable the gizmos.")
	])
	bubble_add_task(
		gtr("Turn ON the [b]Viewport Menu Button -> View Gizmos[/b] option"),
		1,
		func view_gizmo_off(_task: Task) -> int:
			var popup: PopupMenu = interface.spatial_editor_surfaces_menu_buttons.front().get_popup()
			return 1 if popup.is_item_checked(22) else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	highlight_controls([interface.spatial_editor_surfaces_menu_buttons.front()])
	complete_step()

	bubble_set_title(gtr("Move the marker"))
	bubble_add_text([
		gtr("Move the 3D marker to a point in front of the platform the player has to move to. The marker should be floating in front of the platform. This is where the center point of the moving platform will move to when the player activates the lever."),
		gtr("Press the [b]%s[/b] key to focus the view on the marker if needed. You can then move it around with the %s [b]Select Mode[/b] (%s).") % [shortcuts.focus, bbcode_generate_icon_image_by_name("ToolSelect"), shortcuts.select_mode],
		gtr("Press Shift while moving the marker to snap it to 0.1-meter increments.")
	])
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.marker.get_file(),
		Vector3(0.0, 2.0, 27.0),
	)
	guide_parameters.box_size = Vector3.ONE * 2.0
	bubble_add_task_node_to_guide(guide_parameters)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	scene_select_nodes_by_path([NODE_PATHS.marker])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Resize the marker gizmo"))
	bubble_add_text([
		gtr("Let's make the marker gizmo easier to see. In the Inspector, set the [b]Gizmo Extents[/b] to [b]1.0[/b]. This makes the marker lines longer in the viewport.")
	])
	bubble_add_task_set_node_property(NODE_PATHS.marker.get_file(), "gizmo_extents", 1.0)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_RIGHT)
	scene_select_nodes_by_path([NODE_PATHS.marker])
	highlight_inspector_properties(["gizmo_extents"])
	complete_step()

	bubble_set_title(gtr("Select the moving platform"))
	bubble_add_text([
		gtr("Select the [b]%s[/b] scene instance in the [b]Scene[/b] dock once more to assign the end marker to it.") % NODE_PATHS.moving_platform.get_file()
	])
	bubble_add_task_select_nodes_by_path([NODE_PATHS.moving_platform])
	highlight_scene_nodes_by_path([NODE_PATHS.moving_platform])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_LEFT)
	complete_step()

	bubble_set_title(gtr("Assign the end marker"))
	bubble_add_text([
		gtr("Click the [b]Assign[/b] button next to the [b]End Marker[/b] property in the [b]Inspector[/b] dock to open the selection popup. This time, only the [b]Marker3D[/b] node is accessible."),
		gtr("Once again, it's thanks to the use of type hints in the moving platform script: I set the type of the [b]End Marker[/b] property to [b]Marker3D[/b]."),
		gtr("Double-click the [b]Marker3D[/b] node to assign it to the moving platform. Doing so should remove the warning sign next to the [b]%s[/b] instance in the [b]Inspector[/b].") % NODE_PATHS.marker.get_file()
	])
	bubble_add_task_set_node_property(
		NODE_PATHS.moving_platform.get_file(), "end_marker", NODE_PATHS.marker
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	highlight_inspector_properties(["end_marker"])
	complete_step()

	bubble_set_title(gtr("Open the moving platform script"))
	bubble_add_text([
		gtr("Godot has a feature to display warnings in the [b]Inspector[/b] when a node is not configured correctly."),
		gtr("I use this feature to indicate how to configure the [b]%s[/b], a scene I created for you (and that you'll learn to code later).") % NODE_PATHS.moving_platform.get_file(),
		gtr("Open the moving platform script by clicking the Script icon in the [b]Scene[/b] dock."),
	])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	highlight_scene_nodes_by_path([NODE_PATHS.moving_platform])
	bubble_add_task(
		gtr("Open the script attached to the [b]%s[/b] node.") % NODE_PATHS.moving_platform.get_file(),
		1,
		func(task: Task) -> int:
			if not interface.is_in_scripting_context():
				return 0
			var open_script: String = EditorInterface.get_script_editor().get_current_script().resource_path
			return 1 if open_script == FILESYSTEM_PATHS.moving_platform_script else 0
	)
	complete_step()

	bubble_set_title(gtr("The moving platform script"))
	bubble_add_text([
		gtr("In the script editor, you can see the function named [b]_get_configuration_warnings()[/b]."),
		gtr("This is a virtual function built into Godot that you can override in your scripts to display warnings in the [b]Scene[/b] dock."),
		gtr("You will learn how to use it later in the course.")
	])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_scene_nodes_by_path([NODE_PATHS.moving_platform])
	highlight_code(58, 68)
	complete_step()

	bubble_set_title(gtr("Head back to the 3D editor"))
	bubble_add_text([
		gtr("Navigate back to the 3D editor by clicking the 3D button in the toolbar or pressing [b]%s[/b].") % shortcuts.context_3d
	])
	bubble_add_task_toggle_button(interface.context_switcher_3d_button, true, gtr("Return to the 3D view"))
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	highlight_controls([interface.context_switcher_3d_button])
	complete_step()

	bubble_set_title(gtr("The tool mode"))
	bubble_add_text([
		gtr("In this project, we use a Godot feature called [b]Tool Mode[/b] that allows us to run any game code directly in the editor."),
		gtr("Thanks to this feature, we can test the motion of the moving platform without running the game."),
		gtr("The [b]Tool Mode[/b] is active on the lever and the moving platform. Let's see it in action.")
	])
	spatial_editor_focus_node_by_paths([NODE_PATHS.lever, NODE_PATHS.moving_platform])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	complete_step()

	bubble_set_title(gtr("Select the lever"))
	bubble_add_text([
		gtr("First, select the [b]%s[/b] in the [b]Scene[/b] dock to reveal its properties in the [b]Inspector[/b].") % NODE_PATHS.lever.get_file()
	])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_select_nodes_by_path([NODE_PATHS.lever])
	highlight_controls([interface.scene_dock])
	complete_step()

	bubble_set_title(gtr("Activate the lever"))
	bubble_add_text([
		gtr("In the [b]Inspector[/b], turn on the [b]Is Active[/b] property. This will activate the lever, causing it to move and turn yellow. The [b]%s[/b] is linked to the lever, so when you activate it, the platform also changes color and moves.") % NODE_PATHS.moving_platform.get_file()
	])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_add_task_set_node_property(NODE_PATHS.lever.get_file(), "is_active", true)
	scene_select_nodes_by_path([NODE_PATHS.lever])
	highlight_inspector_properties(["is_active"])
	complete_step()

	bubble_set_title(gtr("The moving platform"))
	bubble_add_text([
		gtr("You can see the moving platform move back and forth between its initial position and the marker."),
		gtr("Depending on where you placed the [b]%s[/b] node the platform moves to, you may see the platform move into the ground because the marker is too close to it.") % NODE_PATHS.marker.get_file(),
		gtr("Let's adjust the marker position.")
	])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Select the marker and turn on the Select Mode"))
	bubble_add_text([
		gtr("Select the [b]%s[/b] node in the [b]Scene[/b] dock and turn on the %s [b]Select Mode[/b] if needed. To do so, click the arrow icon in the toolbar or press the [b]%s[/b] key.") % [NODE_PATHS.marker.get_file(), bbcode_generate_icon_image_by_name("ToolSelect"), shortcuts.select_mode]
	])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_select_nodes_by_path([NODE_PATHS.marker])
	bubble_add_task_toggle_button(interface.spatial_editor_toolbar_select_button, true, gtr("Turn on the [b]Select Mode[/b] button ON."))
	highlight_controls([interface.scene_dock, interface.spatial_editor_toolbar_select_button])
	complete_step()

	bubble_set_title(gtr("Adjust the marker position"))
	bubble_add_text([
		gtr("Adjust the position of the marker as needed to prevent the platform from moving into the ground."),
		gtr("You may have noticed that when you moved the marker, the platform paused briefly and then moved to the marker's new position."),
		gtr("This is thanks to the [b]Tool Mode[/b], which allows me to write a small piece of code to restart the platform animation in the editor when the marker moves. It makes level design and testing easier.")
	])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	guide_parameters = Guide3DTaskParameters.new(
		NODE_PATHS.marker.get_file(),
		Vector3(0.0, 2.0, 26.5),
	)
	guide_parameters.box_size = Vector3.ONE * 0.5
	guide_parameters.description_override = gtr("Move the marker to the target location to prevent the platform from moving into the ground")
	bubble_add_task_node_to_guide(guide_parameters)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Deactivate the lever"))
	bubble_add_text([
		gtr("Once you are done placing the platform, reselect the [b]Lever3D[/b] node and turn off the [b]Is Active[/b] property in the Inspector. This will return the moving platform to its original position.")
	])
	bubble_add_task_set_node_property(NODE_PATHS.lever.get_file(), "is_active", false)
	highlight_scene_nodes_by_path([NODE_PATHS.lever])
	highlight_inspector_properties(["is_active"])
	complete_step()

	bubble_set_title(gtr("Run the scene"))
	bubble_add_text([
		gtr("Now, you are ready to test the level you created. Click the [b]Run Current Scene[/b] button at the top right of the editor or press [b]%s[/b] on your keyboard.") % shortcuts.run_current,
		gtr("And have fun! You'll need to shoot at the lever to activate the moving platform. As a reminder, the controls are:"),
		"[ul]" + gtr("Use the [b]WASD[/b] keys to move the player.\n") +
		gtr("Move the mouse to rotate the camera.\n") +
		gtr("Press the space bar to jump.\n") +
		gtr("Right-click to aim. While aiming left-click to shoot.") + "[/ul]",
		gtr("Once you are done, press [b]%s[/b] on your keyboard to close the window.") % shortcuts.stop
	])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_add_task_press_button(interface.run_bar_play_current_button)
	highlight_controls([interface.run_bar_play_current_button])
	complete_step()

	queue_command(interface.bottom_button_output.set_pressed, [false])
	bubble_set_background(RESOURCES.bubble_background)
	bubble_add_texture(RESOURCES.gdquest_logo, 80.0)
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.5))
	bubble_set_title("")
	bubble_add_text([
		gtr("This concludes our intro to 3D. In this last tour, you learned a bit about level design and assembled a little level."),
		gtr("You also got a glimpse of the powerful Tool Mode, editor warnings and exported node properties that allow you to reference nodes."),
		gtr("We'll learn these features in greater detail in the course."),
		gtr("As a fun little challenge, after ending the tour, take a moment to play with your scene and expand your level! You can use everything you learned and build upon it: the [b]CSGBox3D[/b] node, platform scenes, lever, and moving platform."),
		gtr("When you are ready, you can move on to the next module on GDSchool. See you there!")
	])
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	complete_step()
