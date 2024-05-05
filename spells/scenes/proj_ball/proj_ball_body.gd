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
var infliction_time : float

var play_element_sound : bool = false

#endregion

#region Godot methods
func _ready():
	direction = caster.aim_direction
	global_position = caster.global_position + (direction * 40)
	look_at(global_position + direction)
	
	modulate = resource.element.colour
	$PointLight2D.color = resource.element.colour

func _process(delta):
	position += direction * move_speed * delta
#endregion

#region Signal methods
func _on_hitbox_body_entered(_body):
	if(_body.owner != caster):
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

