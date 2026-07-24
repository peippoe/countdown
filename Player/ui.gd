extends Control


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape") and !$LoseScreen.visible:
		
		var toggled = !$PauseScreen.visible
		if toggled:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			$PauseScreen.visible = true
			get_tree().paused = true
			$PauseScreen/VBoxContainer/HBoxContainer/LineEdit.text = str(GameManager.sensitivity)
			
			var vol = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(&"Master"))
			$PauseScreen/VBoxContainer/HBoxContainer2/HSlider.value = vol
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			$PauseScreen.visible = false
			get_tree().paused = false

var current_coins = 0
func _process(delta: float) -> void:
	var m = str(int(GameManager.elapsed_time / 60)).pad_zeros(2)
	var s = str(int(GameManager.elapsed_time) % 60).pad_zeros(2)
	$Timer.text = "%s:%s" % [m, s]
	
	current_coins = lerpf(current_coins, GameManager.coins, delta * 10)
	$Coins.text = "$%d" % current_coins



func _on_line_edit_text_submitted(new_text: String) -> void:
	GameManager.sensitivity = float(new_text)

func _on_h_slider_value_changed(value: float) -> void:
	GameManager.master_volume = value


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
