extends CanvasLayer

signal destroyed()

func _input(event):
	if event.is_action_released("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed():
	destroyed.emit()
	queue_free()
	PlayerPreferenceManager.save()
