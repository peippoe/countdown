extends Control


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape") and !$LoseScreen.visible:
		
		$PauseScreen.visible = !$PauseScreen.visible
		if $PauseScreen.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
