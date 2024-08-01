extends SpellBase
class_name ProjLocalEnemy
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables

@export var burst_amount: int = 4
@export var bullet_scene: PackedScene = null

var direction0: Vector2 = Vector2.RIGHT
#endregion

#region Godot methods
func _ready():
	if caster: 
		global_position = caster.global_position
		direction0 = caster.aim_direction
		if "burst_amount" in caster:
			burst_amount = caster.burst_amount
		
		
	if has_node("Indicator"):
		$Indicator/Direction.look_at($Indicator/Direction.global_position + direction0)
		for n in burst_amount:
			if n != 0:
				var new_projection = $Indicator/Direction/Projection.duplicate()
				$Indicator/Direction.add_child(new_projection)
				new_projection.rotation_degrees = n * (360.0/burst_amount)
		await get_tree().create_timer(start_time).timeout
		$Indicator.hide()
	
	for n in burst_amount:
		var proj = bullet_scene.instantiate()
		proj.set_direction(direction0.rotated(deg_to_rad(360./burst_amount*n)))
		transfer_data(proj)
		call_deferred("add_sibling", proj)
		
		if !caster: proj.global_position = global_position #Debug purposes
	queue_free()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

