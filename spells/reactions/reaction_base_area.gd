extends Area2D
class_name ReactionArea
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const REACTION_ELEMENTS_UI = preload("res://spells/reactions/reaction_elements_ui.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var base_damage : int = 10
@export var reaction_name : String
@export var limit_spawns : bool = true
@export var can_knockback:bool = false

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var should_continue: bool = true
var caster : Node2D

var elements : Array
var should_make_new_numbers : bool = true
var new_reaction_timer : Timer = Timer.new()

#for calculating everages

#endregion

#region Godot methods
func _ready():
	new_reaction_timer.wait_time = 0.2
	new_reaction_timer.autostart = true
	
	if limit_spawns:
		for node in get_tree().get_nodes_in_group(get_groups()[0]):
			#print(node.new_reaction_timer.is_stopped())
			if node != self and node.reaction_name == reaction_name and node.global_position.distance_to(global_position) < 300 and !node.new_reaction_timer.is_stopped():
				node.global_position = (node.global_position + global_position)/2
				#node.scale += Vector2(0.1, 0.1);
				remove_from_group(get_groups()[0])
				should_continue = false
				queue_free()
			
	if should_continue:
		#remove_from_group(get_groups()[0])
		AudioManager.play_audio2D_at_point(global_position, load("res://sounds/effects/reactions/Free Sound Effect (Magic Boom Explosion) HD.mp3"))
		
		var reaction_elements_ui = REACTION_ELEMENTS_UI.instantiate()
		reaction_elements_ui.position = position
		#reaction_elements_ui.z_index = z_index + 1
		add_sibling(reaction_elements_ui)
		
		if elements.size() == 2:
			reaction_elements_ui.element_1.texture = elements[0].pip_texture
			reaction_elements_ui.element_1.modulate = elements[0].colour
			
			reaction_elements_ui.element_2.texture = elements[1].pip_texture
			reaction_elements_ui.element_2.modulate = elements[1].colour
			
			reaction_elements_ui.reaction_name.text = reaction_name + "!"
		
		#remove_from_group(get_groups()[0])
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion
