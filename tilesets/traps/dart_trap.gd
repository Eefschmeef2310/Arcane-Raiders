extends Node2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const DART = preload("res://tilesets/traps/dart.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var dart_fire_rotation : float

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
#endregion

#region Signal methods
func _on_timer_timeout():
	if is_multiplayer_authority():
		create_dart.rpc()
#endregion

#region Other methods (please try to separate and organise!)
@rpc("authority", "call_local", "reliable")
func create_dart():
	var dart = DART.instantiate()
	dart.global_position = global_position
	dart.move_direction = Vector2(cos(deg_to_rad(dart_fire_rotation)), sin(deg_to_rad(dart_fire_rotation)))
	add_sibling(dart)
#endregion
