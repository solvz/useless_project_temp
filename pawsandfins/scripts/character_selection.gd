extends Control

@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
var selected_character_type = CharacterManager.CharacterType.BLACK_CAT
var character_buttons = []

func _ready():
	create_character_buttons()

func create_character_buttons():
	var character_types = CharacterManager.get_all_character_types()
	
	for i in range(character_types.size()):
		var character_type = character_types[i]
		var button = create_character_button(character_type)
		grid_container.add_child(button)
		character_buttons.append(button)
		
		# Add spacing between buttons (except after the last one)
		if i < character_types.size() - 1:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 20)
			grid_container.add_child(spacer)
	
	# Select the first character by default
	if character_buttons.size() > 0:
		select_character(CharacterManager.CharacterType.BLACK_CAT)

func create_character_button(character_type: CharacterManager.CharacterType) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(400, 80)
	button.toggle_mode = true
	var button_group = preload("res://scripts/character_button_group.tres")
	button.button_group = button_group
	
	# Create an HBoxContainer for horizontal layout
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 20)
	button.add_child(hbox)
	
	# Add character sprite on the left
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(64, 64)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Load the idle sprite for preview - extract just the first frame
	var sprite_path = CharacterManager.get_idle_sprite_path(character_type)
	var texture = null
	if ResourceLoader.exists(sprite_path):
		var source_texture = load(sprite_path)
		if source_texture:
			# Create an AtlasTexture to show only the first frame (static preview)
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = source_texture
			# Assuming 32x32 frame size, extract the first frame
			atlas_texture.region = Rect2(0, 0, 32, 32)
			texture = atlas_texture
	
	if texture:
		texture_rect.texture = texture
	else:
		print("Warning: Could not load texture at path: ", sprite_path)
	
	hbox.add_child(texture_rect)
	
	# Add character name on the right
	var label = Label.new()
	label.text = CharacterManager.get_character_name(character_type)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 24)
	hbox.add_child(label)
	
	# Connect the button press
	button.pressed.connect(_on_character_button_pressed.bind(character_type, button))
	
	return button

func _on_character_button_pressed(character_type: CharacterManager.CharacterType, button: Button):
	select_character(character_type)

func select_character(character_type: CharacterManager.CharacterType):
	selected_character_type = character_type
	CharacterManager.set_selected_character(character_type)
	
	# Update button states
	for i in range(character_buttons.size()):
		var button = character_buttons[i]
		var button_character_type = CharacterManager.get_all_character_types()[i]
		button.button_pressed = (button_character_type == character_type)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
