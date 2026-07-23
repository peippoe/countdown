extends Node

@export var COINS: Vector2i = Vector2i.ZERO



func _ready() -> void:
	get_parent().died.connect(on_died)

func on_died():
	GameManager.coins += randi_range(COINS.x, COINS.y)
