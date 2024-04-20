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
@export var speed_falloff_curve : Curve
@export var sprite_rotation_falloff_curve : Curve
@export var scale_falloff_curve : Curve
@export var transparency_falloff_curve: Curve

	#Onready Variables
@onready var kill_timer = $kill_timer
@onready var sprite_2d = $Sprite2D

	#Other Variables (please try to separate and organise!)
var base_damage : int
var resource : Spell
var caster : Player

var starting_scale : Vector2

#endregion

#region Godot methods
func _ready():
	if resource:
		modulate = resource.element.colour
	sprite_2d.rotation_degrees = randf_range(0, 360)
	starting_scale = scale
	scale = starting_scale * (scale_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if scale_falloff_curve else 1.0)

func _process(_delta):
	#print(speed_falloff_curve.sample((1.0 - (kill_timer.time_left/kill_timer.wait_time))))
	position += Vector2(cos(rotation), sin(rotation)/2) * \
		((speed_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if speed_falloff_curve else 1.0))
	scale = starting_scale * (scale_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if scale_falloff_curve else 1.0)
	sprite_2d.rotation_degrees += sprite_rotation_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if sprite_rotation_falloff_curve else 1.0
	
	sprite_2d.modulate.a = transparency_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if transparency_falloff_curve else 1.
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
