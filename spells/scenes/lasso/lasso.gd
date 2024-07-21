extends Node2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var path_follow : PathFollow2D
@export var kill_timer : Timer

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _process(_delta):
	path_follow.progress_ratio = (2/PI) * asin( sin( (PI/kill_timer.wait_time) * kill_timer.time_left) )
#endregion

#region Signal methods
func _on_kill_timer_timeout():
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
