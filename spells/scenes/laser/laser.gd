extends RayCast2D
	#class_name
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
var is_casting : bool = false
#endregion

#region Godot methods
func _ready():
	var cast_point = target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	$Line2D.points[1] = cast_point
	($Area2D/CollisionShape2D as CollisionShape2D).shape.b = cast_point
#endregion

#region Signal methods
func _on_kill_timer_timeout():
	owner.queue_free()
#endregion

#region Other methods (please try to separate and organise!)
#endregion

