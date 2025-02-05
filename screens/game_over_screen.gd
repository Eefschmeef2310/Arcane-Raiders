extends CanvasLayer
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Grdwoup")
	#@export_subgroup("Subgroup")

	#Onready Variables
@onready var castle_climb : CastleClimb = get_parent()

	#Other Variables (please try to separate and organise!)
@export var reset_button : Button
#endregion

#region Godot methods
func _ready():
	get_tree().paused = true
	
	SaveManager.games_played += 1
	
	#Save Management Stuff
	if castle_climb.current_floor >= 4:
		SaveManager.area_1_complete = true
	if castle_climb.current_floor >= 8:
		SaveManager.area_2_complete = true
	if castle_climb.current_floor >= 12:
		SaveManager.area_3_complete = true
		
	for player in castle_climb.player_data:
		SaveManager.total_kills += player.kills
		
	SaveManager.request_save()
	
	AudioManager.play_track_fade("lose")
	
	if !is_multiplayer_authority():
		$Control/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ResetButton.disabled = true
		
	$Control/MarginContainer/VBoxContainer/Label4.text = "You cleared " + str(castle_climb.current_floor) + " floors in " + str(GameManager.format_timer(castle_climb.time_elapsed))

	for ui in castle_climb.player_ui:
		var player_ui : PlayerUI = ui
		player_ui.show_stats_ui()
		player_ui.update_stats_ui()
	
	SteamManager.update_stats_and_achievements()
	
	if(GameManager.isOnline()):
		reset_button.hide()
#endregion

#region Signal methods

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
	queue_free()

func _on_reset_button_pressed():
	get_tree().paused = false
	get_tree().get_first_node_in_group("hub").request_lobby_restart()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
