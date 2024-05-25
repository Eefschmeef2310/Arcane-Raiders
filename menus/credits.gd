extends CanvasLayer

signal destroyed()
@onready var scroll_container : ScrollContainer = $Background/VBoxContainer/ScrollContainer

func _ready():
	$Background/VBoxContainer/ButtonMargin/BackButton.grab_focus()

func _process(delta):
	for device in GameManager.devices:
		var scroll_dir = MultiplayerInput.get_axis(device, "lobby_up", "lobby_down")
		scroll_container.scroll_vertical += scroll_dir * delta * 500

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()

func _on_back_button_pressed():
	destroyed.emit()
	queue_free()
	PlayerPreferenceManager.save()
