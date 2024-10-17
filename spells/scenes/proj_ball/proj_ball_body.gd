extends RigidBody2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables

	#Exported Variables
@export var move_speed : float = 1000

	#Onready Variables
@export var explosion_scene : PackedScene

var direction : Vector2

var base_damage : int
var resource : Spell
var caster : Player
var cast_uuid : CastUUIDManager
var infliction_time : float

var play_element_sound : bool = false

#endregion

#region Godot methods
func _ready():
	direction = caster.aim_direction
	global_position = caster.global_position + (direction * 40)
	look_at(global_position + direction)
	
	if resource.element.gradient:
		($AnimatedSprite2D.material as ShaderMaterial).set_shader_parameter("gradient", resource.element.gradient)
	else:
		modulate = resource.element.colour
	$PointLight2D.color = resource.element.colour
	
	$AnimatedSprite2D.play("default")

func _process(delta):
	position += direction * move_speed * delta
#endregion

#region Signal methods
func _on_hitbox_body_entered(body):
	if(body.owner != caster):
		create_explosion()

func _on_explosion_timer_timeout():
	create_explosion()
#endregion

#region Other methods
func create_explosion():
	var explosion = explosion_scene.instantiate()
	
	explosion.base_damage = base_damage
	explosion.resource = resource
	explosion.caster = caster
	explosion.position = position
	explosion.infliction_time = infliction_time
	explosion.visible = true
	explosion.play_element_sound = play_element_sound
	call_deferred("add_sibling", explosion)
	
	queue_free()
	
#endregion
