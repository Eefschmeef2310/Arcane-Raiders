extends GamePausingMenu
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals
signal difficulty_set()

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var vignette : ColorRect
@export var lerp_duration : float = 0.5
@onready var custom_seed_entry = $Container/Control/MarginContainer/MarginContainer/VBoxContainer/HBoxContainer/CustomSeedEntry


	#Onready Variables

	#Other Variables (please try to separate and organise!)
	
var vignette_material : ShaderMaterial
var difficulty_color : Color = Color.GREEN
var radius : float = 0.5

var elapsed_time : float = 0

#endregion

#region Godot methods
func _ready():
	var arr = [3, 2, 1, 0]
	for i in arr:
		if i > SaveManager.highest_difficulty_unlocked:
			panels_array[i].modulate = Color.WEB_GRAY
			panels_array[i].mouse_entered.disconnect(_on_mouse_entered)
			panels_array.remove_at(i)
	
	super._ready()
	vignette_material = vignette.material as ShaderMaterial

func _process(delta):
	super._process(delta)
	
	if elapsed_time < lerp_duration:
		elapsed_time += delta
		vignette_material.set_shader_parameter("vignette_color", lerp(vignette_material.get_shader_parameter("vignette_color"), difficulty_color, elapsed_time / lerp_duration) )
		vignette_material.set_shader_parameter("inner_radius", lerp(vignette_material.get_shader_parameter("inner_radius"), radius, elapsed_time / lerp_duration) )
		
	if !is_instance_valid(submenu):
		if ("confirm" in mouse_input) and panels_array[current_button] is LineEdit:
			if panels_array[current_button].has_focus():
				panels_array[current_button].release_focus()
			else:
				panels_array[current_button].grab_focus()
		
		if (("confirm" in mouse_input) or "click_confirm" in mouse_input) and current_button != -1:
			if current_button < panels_array.size() - 2:
				_on_difficulty_selected(panels_array[current_button])
			elif !(panels_array[current_button] is LineEdit):
				unpause_game()
		
		if "cancel" in mouse_input:
			unpause_game()
			
	mouse_input.clear()
#endregion

#region Signal methods

#region Button mouse enters
func _on_mouse_entered(col : Color, rad : float):
	elapsed_time = 0
	difficulty_color = col
	radius = rad

func _on_button_mouse_exited():
	if device_id <= -1 and (!(panels_array[current_button] is LineEdit) or !(panels_array[current_button] as LineEdit).has_focus()):
		current_button = -1
	elapsed_time = 0
	difficulty_color = Color.TRANSPARENT
	radius = 0.5
#endregion

#region Button presses
func _on_difficulty_selected(node : Control):
	if (get_parent().get_parent() as CastleRoomLobby):
		(get_parent().get_parent() as CastleRoomLobby).set_difficulty.rpc(panels_array.find(node))
		(get_parent().get_parent() as CastleRoomLobby).custom_seed = custom_seed_entry.text
		difficulty_set.emit()
		unpause_game()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
