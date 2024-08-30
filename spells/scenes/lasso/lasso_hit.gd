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
@export var line : Line2D
@export var wrap : Sprite2D

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var target : Node2D
var caster : Node2D

#endregion

#region Godot methods
func _process(_delta):
	if(is_instance_valid(target)):
		wrap.global_position = target.global_position
		line.points[0] = target.position
		line.points[1] = caster.position
#endregion

#region Signal methods
func _on_timer_timeout():
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)
func init(new_target : Node2D, new_caster : Node2D):
	target = new_target
	caster = new_caster
	
	#Set size of sprite
	var target_sprite = (target.get_node("Sprite2D") as Sprite2D)
	if target_sprite:
		wrap.scale.x = ((target_sprite.get_rect().size.x * target.scale.x) / wrap.get_rect().size.x) / 2
#endregion
