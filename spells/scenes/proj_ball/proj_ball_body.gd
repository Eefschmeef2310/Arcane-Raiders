extends RigidBody2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables

	#Exported Variables
@export var move_speed : float = 1000
@export var explosion_size : float = 1

	#Onready Variables
@onready var explosion_scene = preload("res://spells/scenes/explosive/explosion.tscn")

var direction : Vector2

var base_damage : int
var resource : Spell
var caster : Player

#endregion

#region Godot methods
func _ready():
	direction = caster.aim_direction
	global_position = caster.global_position + (direction * 20)
	look_at(global_position + direction)
	
	modulate = resource.element.colour

func _process(delta):
	position += direction * move_speed * delta
#endregion

#region Signal methods
func _on_hitbox_body_entered(_body):
	create_explosion()

func _on_explosion_timer_timeout():
	create_explosion()
#endregion

#region Other methods
func create_explosion():
	var explosion = explosion_scene.instantiate()
	add_sibling(explosion)
	explosion.base_damage = base_damage
	explosion.resource = resource
	explosion.caster = caster
	explosion.position = position
	explosion.visible = true
	explosion.begin()
	
	queue_free()
	
#endregion

