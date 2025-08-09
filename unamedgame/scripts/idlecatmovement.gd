extends CharacterBody2D

const SPEED = 200
const SLEEPINESS_THRESHOLD = 10.0  # Seconds of inactivity before sleepiness starts
const SLEEPINESS_FILL_TIME = 5.0   # Seconds to fill the sleepiness bar

var fish_counter = 0
var inactivity_timer = 0.0
var sleepiness_level = 0.0
var awake_time = 0.0
var high_score = 0.0
var is_moving = false
var is_sleeping = false

@onready var fish_label = %Label
@onready var animated_sprite = $AnimatedSprite2D
@onready var character_label = %CharacterInfo/CharacterLabel
@onready var sleepiness_bar = %SleepinessBar
@onready var awake_timer_label = %AwakeTimerLabel
@onready var high_score_label = %HighScoreLabel
@onready var sleep_status_label = %SleepStatusLabel

func _ready():
	setup_character_sprites()
	update_character_label()
	load_high_score()
	update_ui()

func setup_character_sprites():
	# Get the current character's sprites
	var idle_sprite_path = CharacterManager.get_idle_sprite_path()
	var sleep_sprite_path = CharacterManager.get_sleep_sprite_path()
	var idle_texture = null
	var sleep_texture = null
	
	if ResourceLoader.exists(idle_sprite_path):
		idle_texture = load(idle_sprite_path)
	else:
		print("Warning: Could not find idle sprite at path: ", idle_sprite_path)
		return
	
	if ResourceLoader.exists(sleep_sprite_path):
		sleep_texture = load(sleep_sprite_path)
	else:
		print("Warning: Could not find sleep sprite at path: ", sleep_sprite_path)
		return
	
	# Clear existing animations
	var sprite_frames = SpriteFrames.new()
	
	# Create idle animation
	setup_animation(sprite_frames, "idle", idle_texture)
	
	# Create sleep animation
	setup_animation(sprite_frames, "sleep", sleep_texture)
	
	# Apply the new sprite frames
	animated_sprite.sprite_frames = sprite_frames
	if is_sleeping:
		animated_sprite.play("sleep")
	else:
		animated_sprite.play("idle")

func setup_animation(sprite_frames: SpriteFrames, animation_name: String, texture: Texture2D):
	var frames = []
	
	if texture:
		var texture_width = texture.get_width()
		var texture_height = texture.get_height()
		var frame_width = 32  # Assuming 32x32 frames
		var frame_height = 32
		var frames_per_row = texture_width / frame_width
		var total_frames = min(7, frames_per_row)  # Max 7 frames for animation
		
		for i in range(total_frames):
			var atlas_texture = AtlasTexture.new()
			atlas_texture.atlas = texture
			atlas_texture.region = Rect2(i * frame_width, 0, frame_width, frame_height)
			frames.append(atlas_texture)
	
	# Add animation to sprite frames
	sprite_frames.add_animation(animation_name)
	for frame in frames:
		sprite_frames.add_frame(animation_name, frame)
	
	var speed = 3.0 if animation_name == "sleep" else 10.0
	sprite_frames.set_animation_speed(animation_name, speed)
	sprite_frames.set_animation_loop(animation_name, true)

func _physics_process(delta: float) -> void:
	# Update awake time only if not sleeping
	if not is_sleeping:
		awake_time += delta
	
	# Handle wake up input if sleeping
	if is_sleeping:
		if Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").length() > 0 or Input.is_anything_pressed():
			wake_up()
		return
	
	# Handle character switching
	if Input.is_action_just_pressed("switch_character_next"):
		CharacterManager.switch_to_next_character()
		setup_character_sprites()
		update_character_label()
		reset_sleepiness()
		print("Switched to: ", CharacterManager.get_character_name(CharacterManager.selected_character))
	elif Input.is_action_just_pressed("switch_character_prev"):
		CharacterManager.switch_to_previous_character()
		setup_character_sprites()
		update_character_label()
		reset_sleepiness()
		print("Switched to: ", CharacterManager.get_character_name(CharacterManager.selected_character))
	
	var input_direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# Check if player is moving
	is_moving = input_direction.length() > 0
	
	if is_moving:
		# Reset sleepiness when moving
		reset_sleepiness()
		
		# Handle horizontal flipping
		if input_direction.x < 0:
			animated_sprite.flip_h = true
		elif input_direction.x > 0:
			animated_sprite.flip_h = false
	else:
		# Update sleepiness when not moving
		update_sleepiness(delta)
	
	velocity = input_direction * SPEED
	move_and_slide()
	
	# Update UI
	update_ui()
	
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

func _on_exit_button_pressed():
	save_high_score()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func update_sleepiness(delta: float):
	inactivity_timer += delta
	
	if inactivity_timer > SLEEPINESS_THRESHOLD:
		# Start filling sleepiness bar
		sleepiness_level += delta / SLEEPINESS_FILL_TIME
		sleepiness_level = min(sleepiness_level, 1.0)
		
		# If sleepiness bar is full, go to sleep
		if sleepiness_level >= 1.0:
			go_to_sleep()

func reset_sleepiness():
	inactivity_timer = 0.0
	sleepiness_level = 0.0

func go_to_sleep():
	# Save high score before going to sleep
	if awake_time > high_score:
		high_score = awake_time
		save_high_score()
	
	# Enter sleeping state
	is_sleeping = true
	animated_sprite.play("sleep")
	print("Cat is now sleeping! Move or press any key to wake up.")

func wake_up():
	# Reset sleeping state
	is_sleeping = false
	awake_time = 0.0
	reset_sleepiness()
	animated_sprite.play("idle")
	print("Cat woke up! Starting new awake session.")

func update_ui():
	if sleepiness_bar:
		sleepiness_bar.value = sleepiness_level * 100
	if awake_timer_label:
		awake_timer_label.text = "Awake: " + format_time(awake_time)
	if high_score_label:
		high_score_label.text = "Best: " + format_time(high_score)
	if sleep_status_label:
		if is_sleeping:
			sleep_status_label.text = "😴 SLEEPING\nMove to wake up!"
		else:
			sleep_status_label.text = ""

func format_time(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	return "%02d:%02d" % [minutes, seconds]

func load_high_score():
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		if file:
			high_score = file.get_float()
			file.close()
	else:
		high_score = 0.0

func save_high_score():
	var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	if file:
		file.store_float(high_score)
		file.close()
	else:
		print("Error: Could not save high score")
