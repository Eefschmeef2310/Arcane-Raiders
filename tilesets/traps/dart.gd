extends Area2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var move_speed : float

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var move_direction : Vector2
var in_wall : bool = true

#endregion

#region Godot methods
func _process(delta):
	position += move_direction * move_speed * delta
#endregion

#region Signal methods
func _on_area_entered(area):
	if "deal_damage" in area.get_parent():
		area.get_parent().deal_damage.rpc(null, 10, null, null, true)
	queue_free()

func _on_body_entered(body):
	if !in_wall:
		if "deal_damage" in body.get_parent():
			body.get_parent().deal_damage.rpc(null, 10, null, null, true)
		queue_free()
		
func _on_body_exited(body): #Allow dart to leave wall without destroy itself
	if in_wall:
		var in_any_wall_tiles : bool = false
		for overlapping_body : StaticBody2D in get_overlapping_bodies():
			if overlapping_body.get_collision_layer_value(1):
				in_any_wall_tiles = true
		
		if !in_any_wall_tiles:
			in_wall = false
			set_collision_mask_value(1, true)
#endregion

#region Other methods (please try to separate and organise!)

#endregion



