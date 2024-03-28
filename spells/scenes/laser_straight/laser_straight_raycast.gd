extends RayCast2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
var is_casting : bool = false

var t = 0

var base_damage : int
var resource : Spell
var caster : Player
#endregion

#region Godot methods
func _ready():
	await get_tree().create_timer(owner.start_time).timeout
	print("dayumn")
	
	owner.transfer_data(self)
	owner.transfer_data($Area2D)
	owner.global_position = caster.global_position
	owner.global_position.y -= 32
	
	target_position = global_position + (caster.aim_direction * 999999)
	
	var cast_point = target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
	$Line2D.points[1] = cast_point
	($Area2D/CollisionShape2D as CollisionShape2D).shape.b = cast_point
	
	$KillTimer.wait_time = owner.end_time
	$KillTimer.start()

func _process(delta):
	if !$KillTimer.is_stopped():
		t += delta
		$Area2D/CollisionShape2D.disabled = (sin(t*200) >= 0)
		print($Area2D/CollisionShape2D.disabled)

#endregion

#region Signal methods
func _on_kill_timer_timeout():
	owner.queue_free()
#endregion

#region Other methods (please try to separate and organise!)
#endregion

