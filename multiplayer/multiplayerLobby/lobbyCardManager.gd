extends Node
#class_name
#Authored by Tom. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants

#Exported Variables
#@export_group("Group")
#@export_subgroup("Subgroup")
@export_group("Card Values")
@export var username : String
@export var selected_raider : int = 0
@export var selected_loadout : int = 0
@export var selected_panel : int = 0 #0=raider, 1=loadout, 2=ready
@export var show_panels : bool = false #dont show stuff until a player connects
@export var player_ready : bool = false

@export_group("Other Resources")
#@export var default_slot_icon : Texture2D
#@export var default_online_card : PlayerCardRes
#@export var default_offline_card : PlayerCardRes

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

#Onready Variables

#Other Variables (please try to separate and organise!)


#endregion

#region Godot methods
func _ready():
	
	#setOnlineDefault()
	pass

func _process(delta):
	#Runs per frame
	if username != "":
		show_panels = true
	all_panels.visible = show_panels
	#also manage setting of visible card values 
	raider_name.text = lobby_manager.raiders[selected_raider].raider_name
	raider_desc.text = lobby_manager.raiders[selected_raider].raider_desc
	raider_portrait.texture = lobby_manager.raiders[selected_raider].portrait
	loadout_name.text = lobby_manager.loadouts[selected_loadout].loadout_name
	loadout_desc.text = lobby_manager.loadouts[selected_loadout].loadout_desc
	
	#also manage pips for raider and loadout 
	
	
	#also manage panel highlighting 
	#TODO make modulate colour the raider color?
	for panel_num in panels_array.size():
		if selected_panel == panel_num:
			#highlight panel with moduate
			(panels_array[panel_num] as Control).modulate = Color.RED
			pass
		else:
			#restore it to normal modulation
			(panels_array[panel_num] as Control).modulate = Color.WHITE
			pass
	pass
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
	
	#also set colour ect

func setLocalDefault():
	#setValues(default_offline_card)
	pass

func setOnlineDefault():
	#setValues(default_online_card)
	pass
#endregion
