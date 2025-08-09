extends CharacterBody2D

func _ready():
	# Display a message about how to wake up
	var label = Label.new()
	label.text = "Press any key to wake up!\nClick 'Back to Game' to return"
	label.position = Vector2(-100, -80)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	# Add a button to return to game
	var button = Button.new()
	button.text = "Back to Game"
	button.position = Vector2(-50, 40)
	button.size = Vector2(100, 30)
	button.pressed.connect(_on_wake_up_pressed)
	add_child(button)

func _input(event):
	if event is InputEventKey and event.pressed:
		wake_up()

func _on_wake_up_pressed():
	wake_up()

func wake_up():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
