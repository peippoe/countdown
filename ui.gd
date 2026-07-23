extends Control


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape") and !$LoseScreen.visible:
		
		var toggled = !$PauseScreen.visible
		if toggled:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$PauseScreen.visible = true
			get_tree().paused = true
			$PauseScreen/VBoxContainer/HBoxContainer/LineEdit.text = str(GameManager.sensitivity)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$PauseScreen.visible = false
			get_tree().paused = false



func _on_line_edit_text_submitted(new_text: String) -> void:
	GameManager.sensitivity = float(new_text)


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
