extends Node
class_name HatPickup #THIS MUST BE A SEPARATE CLASS BCS THIS SCRIPT IS USED FOR THE HAT DESTROYER
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var target_info_modulate_a = 0

#endregion

#region Godot methods
#endregion

#region Signal methods
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		$Outline.self_modulate = body.data.main_color
		$Outline.show()
		target_info_modulate_a = 1

func _on_area_2d_body_exited(body):
	$Outline.hide()
	target_info_modulate_a = 0
	
	if $Area2D.get_overlapping_bodies().size() <= 0:
		pass
	
	for thing in $Area2D.get_overlapping_bodies():
		if thing.is_in_group("player"):
			$Outline.show()
			target_info_modulate_a = 1
	if body.is_in_group("player"):
		$Outline.hide()
		target_info_modulate_a = 0
#endregion

#region Other methods (please try to separate and organise!)
func pickup_function(player):
	for child in player.get_children():
		if child is Hat:
			child.queue_free()
			player.crown.texture = null
#endregion
