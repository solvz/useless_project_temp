extends Area2D

@export var respawn_time: float = 5.0 # Seconds before the fish reappears

var start_position: Vector2

func _ready() -> void:
	start_position = position  # Remember where the fish started
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		print("Player touched me!")
		hide()  # Make fish invisible
		$CollisionShape2D.disabled = true  # Disable collisions
		var respawn_timer = Timer.new()
		respawn_timer.wait_time = respawn_time
		respawn_timer.one_shot = true
		add_child(respawn_timer)
		respawn_timer.connect("timeout", Callable(self, "_respawn"))
		respawn_timer.start()

func _respawn() -> void:
	position = start_position
	show()
	$CollisionShape2D.disabled = false
