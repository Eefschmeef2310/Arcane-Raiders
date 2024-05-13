extends CanvasLayer

func _on_back_button_pressed():
	queue_free()
	PlayerPreferenceManager.save()
