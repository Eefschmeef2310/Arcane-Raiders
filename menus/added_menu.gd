extends CanvasLayer

signal destroyed()

#TODO - ui_cancel implementation

func _on_back_button_pressed():
	destroyed.emit()
	queue_free()
	PlayerPreferenceManager.save()
