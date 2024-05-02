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
@export var match_tilemap_angle : bool = false
@export var speed_curve : Curve
@export var sprite_rotation_falloff_curve : Curve
@export var scale_falloff_curve : Curve
@export var transparency_falloff_curve: Curve
@export var area_enabled_curve : Curve

	#Onready Variables
@onready var kill_timer = $kill_timer
@onready var sprite_2d = $Sprite2D
@onready var point_light_2d = $PointLight2D
@onready var collision_shape_2d = $CollisionShape2D

	#Other Variables (please try to separate and organise!)
var base_damage : int
var resource : Spell
var caster : Player

var starting_scale : Vector2

var lifetime_progress : float

var infliction_time : float

#endregion

#region Godot methods
func _ready():
	if resource:
		modulate = resource.element.colour
		point_light_2d.color = resource.element.colour
	sprite_2d.rotation_degrees = randf_range(0, 360)
	starting_scale = scale
	scale = starting_scale * (scale_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if scale_falloff_curve else 1.0)
	point_light_2d.texture_scale = scale.x * 1.5

func _physics_process(_delta):
	lifetime_progress = (kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time
	
	position += Vector2(cos(rotation), sin(rotation)/(2 if match_tilemap_angle else 1)) * \
		((speed_curve.sample(lifetime_progress) if speed_curve else 0.0))
	scale = starting_scale * (scale_falloff_curve.sample((kill_timer.wait_time - kill_timer.time_left)/kill_timer.wait_time) if scale_falloff_curve else 1.0)
	point_light_2d.texture_scale = scale.x * 1.5
	sprite_2d.rotation_degrees += sprite_rotation_falloff_curve.sample(lifetime_progress) if sprite_rotation_falloff_curve else 1.0
	
	sprite_2d.modulate.a = transparency_falloff_curve.sample(lifetime_progress) if transparency_falloff_curve else 1.
	
	#1.0 - so you can set the curve to 0 for disabled and 1 for enabled
	collision_shape_2d.disabled = 1.0 - area_enabled_curve.sample(lifetime_progress) if area_enabled_curve else 0.0

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
