extends Area2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums
	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var speed : float = 1

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var base_damage : int
var resource : Spell
var caster : Player

#endregion

#region Godot methods
func _ready():
	if resource:
		modulate = resource.element.colour

func _process(_delta):
	position += Vector2(cos(rotation), sin(rotation)) * speed
#endregion

#region Signal methods
func _on_body_entered(body):
	if body != caster and "on_hurt" in body:
		body.on_hurt(self)

func _on_area_entered(area):
	if area != caster and "on_hurt" in area:
		area.on_hurt(self)

func _on_kill_timer_timeout():
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
