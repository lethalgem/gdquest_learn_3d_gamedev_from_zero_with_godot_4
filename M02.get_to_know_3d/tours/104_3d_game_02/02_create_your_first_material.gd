extends "../104_base.gd"


func _build() -> void:
	scene_open(FILESYSTEM_PATHS.start)
	_add_intro_step(
		gtr("104.b. Create your first material"),
		[
			gtr("The platform's default gray color makes it look a bit bland. In this tour, you'll learn how to create a [b]material[/b] and apply it to the platform to change its appearance."),
			gtr("Ready? Let's get started!"),
		]
	)

	bubble_set_title(gtr("What materials are"))
	bubble_add_text([
		gtr("Materials define how 3D objects look in a game. They control properties like the color, texture, reflectiveness, and many more aspects of the object's appearance."),
		gtr("Under the hood, they use [b]shader programs[/b]. Shaders are small programs that run on the computer's graphics card which is used to calculate the color of each pixel on the screen, among other things."),
		gtr("Anything drawn in a modern game engine uses shaders under the hood: the background, sprites, 3D geometry, particles, and more.")
	])
	complete_step()

	bubble_set_title(gtr("Create a new material on the CSG box"))
	bubble_add_text(
		[
			gtr("Let's create a new material for the platform."),
			gtr("Select the [b]CSGBox3D[/b] node to reveal its properties in the [b]Inspector[/b] dock. One of the properties you will see is the [b]Material[/b] property. "),
			gtr("Click the <empty> slot next to it and select [b]New StandardMaterial3D[/b] to create a default 3D material."),
			gtr("Upon adding the material, the CSG box turns white. This is because the material is now overriding the default color of the [b]CSGBox3D[/b] node.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	scene_deselect_all_nodes()
	highlight_scene_nodes_by_path([NODE_PATHS.csgbox])
	highlight_inspector_properties(["material"])
	bubble_add_task_select_nodes_by_path([NODE_PATHS.csgbox])
	bubble_add_task(
		gtr("Assign a new [b]StandardMaterial3D[/b] material to the platform"),
		1,
		func assign_material(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
			return 1 if csgbox != null and csgbox.material is StandardMaterial3D else 0
	)
	complete_step()

	bubble_set_title(gtr("The StandardMaterial3D resource"))
	bubble_add_text([
		gtr("[b]StandardMaterial3D[/b] is a type of material built into Godot that gives you many options to style your 3D objects. This includes setting the color, texture, reflectiveness, making the object emit light, and more. It's a good tool for most 3D games."),
	])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Expand the material properties"))
	bubble_add_text(
		[
			gtr("Click on the white sphere that represents the material you just created to expand its properties and reveal all the options it offers. There are many! In this tour, we'll only play with the most common ones: [b]Albedo[/b], [b]Metallic[/b], [b]Roughness[/b], and [b]UV1[/b]."),
			gtr("Many other material properties are situation-specific."),
			gtr("Some, like [b]Subsurface Scattering[/b], are used for realistic skin rendering or effects like wax or marble. Others, like [b]Refraction[/b], are used for glass or water."),
			gtr("We use these properties to simulate realistic materials based on real-world physics knowledge.")
		]
	)
	bubble_add_task_expand_inspector_property("material")
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	highlight_inspector_properties(["material"], false)
	complete_step()

	bubble_set_title(gtr("Change the platform's color"))
	bubble_add_text(
		[
			gtr("I just expanded the [b]Albedo[/b] category of the material for you. Change the [b]Color[/b] property to a color of your choice."),
			gtr("The albedo is the base color of the surface. Changing it tints the 3D object. You'll see it update in real-time in the 3D viewport.")
		]
	)
	bubble_add_task(
		gtr("Change the [b]Color[/b] property"),
		1,
		func change_color(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
			return 1 if csgbox != null and csgbox.material is StandardMaterial3D and not csgbox.material.albedo_color.is_equal_approx(Color.WHITE) else 0
	)
	highlight_inspector_properties(["albedo_color"])
	highlight_controls(interface.spatial_editor_surfaces)
	complete_step()

	bubble_set_title(gtr("Turn off gizmos preview"))
	bubble_add_text(
		[
			gtr("When you select nodes like our [b]CSGBox3D[/b], the viewport draws editor overlays, like the orange dots to resize the box. It also changes the shading of the box to indicate that it's editable."),
			gtr("This kind of editor overlay is commonly called a [b]gizmo[/b] in 3D programs."),
			gtr("The overlay prevents us from clearly seeing the underlying texture and color. So let's turn it off."),
			gtr("Click the [b]Perspective[/b] menu at the top left of the viewport and turn off the [b]View Gizmos[/b] option to hide the gizmos. It's located in the bottom half of the menu.")
		]
	)
	bubble_add_task(
		gtr("Turn OFF the [b]Viewport Menu Button -> View Gizmos[/b] option"),
		1,
		func view_gizmo_off(_task: Task) -> int:
			var popup: PopupMenu = interface.spatial_editor_surfaces_menu_buttons.front().get_popup()
			return 0 if popup.is_item_checked(22) else 1
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	highlight_controls([interface.spatial_editor_surfaces_menu_buttons.front()])
	complete_step()

	bubble_set_title(gtr("Apply a texture to the platform"))
	bubble_add_text(
		[
			gtr("The Albedo category has a Texture property. This texture combines with the [b]Color[/b] property and allows you to apply a pattern or image to the 3D geometry."),
			gtr("We prepared a checkered pattern that you'll find in the [b]FileSystem[/b] dock. Drag the [b]checkboard.png[/b] file from the [b]FileSystem[/b] dock onto the [b]Texture[/b] slot."),
		]
	)
	bubble_add_task(
		gtr("Apply the [b]%s[/b] texture to the platform" % FILESYSTEM_PATHS.checkerboard.get_file()),
		1,
		func change_color(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
			return 1 if csgbox != null and csgbox.material is StandardMaterial3D and csgbox.material.albedo_texture == RESOURCES.checkerboard else 0
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	highlight_filesystem_paths([FILESYSTEM_PATHS.checkerboard])
	highlight_inspector_properties(["albedo_texture"])
	mouse_click_drag_by_callable(
		get_tree_item_center_by_path.bind(interface.filesystem_tree, FILESYSTEM_PATHS.checkerboard),
		get_inspector_property_center.bind("albedo_texture")
	)
	complete_step()

	bubble_set_title(gtr("The texture's effect"))
	bubble_add_text([
		gtr("You should see a large, subtle, checkered pattern drawn on the platform."),
		gtr("Depending on the color you chose for the Albedo property, the checkered pattern drawn on the platform may be more or less visible."),
		gtr("Let's adjust the color to make it stand out more."),
	])
	highlight_controls([interface.spatial_editor])
	bubble_move_and_anchor(interface.inspector_editor, Bubble.At.BOTTOM_RIGHT)
	complete_step()

	bubble_set_title(gtr("Adjust the color"))
	bubble_add_text(
		[
			gtr("Adjust the [b]Color[/b] property. You can try a bright orange or a medium blue, purple, or pink to help the pattern stand out."),
			gtr("Take a moment to pick a color that works for you before moving on.")
		]
	)
	highlight_controls(interface.spatial_editor_surfaces)
	highlight_inspector_properties(["albedo_color"])
	complete_step()

	bubble_set_title(gtr("The UV coordinates"))
	bubble_add_text(
		[
			gtr("By default, the checkered pattern is really large. We should make it smaller to make it feel more natural."),
			gtr("We can control the texture repetition with the 3D geometry's [b]UV coordinates[/b], or UVs, in short."),
			gtr("Because the image is 2D, the computer needs to know how to apply the texture to the 3D geometry. The UVs are coordinates that map the 2D image to the 3D geometry."),
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	complete_step()

	bubble_set_title(gtr("What UVs look like"))
	bubble_add_text(
		[
			gtr("When you visualize UVs, they look like an unwrapped and flattened version of the 3D geometry."),
			gtr("If you've ever created a cube from a sheet of paper by cutting a cross shape and folding it six times, the UVs are like the sheet of paper you cut before assembling the cube."),
			gtr("Here's a picture to help visualize it. The left side shows the UVs of a cube, and the right side shows the cube's geometry:")
		]
	)
	bubble_add_texture(RESOURCES.uv_coordinates, 200.0)
	complete_step()

	bubble_set_title(gtr("How UVS are created"))
	bubble_add_text(
		[
			gtr("For simple geometric shapes like boxes, the computer generates the UV coordinates for us. That's why we can see the checkered pattern drawn on the box."),
			gtr("For more complex 3D models like the robot character, a 3D artist unwraps the 3D geometry using an art program. The program lets them choose where to cut and unwrap."),
			gtr("Let's adjust the UV scale of the material to make the checkered pattern smaller.")
		]
	)
	complete_step()

	bubble_set_title(gtr("Scale the UVs"))
	bubble_add_text(
		[
			gtr("Expand the UV1 category in the inspector and change the [b]Scale[/b] property to [b]4[/b] on all axes. This will make the checkered pattern... smaller!"),
			gtr("The size of the texture is inversely proportional to the UV scale. As you increase the Scale property, the checkered pattern becomes smaller relative to the UV coordinates, so it repeats more on the surface."),
			gtr("It's because what we are scaling is the unwrapped virtual shape. We are making it bigger relative to the texture.")
		]
	)
	bubble_add_task(
		gtr("Change the [b]UV1 -> Scale[/b] property to 4 on all three axes"),
		1,
		func change_color(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
			return 1 if csgbox != null and csgbox.material is StandardMaterial3D and csgbox.material.uv1_scale.is_equal_approx(4.0 * Vector3.ONE) else 0
	)
	highlight_inspector_properties(["uv1_scale"])
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.CENTER_RIGHT)
	complete_step()

	bubble_set_title(gtr("The material preview"))
	bubble_add_text(
		[
			gtr("Notice the material preview in the [b]Inspector[/b]. It shows a sphere with your material applied to it. This preview is useful to see how the material behaves on a rounded surface."),
			gtr("Some properties like [b]Metallic[/b] and [b]Roughness[/b] will be more visible on a sphere than our platform in the viewport. We will tweak those shortly, so keep an eye on the preview.")
		]
	)
	highlight_material_preview()
	complete_step()

	bubble_set_title(gtr("The roughness of a material"))
	bubble_add_text(
		[
			gtr("The [b]Roughness[/b] controls how rough a surface is... right! But what does that mean in practice?"),
			gtr("This slider changes how the surface diffuses light. The higher the roughness, the more uniform and spread-out highlights become over the surface. The lower the roughness, the glossier the surface gets."),
			gtr("Play with the [b]Roughness[/b] slider to see how it changes the shading of the preview sphere and the box in the level. When you lower the value to 0, the box will reflect the sky gradient much more.")
		]
	)
	highlight_material_preview()
	highlight_inspector_properties(["roughness"])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The metalness of a material"))
	bubble_add_text(
		[
			gtr("The [b]Metallic[/b] property controls whether the material is metal or not."),
			gtr("Play with the [b]Metallic[/b] slider to see how it changes the shading of the preview sphere in the Inspector."),
			gtr("Note that I set the [b]Roughness[/b] property to [b]0.2[/b] for this step to make the effect clearer on the preview."),
			gtr("The effect of this property is easier to see in photorealistic scenes.")
		]
	)
	queue_command(func set_roughness() -> void:
		var scene_root := EditorInterface.get_edited_scene_root()
		var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
		if csgbox != null and csgbox.material is StandardMaterial3D:
			csgbox.material.roughness = 0.2
	)
	highlight_material_preview()
	highlight_inspector_properties(["metallic"])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("The specular property"))
	bubble_add_text(
		[
			gtr("Next to the [b]Metallic[/b] property is the [b]Specular[/b] property. It controls how glossy the material is."),
			gtr("I set the [b]Metallic[/b] property to 0.0 in this step. Otherwise, the effect can be difficult to see."),
			gtr("If you increase the [b]Specular[/b] value, you will see the preview sphere get a glossy highlight."),
			gtr("Try turning the view up and down in the viewport with the Middle Mouse Button to view the box from different angles. When you look at the top face at a steep angle, it gets brighter."),
			gtr("We'll learn more about how the material properties interact with one another later in the course."),
		]
	)
	queue_command(func set_roughness() -> void:
		var scene_root := EditorInterface.get_edited_scene_root()
		var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
		if csgbox != null and csgbox.material is StandardMaterial3D:
			csgbox.material.metallic = 0.0
	)
	highlight_material_preview()
	highlight_inspector_properties(["metallic_specular"])
	highlight_controls([interface.spatial_editor])
	complete_step()

	bubble_set_title(gtr("Triplanar mapping"))
	bubble_add_text([
		gtr("There's one more property I really want to show you: [b]Triplanar[/b]. You might have noticed that the checkered pattern stretches on the vertical faces of the platform."),
		gtr("Triplanar mapping is a technique that helps to avoid this kind of stretching."),
		gtr("When you enable it, the texture is projected onto the model from three different directions: the top, the side, and the front. This way, the texture adapts to the geometry's shape."),
		gtr("It's a powerful tool for level design.")
	])
	highlight_inspector_properties(["uv1_triplanar"])
	bubble_add_task(
		gtr("Turn the [b]UV1 -> Triplanar[/b] property ON"),
		1,
		func check_triplanar(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
			return 1 if csgbox != null and csgbox.material is StandardMaterial3D and csgbox.material.uv1_triplanar else 0
	)
	complete_step()

	bubble_set_title(gtr("Reset the UV scale"))
	bubble_add_text(
		[
			gtr("Enabling triplanar mapping also affects the scale of the pattern on the platform because the effect bypasses the box's UV coordinates."),
			gtr("Reset the [b]UV1 -> Scale[/b] property to [b]1[/b] on all three axes to get a more natural pattern size."),
		]
	)
	highlight_inspector_properties(["uv1_scale"])
	bubble_add_task(
		gtr("Change the [b]UV1 -> Scale[/b] property to 1 on all three axes"),
		1,
		func change_color(_task: Task) -> int:
			var scene_root := EditorInterface.get_edited_scene_root()
			var csgbox := scene_root.get_node_or_null(NODE_PATHS.csgbox.get_file())
			return 1 if csgbox != null and csgbox.material is StandardMaterial3D and csgbox.material.uv1_scale.is_equal_approx(Vector3.ONE) else 0
	)
	complete_step()

	bubble_set_title(gtr("Play with the material"))
	bubble_add_text(
		[
			gtr("Take some time to play with the material properties and colors and adjust the platform's material to your liking. You can change the color, UV1 scale, roughness, metallic, and specular properties to create a unique look.")
		]
	)
	bubble_move_and_anchor(interface.spatial_editor, Bubble.At.TOP_RIGHT)
	highlight_controls([interface.spatial_editor, interface.inspector_editor])
	complete_step()

	bubble_set_background(RESOURCES.bubble_background)
	queue_command(func scale_avatar(): bubble.avatar.set_scale_multiplier(1.5))
	bubble_add_texture(RESOURCES.gdquest_logo, 80.0)
	bubble_set_title("")
	bubble_add_text(
		[
			gtr("Now, we are done with the platform. It's time to add... the rest of the game! We'll do that in the next tour."),
			gtr("In this tour, you learned how to:"),
			"[ul]" + gtr("Create a new standard 3D material and apply it to a 3D object.\n") +
			gtr("Change the color of a material.\n") +
			gtr("Apply a texture to 3D geometry.\n") +
			gtr("Adjust the UV scale of the texture on a material.\n") +
			gtr("Change the metallic, roughness, and specular properties.") + "[/ul]",
			gtr("In the next tour, we'll add the flag, the moving platform, and the lever to the scene.")
		]
	)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	complete_step()
