extends CanvasLayer

signal destroyed()

func _on_back_button_pressed():
	destroyed.emit()
	queue_free()
	PlayerPreferenceManager.save()
