extends Area2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	print("Something entered:", body.name, " Type:", body.get_class())

	if body is CharacterBody2D:
		print("Player touched me!")
		queue_free()


func _on_life_timer_timeout() -> void:
	queue_free() # R queue_free()eplace with function body.
