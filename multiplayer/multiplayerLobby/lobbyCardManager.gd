extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
@export_group("Card Values")
@export var username : String
@export var selected_raider : int = 0
@export var selected_loadout : int = 0
@export var selected_panel : int = 0 #0=raider, 1=loadout, 2=ready
@export var show_panels : bool = true #dont show stuff until a player connects
@export var player_ready : bool = false
@export var highlight_color : Color = Color.RED

@export_group("Other Resources")
@export var pip_texture : Texture2D

@export_group("References")
@export var lobby_manager : Node
@export var raider_portrait : TextureRect 
@export var raider_name : Label 
@export var raider_desc : Label 
@export var player_name : Label
@export var loadout_name : Label
@export var loadout_desc : Label
@export var all_panels : VBoxContainer # hide and show this depending on if a player has joined 
@export var most_panels : VBoxContainer # modulate this to grey when a player is ready to show their choices are "locked"
@export var panels_array : Array[Control]
@export var character_pips_box : HBoxContainer
@export var loadout_pips_box : HBoxContainer
@export var spells_box : HBoxContainer

#Onready Variables

#Other Variables (please try to separate and organise!)


#endregion

#region Godot methods
func _ready():
	
	
	# create and prepare the ui pips
	for child in character_pips_box.get_children():
		child.queue_free()
	
	for raiderCount in lobby_manager.raiders.size():
		var new_pip = TextureRect.new()
		new_pip.texture = pip_texture
		if raiderCount > 0:
			new_pip.modulate = Color.DIM_GRAY
		character_pips_box.add_child(new_pip)
		
	for child in loadout_pips_box.get_children():
		child.queue_free()
		
	for loadoutCount in lobby_manager.loadouts.size():
		var new_pip = TextureRect.new()
		new_pip.texture = pip_texture
		if loadoutCount > 0:
			new_pip.modulate = Color.DIM_GRAY
		loadout_pips_box.add_child(new_pip)
	pass

func _process(_delta):
	#Runs per frame
	#if username != "":
		#show_panels = true
	
	if is_multiplayer_authority():
		var changed = false
		if(Input.is_action_just_pressed("down")):
			if not player_ready:
				selected_panel = clampi(selected_panel + 1, 0,2)
			changed = true
		
		if(Input.is_action_just_pressed("up")):
			if not player_ready:
				selected_panel = clampi(selected_panel - 1, 0,2)
			changed = true
		
		if(Input.is_action_just_pressed("left")):
			if(selected_panel == 0): #raider panel selected 
				selected_raider = clampi(selected_raider - 1, 0,lobby_manager.raiders.size()-1)
			elif(selected_panel == 1): #loadout selected
				selected_loadout = clampi(selected_loadout - 1, 0,lobby_manager.loadouts.size()-1)
			changed = true
			
		if(Input.is_action_just_pressed("right")):
			if(selected_panel == 0): #raider panel selected 
				selected_raider = clampi(selected_raider + 1, 0,lobby_manager.raiders.size()-1)
			elif(selected_panel == 1): #loadout selected
				selected_loadout = clampi(selected_loadout + 1, 0,lobby_manager.loadouts.size()-1)
			changed = true
		
		if(Input.is_action_just_pressed("lobby_confirm")):
			if(selected_panel == 2): #ready button selected
				player_ready = !player_ready
				changed = true
				
		if changed:
			setValues.rpc(Steam.getPersonaName(),selected_raider,selected_loadout,selected_panel,player_ready)
	
	UpdateDisplay()

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
@rpc("any_peer","call_local")
func setValues(new_username : String, new_raider : int, new_loadout : int, new_panel : int, new_ready : bool ):
	username = new_username
	player_name.text = username
	#raider name, picture and description will be an array get from lobby manager 
	#loadout name and desc will be an array get from lobby manager 
	selected_raider = new_raider
	selected_loadout = new_loadout
	selected_panel = new_panel
	player_ready = new_ready

func UpdateDisplay():
	
	# hide everything if there isnt a player to use it
	all_panels.visible = show_panels
	
	# set some basic values
	raider_name.text = lobby_manager.raiders[selected_raider].raider_name
	raider_desc.text = lobby_manager.raiders[selected_raider].raider_desc
	raider_portrait.texture = lobby_manager.raiders[selected_raider].portrait
	loadout_name.text = lobby_manager.loadouts[selected_loadout].loadout_name
	loadout_desc.text = lobby_manager.loadouts[selected_loadout].loadout_desc
	
	# prepare spell icons
	for spell : int in spells_box.get_children().size():
		var spell_resource: Spell = SpellManager.get_spell_from_string(lobby_manager.loadouts[selected_loadout].spell_ids[spell])
		if spell_resource:
			spells_box.get_child(spell).texture = spell_resource.ui_texture
			spells_box.get_child(spell).modulate = spell_resource.element.colour
	
	# Manage the pips under raider and loadout title
	for pip in character_pips_box.get_children().size():
		if pip == selected_raider:
			character_pips_box.get_child(pip).modulate = Color.WHITE
		else: 
			character_pips_box.get_child(pip).modulate = Color.DIM_GRAY
			
	for pip in loadout_pips_box.get_children().size():
		if pip == selected_loadout:
			loadout_pips_box.get_child(pip).modulate = Color.WHITE
		else: 
			loadout_pips_box.get_child(pip).modulate = Color.DIM_GRAY
	
	
	#Highlight the correct panel
	highlight_color = lobby_manager.raiders[selected_raider].color
	if player_ready:
		most_panels.modulate = Color.DIM_GRAY
	else: 
		most_panels.modulate = Color.WHITE 
	
	for panel_num in panels_array.size():
		if selected_panel == panel_num:
			#highlight panel with moduate
			(panels_array[panel_num] as Control).self_modulate = highlight_color
			pass
		else:
			#restore it to normal modulation
			(panels_array[panel_num] as Control).self_modulate = Color.WHITE
			pass
	pass

#endregion
