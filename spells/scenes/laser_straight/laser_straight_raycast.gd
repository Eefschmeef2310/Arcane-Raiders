extends RayCast2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
var is_casting : bool = false

var t = 0
var y_offset = -16
var track_aim := true
var beam_width = 30

var base_damage : int
var resource : Spell
var caster : Player
var cast_uuid : CastUUIDManager
var infliction_time : float
#endregion

#region Godot methods
func _ready():
	owner.transfer_data(self)
	owner.transfer_data($Area2D)
	owner.global_position = caster.global_position
	owner.global_position.y += y_offset
	$Line2D.width = 5
	
	if owner.resource.element.gradient:
		($Line2D.material as ShaderMaterial).set_shader_parameter("gradient", owner.resource.element.gradient)
	else:
		$Line2D.default_color = owner.resource.element.colour
	
	#await get_tree().create_timer(owner.start_time).timeout
	track_aim = false
	
	target_position = global_position + (caster.aim_direction * 999999)
	target_position.y += y_offset
	
	var cast_point = target_position
	var cast_length: float
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		cast_length = position.distance_to(cast_point)
		
	$Line2D.points[1] = cast_point
	$Line2D.width = beam_width
	$Area2D.monitorable = true
	$Area2D/CollisionShape2D.position = (position + cast_point)/2
	$Area2D/CollisionShape2D.rotation = position.direction_to(cast_point).angle()
	$Area2D/CollisionShape2D.shape.size = Vector2(cast_length, beam_width)
	
	$KillTimer.start()
	$AnimationPlayer.play("beam", -1, 1/$KillTimer.wait_time)

func _process(_delta):
	if track_aim:
		owner.global_position = caster.global_position
		owner.global_position.y += y_offset
		update_raycast()
		if is_colliding():
			var cast_point = to_local(get_collision_point())
			$Line2D.points[1] = cast_point

func update_raycast():
	target_position = global_position + (caster.aim_direction * 999999)
	target_position.y += y_offset
	force_raycast_update()

#endregion

#region Signal methods
func _on_kill_timer_timeout():
	owner.queue_free()
#endregion

#region Other methods (please try to separate and organise!)
#endregion

