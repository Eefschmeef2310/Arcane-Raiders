extends SpellBase
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var EXPLOSION : PackedScene
@onready var raycast = $RayCast2D

var cast_distance: float = 250

func _ready():
	
	# Set modulation
	$Ring/Sprite2D.modulate = resource.element.colour
	
	# Setup raycast
	global_position = caster.global_position
	raycast.global_position = caster.global_position
	raycast.target_position = raycast.position + (caster.aim_direction * cast_distance)
	raycast.force_raycast_update()
	
	#Check for collision with wall
	if raycast.is_colliding():
		global_position = raycast.get_collision_point()
	else:
		global_position = caster.global_position + (caster.aim_direction * cast_distance)

func _process(delta):
	$Ring/Sprite2D.rotation += delta


func _on_explosion_timer_timeout():
	$Ring/Sprite2D.hide()
	var explosion = EXPLOSION.instantiate()
	transfer_data(explosion)
	explosion.global_position = global_position
	add_sibling(explosion)
	queue_free()
