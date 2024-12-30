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
		if (("confirm" in mouse_input) or "click_confirm" in mouse_input):
			if current_button < panels_array.size() - 1:
				_on_difficulty_selected(panels_array[current_button])
			else:
				unpause_game()
		
		if "cancel" in mouse_input:
			unpause_game()
			
	mouse_input.clear()
#endregion

#region Signal methods

#region Button mouse enters
func _on_continue_button_mouse_entered():
	elapsed_time = 0
	difficulty_color = Color.GREEN
	radius = 0.5
	
func _on_feedback_button_mouse_entered():
	elapsed_time = 0
	difficulty_color = Color.YELLOW
	radius = 0.4

func _on_hard_button_mouse_entered():
	elapsed_time = 0
	difficulty_color = Color.RED
	radius = 0.3

func _on_extreme_button_mouse_entered():
	elapsed_time = 0
	difficulty_color = Color.PURPLE
	radius = 0.2

func _on_button_mouse_exited():
	elapsed_time = 0
	difficulty_color = Color.TRANSPARENT
	radius = 0.5
#endregion

#region Button presses
func _on_difficulty_selected(node : Control):
	if (get_parent() as CastleRoomLobby):
		(get_parent() as CastleRoomLobby).set_difficulty.rpc(panels_array.find(node))
		difficulty_set.emit()
		unpause_game()

#endregion

#endregion

#region Other methods (please try to separate and organise!)

#endregion

