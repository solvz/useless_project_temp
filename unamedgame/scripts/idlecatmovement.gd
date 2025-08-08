extends CharacterBody2D

const SPEED = 200
var fish_counter=0
@onready var fish_label = %Label
@onready var animated_sprite = $AnimatedSprite2D
@onready var character_label = %CharacterInfo/CharacterLabel

func _ready():
	setup_character_sprites()
	update_character_label()

func setup_character_sprites():
	# Get the current character's idle sprite
	var idle_sprite_path = CharacterManager.get_idle_sprite_path()
	var idle_texture = null
	
	if ResourceLoader.exists(idle_sprite_path):
		idle_texture = load(idle_sprite_path)
	else:
		print("Warning: Could not find sprite at path: ", idle_sprite_path)
		return
	
	# Clear existing animations
	var sprite_frames = SpriteFrames.new()
	
	# Create idle animation
	var idle_frames = []
	
	# Check if the texture is a sprite sheet (has multiple frames)
	if idle_texture:
		var texture_width = idle_texture.get_width()
		var texture_height = idle_texture.get_height()
		var frame_width = 32  # Assuming 32x32 frames
		var frame_height = 32
		var frames_per_row = texture_width / frame_width
		var total_frames = min(7, frames_per_row)  # Max 7 frames for idle animation
		
		for i in range(total_frames):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = idle_texture
			atlas_texture.region = Rect2(i * frame_width, 0, frame_width, frame_height)
			idle_frames.append(atlas_texture)
	
	# Add idle animation to sprite frames
	sprite_frames.add_animation("idle")
	for frame in idle_frames:
		sprite_frames.add_frame("idle", frame)
	sprite_frames.set_animation_speed("idle", 10.0)
	sprite_frames.set_animation_loop("idle", true)
	
	# Apply the new sprite frames
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	# Handle character switching
	if Input.is_action_just_pressed("switch_character_next"):
		CharacterManager.switch_to_next_character()
		setup_character_sprites()
		update_character_label()
		print("Switched to: ", CharacterManager.get_character_name(CharacterManager.selected_character))
	elif Input.is_action_just_pressed("switch_character_prev"):
		CharacterManager.switch_to_previous_character()
		setup_character_sprites()
		update_character_label()
		print("Switched to: ", CharacterManager.get_character_name(CharacterManager.selected_character))
	
	var input_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = input_direction * SPEED
	move_and_slide()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("fish"):
		set_fish(fish_counter+1)
		print(fish_counter)
	
func set_fish(new_fish_count: int) -> void:
	fish_counter = new_fish_count
	fish_label.text = "Fish Count: " + str(fish_counter)

func update_character_label():
	if character_label:
		character_label.text = "Character: " + CharacterManager.get_character_name(CharacterManager.selected_character)
