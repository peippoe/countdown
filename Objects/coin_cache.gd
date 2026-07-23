extends Node3D


func interact():
	print("MONEYYYYYY")
	GameManager.coins += randi_range(10, 50)
	queue_free()
