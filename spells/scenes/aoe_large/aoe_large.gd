extends SpellBase
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

@onready var EXPLOSION = preload("res://spells/scenes/explosive/explosion.tscn")
@onready var raycast = $RayCast2D

var cast_distance: float = 200.0

func _ready():
	# Set modulation
	$Ring/Sprite2D.modulate = resource.element.colour
	
	# Setup raycast
	global_position = caster.global_position
	raycast.global_position = global_position
	raycast.target_position = global_position + (caster.aim_direction * cast_distance)
	raycast.force_raycast_update()
	
	# Check for collision with wall
	if raycast.is_colliding():
		global_position = raycast.get_collision_point()
	else:
		global_position = raycast.target_position

func _process(delta):
	$Ring.rotation += delta


func _on_explosion_timer_timeout():
	$Ring/Sprite2D.hide()
	var explosion = EXPLOSION.instantiate()
	transfer_data(explosion)
	add_sibling(explosion)
	queue_free()