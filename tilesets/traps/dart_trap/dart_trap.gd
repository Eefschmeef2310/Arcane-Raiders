extends Node2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const DART = preload("res://tilesets/traps/dart_trap/dart.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var dart_fire_rotation : float
@export var first_available_sector : int = 1

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var should_fire : bool = true

#endregion

#region Godot methods
func _ready(): 
	#var castle_climb : CastleClimb = owner.get_parent().get_parent()
	#if castle_climb and castle_climb.get_current_sector() < first_available_sector:
		#queue_free()
		#
	get_parent().get_parent().all_waves_cleared.connect(toggle_fire)
#endregion

#region Signal methods
func _on_timer_timeout():
	if is_multiplayer_authority():
		create_dart.rpc()
#endregion

#region Other methods (please try to separate and organise!)
@rpc("authority", "call_local", "reliable")
func create_dart():
	if should_fire:
		$AudioStreamPlayer2D.play()
		var dart = DART.instantiate()
		dart.global_position = global_position
		dart.rotation_degrees = dart_fire_rotation
		dart.move_direction = Vector2(cos(deg_to_rad(dart_fire_rotation)), sin(deg_to_rad(dart_fire_rotation)))
		add_sibling(dart)
		
func toggle_fire():
	should_fire = false
#endregion
