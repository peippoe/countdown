extends Node

# settings
var sensitivity: float = 10.0
var master_volume: float = 1.0:
	set(value):
		master_volume = value
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(&"Master"), master_volume)


@onready var coins_label = get_tree().get_first_node_in_group("player").get_node("UI/Coins")
# stats
var time_elapsed: float = 0.0
var coins: int = 0:
	set(value):
		var diff = value - coins
		if sign(diff) == -1:
			print("LOST")
		elif sign(diff) == 1:
			Util.play_sound("res://coinget.mp3", null, Vector2(1.25, 1.3))
		
		if diff:
			coins_label.modulate = Color.YELLOW
			var tween = get_tree().create_tween()
			tween.tween_property(coins_label, "scale", Vector2.ONE*1.1, .06)
			tween.tween_property(coins_label, "scale", Vector2.ONE, .06)
			
			var tween2 = get_tree().create_tween()
			tween2.tween_property(coins_label, "modulate", Color.WHITE, .1)
			
			#tween.tween_callback($Sprite.queue_free)
			
		
		coins = value

func _process(delta: float) -> void:
	time_elapsed += delta
