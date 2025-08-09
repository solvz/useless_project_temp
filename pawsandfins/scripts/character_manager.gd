extends Node

# Character types available
enum CharacterType {
	BLACK_CAT,
	BROWN_CAT,
	SIAMESE_CAT
}

# Currently selected character
var selected_character: CharacterType = CharacterType.BLACK_CAT

# Character data with their sprite paths
var character_data = {
	CharacterType.BLACK_CAT: {
		"name": "Black Cat",
		"idle_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BlackCat/PNG/IdleCatb.png",
		"run_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BlackCat/PNG/RunCatb.png",
		"jump_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BlackCat/PNG/JumpCabt.png",
		"attack_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BlackCat/PNG/AttackCatb.png",
		"sleep_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BlackCat/PNG/SleepCatb.png"
	},
	CharacterType.BROWN_CAT: {
		"name": "Brown Cat",
		"idle_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BrownCat/IdleCattt.png",
		"run_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BrownCat/RunCattt.png",
		"jump_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BrownCat/JumpCatttt.png",
		"attack_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BrownCat/AttackCattt.png",
		"sleep_sprite": "res://assets/sprites/Player/AnimalPack/Cats/BrownCat/SleepCattt.png"
	},
	CharacterType.SIAMESE_CAT: {
		"name": "Siamese Cat",
		"idle_sprite": "res://assets/sprites/Player/AnimalPack/Cats/Siamese/PNG/IdleCattt.png",
		"run_sprite": "res://assets/sprites/Player/AnimalPack/Cats/Siamese/PNG/RunCattt.png",
		"jump_sprite": "res://assets/sprites/Player/AnimalPack/Cats/Siamese/PNG/JumpCatttt.png",
		"attack_sprite": "res://assets/sprites/Player/AnimalPack/Cats/Siamese/PNG/AttackCattt.png",
		"sleep_sprite": "res://assets/sprites/Player/AnimalPack/Cats/Siamese/PNG/SleepCattt.png"
	}
}

func get_character_name(character_type: CharacterType) -> String:
	return character_data[character_type]["name"]

func get_idle_sprite_path(character_type: CharacterType = selected_character) -> String:
	return character_data[character_type]["idle_sprite"]

func get_run_sprite_path(character_type: CharacterType = selected_character) -> String:
	return character_data[character_type]["run_sprite"]

func get_jump_sprite_path(character_type: CharacterType = selected_character) -> String:
	return character_data[character_type]["jump_sprite"]

func get_attack_sprite_path(character_type: CharacterType = selected_character) -> String:
	return character_data[character_type]["attack_sprite"]

func get_sleep_sprite_path(character_type: CharacterType = selected_character) -> String:
	return character_data[character_type]["sleep_sprite"]

func set_selected_character(character_type: CharacterType):
	selected_character = character_type

func get_all_character_types() -> Array:
	return character_data.keys()

func get_next_character_type() -> CharacterType:
	var character_types = get_all_character_types()
	var current_index = character_types.find(selected_character)
	var next_index = (current_index + 1) % character_types.size()
	return character_types[next_index]

func get_previous_character_type() -> CharacterType:
	var character_types = get_all_character_types()
	var current_index = character_types.find(selected_character)
	var prev_index = (current_index - 1) % character_types.size()
	if prev_index < 0:
		prev_index = character_types.size() - 1
	return character_types[prev_index]

func switch_to_next_character():
	var next_character = get_next_character_type()
	set_selected_character(next_character)
	return next_character

func switch_to_previous_character():
	var prev_character = get_previous_character_type()
	set_selected_character(prev_character)
	return prev_character
