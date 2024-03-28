extends RigidBody2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables

	#Exported Variables
@export var force : float = 1000
@export var explosion_size : float = 1

	#Onready Variables
@onready var explosion = $"../Explosion"

#endregion

#region Godot methods
func _ready():
	apply_impulse(Vector2(cos(owner.rotation), sin(owner.rotation)) * force)
#endregion

#region Signal methods
func _on_hitbox_body_entered(_body):
	create_explosion()

func _on_explosion_timer_timeout():
	create_explosion()
#endregion

#region Other methods
func create_explosion():
	queue_free()
	
	explosion.position = position
	explosion.visible = true
	explosion.begin()
	
#endregion

