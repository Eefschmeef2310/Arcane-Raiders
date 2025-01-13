extends Area2D
#class_name ExplosionBaseScript
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
@export var knockback : float = 1
@export var destroy_on_contact : bool = false

	#Onready Variables
@onready var kill_timer = $kill_timer
@onready var sprite_2d = $Sprite2D
@onready var point_light_2d = $PointLight2D
@onready var collision_shape_2d = $CollisionShape2D

	#Other Variables (please try to separate and organise!)
var base_damage : int
var resource : Spell
var caster : Player
var cast_uuid : CastUUIDManager
var deal_force : bool

var starting_scale : Vector2

var lifetime_progress : float

var infliction_time : float

var play_element_sound : bool = false

#endregion

#region Godot methods
func _ready():
	if resource:
		if resource.element.gradient:
			(material as ShaderMaterial).set_shader_parameter("gradient", resource.element.gradient)
		else:
			modulate = resource.element.colour
		point_light_2d.color = resource.element.colour
		if play_element_sound and resource.element.sound:
			AudioManager.play_audio2D_at_point(global_position, resource.element.sound)
	#sprite_2d.rotation_degrees = randf_range(0, 360)
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
	
	(material as ShaderMaterial).set_shader_parameter("alpha", transparency_falloff_curve.sample(lifetime_progress) if transparency_falloff_curve else 1.)
	
	#1.0 - so you can set the curve to 0 for disabled and 1 for enabled
	collision_shape_2d.disabled = 1.0 - area_enabled_curve.sample(lifetime_progress) if area_enabled_curve else 0.0

#endregion

#region Signal methods
func _on_body_entered(body):
	if body != caster and "on_hurt" in body:
		#print("bingus")
		body.on_hurt(self)
	if destroy_on_contact:
		queue_free()

func _on_area_entered(area):
	if area.owner != caster and "on_hurt" in area.owner:
		#print("aingus")
		area.owner.on_hurt(self)
	if destroy_on_contact:
		queue_free()

func _on_kill_timer_timeout():
	queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
