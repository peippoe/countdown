extends Node3D

@export var COINS: Vector2i = Vector2i.ZERO



func _ready() -> void:
	get_parent().died.connect(on_died)

func on_died():
	var new_health_drop = load("res://Objects/health_drop.tscn").instantiate()
	get_tree().root.get_node("Main/World").add_child(new_health_drop)
	new_health_drop.global_position = global_position
	
	
	GameManager.coins += randi_range(COINS.x, COINS.y)
