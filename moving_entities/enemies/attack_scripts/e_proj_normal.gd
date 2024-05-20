extends SpellBase
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var projectile_speed: float = 600

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var initial_distance = 20
var direction: Vector2 = Vector2.RIGHT
#endregion

#region Godot methods
func _ready():
	if caster: 
		direction = caster.aim_direction if direction == Vector2.RIGHT else direction
		global_position = caster.global_position + direction * initial_distance
		look_at(global_position + direction)

func _process(delta):
	position += direction * projectile_speed * delta
#endregion

#region Signal methods
func _on_area_entered(_area):
	queue_free()

func _on_body_entered(_body):
	queue_free()
#endregion

#Called from other scripts (e.g Triple shot attack)
func set_direction(new_direction: Vector2):
	self.direction = new_direction
#endregion
