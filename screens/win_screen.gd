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
@export var damage_dealt : FinalStat
@export var kills : FinalStat
@export var highest_earner : FinalStat
@export var most_pickups : FinalStat
@export var most_reactions : FinalStat

@export_group("Node References")
@export var total_time : Label
@export var leaderboard_panels : Array[Panel]
@export var back_button_progress_bar : ProgressBar
@export var seed : Label
@export var master_mode : RichTextLabel
@export var quit_button : Button

	#Onready Variables
@onready var castle_climb : CastleClimb = get_parent().get_parent()

	#Other Variables (please try to separate and organise!)
var game : Control
var back_timer : float
var scores : Array[stat_score]

class stat_score:
	var player : Color
	var wins : int
	var damage : int

var hats_used = []
#endregion

#region Godot methods
func _ready():
	AudioManager.play_track_fade("win")
	
	#add to runs completed
	SaveManager.runs_completed += 1
	SaveManager.games_played += 1
	if castle_climb.current_floor >= 4:
		SaveManager.area_1_complete = true
	if castle_climb.current_floor >= 8:
		SaveManager.area_2_complete = true
	if castle_climb.current_floor >= 12:
		SaveManager.area_3_complete = true
		
		for data in castle_climb.player_data:
			if data.character != null:
				if !SaveManager.characters_completed.has(data.character.raider_name):
					SaveManager.characters_completed.append(data.character.raider_name)
	
	for player in castle_climb.player_data:
		SaveManager.total_kills += player.kills
	
	SaveManager.request_save()
	
	#display all the per player stats
	for ui in castle_climb.player_ui:
		var player_ui : PlayerUI = ui
		player_ui.show_stats_ui()
		player_ui.update_stats_ui()
	
	#pause the game in the background
	get_tree().paused = true
	
	#print_debug(castle_climb.check_crown()) 
	damage_dealt.load_data(castle_climb.get_highest_damage())
	kills.load_data(castle_climb.get_highest_kills())
	highest_earner.load_data(castle_climb.get_highest_earner())
	most_pickups.load_data(castle_climb.get_most_pickups())
	most_reactions.load_data(castle_climb.get_most_reactions())
	
	for data in castle_climb.player_data:
		if data.damage > 0:
			var new_score = stat_score.new()
			new_score.player = data.main_color
			new_score.wins = 0
			new_score.damage = data.damage
			scores.append(new_score)
		
		if data.peer_id == get_tree().get_multiplayer().get_unique_id():
			hats_used.append(data.hat_string)
	
	for stat in scores:
		if damage_dealt.top_player() == stat.player: stat.wins += 1
		if kills.top_player() == stat.player: stat.wins += 1
		if highest_earner.top_player() == stat.player: stat.wins += 1
		if most_pickups.top_player() == stat.player: stat.wins += 1
		if most_reactions.top_player() == stat.player: stat.wins += 1
	
	#if castle_climb.james_mode:
		#master_mode.show()
	#else:
		#master_mode.hide()
	
	match castle_climb.difficulty_setting:
		0:
			master_mode.text = "[center]Difficulty: [color=green]Easy"
		1: 
			master_mode.text = "[center]Difficulty: [color=Yellow]Medium"
		2:
			master_mode.text = "[center]Difficulty: [color=red]Hard"
		3:
			master_mode.text = "[center]Difficulty: [color=purple]Extreme"
	
	if castle_climb.preset_seed:
		seed.show()
		seed.text = 'Custom seed used: "' + castle_climb.seed_text + '"'
	else:
		seed.hide()
	
	#if(GameManager.isLocal()):
		#damage_dealt.stat_title.text = "Most " + damage_dealt.stat_title.text
		#kills.stat_title.text = "Most " + kills.stat_title.text
		#highest_earner.stat_title.text = "Most " + highest_earner.stat_title.text
		#most_pickups.stat_title.text = "Most " + most_pickups.stat_title.text
		#most_reactions.stat_title.text = "Most " + most_reactions.stat_title.text
	#
	#var local_playerdata_id = -1
	#if(GameManager.isOnline()):
		#var local_peer_id = multiplayer.get_unique_id()
		##print_debug("This peer id: " + str(local_peer_id))
		#for i in castle_climb.player_data.size():
			#if local_peer_id == castle_climb.player_data[i].peer_id && local_playerdata_id == -1:
				#local_playerdata_id = i
		##print_debug("This castleclimb id: " + str(local_playerdata_id))
	#
	#if local_playerdata_id != -1:
		#damage_dealt.stat_title.text += str(castle_climb.player_data[local_playerdata_id].damage)
		#kills.stat_title.text += str(castle_climb.player_data[local_playerdata_id].kills)
		#highest_earner.stat_title.text += str(castle_climb.player_data[local_playerdata_id].total_money)
		#most_pickups.stat_title.text += str(castle_climb.player_data[local_playerdata_id].pickups_obtained)
		#most_reactions.stat_title.text += str(castle_climb.player_data[local_playerdata_id].reactions_created)
	
	total_time.text += str(GameManager.format_timer(castle_climb.time_elapsed))
	
	#print_debug(str(castle_climb.get_leaderboard()))
	#var leaderboard : Array[int] = castle_climb.get_leaderboard()
	var leaderboard : Array[int] = get_leaderboard()
	var players_in_leaderboard = leaderboard.size()
	for i in range(4):
		#set corresponding card
		if i < players_in_leaderboard:
			#print_debug("we have " + str(i))
			leaderboard_panels[i].get_node("SpritesFlip/SpritesScale/Head").texture = castle_climb.player_data[leaderboard[i]].character.head_texture
			leaderboard_panels[i].get_node("SpritesFlip/SpritesScale/Head/Hat").texture = castle_climb.player_data[leaderboard[i]].hat_sprite
			leaderboard_panels[i].get_node("SpritesFlip/SpritesScale/Body").self_modulate = castle_climb.player_data[leaderboard[i]].main_color
			leaderboard_panels[i].get_node("SpritesFlip/SpritesScale/RightHand").self_modulate = castle_climb.player_data[leaderboard[i]].character.skin_color
			leaderboard_panels[i].get_node("SpritesFlip/SpritesScale/LeftHand").self_modulate = castle_climb.player_data[leaderboard[i]].character.skin_color
			if i == 0 and players_in_leaderboard >= 2:
				leaderboard_panels[i].get_node("Label").show()
		else:
			leaderboard_panels[i].visible = false
			#print_debug("we lack " + str(i))

	# Save everything
	
	if castle_climb.difficulty_setting >= SaveManager.highest_difficulty_unlocked:
		SaveManager.highest_difficulty_unlocked = castle_climb.difficulty_setting + 1
	for hat in hats_used:
		if !hat in SaveManager.hats_highest_difficulty_completed or SaveManager.hats_highest_difficulty_completed[hat] < castle_climb.difficulty_setting:
			SaveManager.hats_highest_difficulty_completed[hat] = castle_climb.difficulty_setting
	SaveManager.request_save()
	
	if not castle_climb.preset_seed:
		if castle_climb.difficulty_setting >= 0:
			SteamManager.grant_achievement("win_easy")
		if castle_climb.difficulty_setting >= 1:
			SteamManager.grant_achievement("win_medium")
		if castle_climb.difficulty_setting >= 2:
			SteamManager.grant_achievement("win_hard")
		if castle_climb.time_elapsed < 400:
			SteamManager.grant_achievement("speed")
		if castle_climb.difficulty_setting >= 3:
			SteamManager.grant_achievement("win_expert")
			if castle_climb.time_elapsed < 400:
				SteamManager.grant_achievement("speed_expert")
		
		if castle_climb.number_of_players == 4:
			SteamManager.grant_achievement("4_players")
		if castle_climb.number_of_players == 1 and castle_climb.difficulty_setting == 3:
			SteamManager.grant_achievement("1_player_expert")
			
		
		if SteamManager.damageless:
			SteamManager.grant_achievement("no_damage")
	
	SteamManager.update_stats_and_achievements()
	
	if(GameManager.isLocal()):
		pass
	else:
		quit_button.text = "Menu"
	

 
func _process(delta):
	if Input.is_action_pressed("ui_cancel"):
		back_timer += delta
		if back_timer > 1:
			_on_quit_button_pressed()
	else:
		back_timer = 0
	back_button_progress_bar.value = (back_timer / 1) * 100
#endregion

#region Signal methods

func _on_quit_button_pressed():  
	#get_tree().paused = false
	#get_tree().change_scene_to_file("res://menus/main_menu.tscn")
	## game.queue_free()
	#queue_free()
	
	if(GameManager.isLocal()):
		get_tree().paused = false
		get_tree().get_first_node_in_group("hub").request_lobby_restart()
	else: # online game, send back to menu
		get_tree().paused = false
		get_tree().change_scene_to_file("res://menus/main_menu.tscn")
		# game.queue_free()
		queue_free()
#endregion

#region Other methods (please try to separate and organise!)
func get_leaderboard() -> Array[int]:
	var leaders : Array[int] = [] # player id's only
	var data : Array[stat_score] = scores.duplicate()
	var passes = 0
	print(scores)
	
	data.sort_custom(custom_sort_stat_scores)
	
	#populate leaders 
	for x in data.size():
		if data[x].wins > 0 or data[x].damage > 0:
			var player_id = -1 
			#leaders[x] = -1
			for i in castle_climb.number_of_players:
				if castle_climb.player_data[i].main_color == data[x].player:
					#leaders[x] = i
					leaders.append(i)
				
	
	#while passes < 4:
		#var most_wins = -1
		#var player_id = -1
		#for i in castle_climb.number_of_players:
			#if data[i].wins > most_wins:
				#most_wins = data[i].wins
				#player_id = i
		#
		#if(data[player_id].wins != -1):
			#leaders.append(player_id)
			#data[player_id].wins = -1
		#passes += 1
	
	
	#returns an array of player id's from 1st to 4th, missing players will return -1
	return leaders 

func custom_sort_stat_scores(a: stat_score, b: stat_score):
	if (a.wins > b.wins) or (a.wins == b.wins and a.damage >= b.damage):
		return true
	return false
	
#endregion
