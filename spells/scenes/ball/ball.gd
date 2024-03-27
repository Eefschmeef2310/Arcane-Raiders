extends RigidBody2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const EXPLOSION = preload("res://spells/scenes/explosive/explosion.tscn")
	
	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var force : float = 1000
@export var explosion_size : float = 1

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	apply_impulse(Vector2(cos(owner.rotation), sin(owner.rotation)) * force)

func _process(_delta):
	#Runs per frame
	pass
#endregion

#region Signal methods
func _on_hitbox_body_entered(_body):
	var explosion = EXPLOSION.instantiate()
	explosion.size = explosion_size
	explosion.position = position
	owner.call_deferred("add_child", explosion)
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
