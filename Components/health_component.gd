extends Area3D


@export var max_health = 100
var health = max_health

signal died
func change_health(change):
	health += change
	
	if health <= 0:
		died.emit()
		on_died()
		get_parent().call_deferred("queue_free")

func on_died():
	Util.play_sound("res://pew.mp3", null, Vector2(0.5, 0.6))
