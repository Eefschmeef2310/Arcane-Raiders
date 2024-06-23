extends State
class_name Attack
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var spell_num: int = 0
@export var transition_out_instantly: bool = false
@export var transition_out_when_can_cast: bool = false
@export var next_state: String = ""
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var previous_state= ""
#endregion

#region Godot methods
func enter():
	play_anim()
	set_position()
	enemy.attempt_cast(spell_num)
	if transition_out_instantly:
		transition()

func physics_update(delta):
	super.physics_update(delta)
	if transition_out_when_can_cast and enemy.can_cast:
		transition()
#endregion

#region Signal methods
func _on_animation_player_animation_finished(_anim_name):
	if get_parent().current_state == self:
		transition()
#endregion

#region Other methods (please try to separate and organise!)
func transition():
	if next_state != "": Transitioned.emit(self, next_state)
	else: Transitioned.emit(self, previous_state)
#endregion

