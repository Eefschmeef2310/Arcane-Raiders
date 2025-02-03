extends GamePausingMenu
#Authored by Ethan. Please consult for any modifications or major feature requests.

var just_spawned := true
var quit_warning

#region Godot methods
func _process(_delta):
	super._process(_delta)
	
	if !is_instance_valid(submenu):
		if (("confirm" in mouse_input) or "click_confirm" in mouse_input) and !quit_warning and current_button != -1:
			match current_button:
				0: unpause_game()
				#1: _on_feedback_button_pressed()
				1: _on_settings_button_pressed()
				2: _on_quit_button_pressed()
		
		if ("cancel" in mouse_input or "pause" in mouse_input):
			unpause_game()
		
	mouse_input.clear()
#endregion

#region Signal methods
#endregion
		
#region Button Presses
func _on_settings_button_pressed():
	submenu = load("res://menus/settings.tscn").instantiate()
	submenu.destroyed.connect(settings_set_focus)
	get_tree().root.add_child(submenu)
	
func _on_quit_button_pressed():
	if GameManager.isOnline():
		quit_warning = load("res://menus/quit_warning.tscn").instantiate()
		
		if is_multiplayer_authority():
			quit_warning.set_text("By quitting, you will close the server. \nAre you sure you want to quit?")
			
		#quit_warning.destroyed.connect($Control/MarginContainer/MarginContainer/VBoxContainer/QuitButton.warning_closed)

		add_child(quit_warning)
	else:
		get_tree().paused = false
		GameManager.isPaused = false
		
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")
		queue_free()
		
func _on_feedback_button_pressed():
	OS.shell_open("https://forms.gle/X1ToW3kE8Pzpy4mu5")

func _on_mouse_exited():
	if device_id <= -1: #We only want this if the player is a mouse player
		current_button = -1
#endregion

#endregion

#region Other methods (please try to separate and organise!)
func set_panel_color(col: Color):
	($Control/MarginContainer/Panel as Panel).self_modulate = col

func settings_set_focus():
	$Control/MarginContainer/MarginContainer/VBoxContainer/SettingsButton.grab_focus()
#endregion
