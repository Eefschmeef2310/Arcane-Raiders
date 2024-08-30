extends SpellBase
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const LASSO_HIT = preload("res://spells/scenes/lasso/lasso_hit.tscn")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var distance_from_caster : float = 40
@export var knockback : float = 1

@export_group("Node References")
@export var path_follow : PathFollow2D
@export var icon : Sprite2D
@export var kill_timer : Timer
@export var line : Line2D
@export var hurtbox : Area2D

	#Onready Variables
@onready var initial_freq = kill_timer.wait_time

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	global_position = caster.global_position + (caster.aim_direction * distance_from_caster) + Vector2(0,-30)
	rotation = caster.aim_direction.angle()
	
	if resource.element.gradient:
		(line.material as ShaderMaterial).set_shader_parameter("gradient", resource.element.gradient)
		(icon.material as ShaderMaterial).set_shader_parameter("gradient", resource.element.gradient)
	else:
		line.modulate = resource.element.colour
		icon.modulate = resource.element.colour

func _process(_delta):
	#print((kill_timer.wait_time - kill_timer.time_left))
	#if hurtbox.get_overlapping_bodies().size() == 0:
		#path_follow.progress_ratio = (2/PI) * asin( sin( (PI/kill_timer.wait_time) * kill_timer.time_left) )
	#else:
		#kill_timer.start(kill_timer.wait_time - kill_timer.time_left)
		#path_follow.progress_ratio = (2/PI) * asin( sin( (PI/kill_timer.wait_time) * kill_timer.time_left) )
	path_follow.progress_ratio = (2/PI) * asin( sin( (PI/initial_freq) * (initial_freq - kill_timer.time_left)) )
	#path_follow.progress_ratio = kill_timer.wait_time * 
	global_position = caster.global_position + (caster.aim_direction * distance_from_caster) + Vector2(0,-30)
	rotation = caster.aim_direction.angle()
	
	line.points[1] = path_follow.position
#endregion

#region Signal methods
func _on_kill_timer_timeout():
	queue_free()
	
func _on_hurtbox_body_entered(_body):
	#print(initai - kill_timer.time_left)
	#Hits a wall: detract immediately
	kill_timer.start(initial_freq - kill_timer.time_left)
	#path_follow.progress_ratio = (2/PI) * asin( sin( (PI/kill_timer.wait_time) * kill_timer.time_left) )
	
func _on_hurtbox_area_entered(area):
	if area.owner != caster and "on_hurt" in area.owner:
		var hit = LASSO_HIT.instantiate()
		hit.init(area.owner, caster, resource.element)
		add_sibling(hit)
		
		area.owner.on_hurt(self)
		queue_free()
#endregion

#region Other methods (please try to separate and organise!)

#endregion
