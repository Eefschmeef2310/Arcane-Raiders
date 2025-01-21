extends SpellBase
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var projectile_speed: float = 600

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var initial_distance = 20
var direction: Vector2
#endregion

#region Godot methods
func _ready():
	if caster: 
		if direction == Vector2.ZERO: direction = caster.aim_direction 
		if global_position == Vector2.ZERO: global_position = caster.global_position + direction * initial_distance
		look_at(global_position + direction)

func _process(delta):
	position += direction * projectile_speed * delta
#endregion

#region Signal methods
func _on_area_entered(area):
	var parent = area.get_parent()
	if !(parent is Player and (parent.is_invincible or parent.is_dashing)):
		call_deferred("queue_free")

func _on_body_entered(_body):
	call_deferred("queue_free")

#Called from other scripts (e.g Triple shot attack)
func set_direction(new_direction: Vector2):
	direction = new_direction
#endregion


func _on_timer_timeout():
	call_deferred("queue_free")
