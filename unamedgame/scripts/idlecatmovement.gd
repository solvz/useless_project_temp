extends CharacterBody2D

const SPEED = 200
var fish_counter=0
@onready var fish_label = %Label


func _physics_process(delta: float) -> void:
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
