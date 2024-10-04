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
@export var wrap : Line2D

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var target : Node2D
var caster : Node2D

var target_line

#endregion

#region Godot methods
func _process(_delta):
	if(is_instance_valid(target)):
		wrap.global_position = target.global_position
		line.points[0] = target.position
		line.points[1] = caster.position

	if is_instance_valid(target_line):
		wrap.set_points(target_line.get_points())
		#line.points[0] = wrap.global_position
		line.points[0] = (target_line.points[0] + target_line.points[1])/2 + wrap.global_position

#region Signal methods
func _on_timer_timeout():
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)
func init(new_target : Node2D, new_caster : Node2D, element : ElementResource):
	target = new_target
	caster = new_caster
	
	if element.gradient:
		(line.material as ShaderMaterial).set_shader_parameter("gradient", element.gradient)
		(wrap.material as ShaderMaterial).set_shader_parameter("gradient", element.gradient)
	else:
		line.modulate = element.colour
		wrap.modulate = element.colour
	
	#Set size of sprite
	target_line = (target.get_node("LassoLine") as Line2D)
		#wrap.scale.x = target_line.points[0].distance_to(target_line.points[1]) / wrap.get_rect().size.x
		#wrap.scale.x = target.lasso_width / wrap.get_rect().size.x
		#wrap.scale.x = ((target_sprite.get_rect().size.x * target.scale.x) / wrap.get_rect().size.x) * 0.75
#endregion
