extends Camera2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var move_speed := 30.
@export var zoom_speed := 10.
@export var min_zoom := 2.
@export var max_zoom := 1.
@export var margin := Vector2(400,400) #Safe zone around players

	#Onready Variables
@onready var screen_size = get_viewport_rect().size
@onready var targets = get_tree().get_nodes_in_group("player")
#endregion

#region Godot methods
func _ready():
	#dynamic_camera(-1)
	pass

func _process(delta):
	dynamic_camera(delta)
#endregion


#region Other methods (please try to separate and organise!)

func dynamic_camera(delta):
	if !targets:
		return

	# Keep the camera centered among all targets
	var p = Vector2.ZERO
	for target in targets:
		p += target.position
	p /= targets.size()
	position = lerp(position, p, move_speed * delta)

	# Find the zoom that will contain all targets
	var r = Rect2(position, Vector2.ONE)
	for target in targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = 1 / clamp(r.size.x / screen_size.x, max_zoom, min_zoom)
	else:
		z = 1 / clamp(r.size.y / screen_size.y, max_zoom, min_zoom)
		
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed * delta)
	
	#get_parent().draw_cam_rect(r)

#Helper function to add targets at runtime
func add_target(object):
	if not object in targets:
		targets.append(object)

#Helper function to remove targets at runtime
func remove_target(object):
	if object in targets:
		targets.remove(object)
#endregion
