extends Camera2D
class_name DynamicCamera
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Exported Variables
@export var min_zoom := 2.
@export var max_zoom := 1.
@export var margin := Vector2(400,400) #Safe zone around players
@export var targets: Array[Node] = []

	#Onready Variables
@onready var screen_size = get_viewport_rect().size
#endregion

#region Godot methods
func _process(_delta):
	dynamic_camera(_delta)
#endregion

#region Other methods (please try to separate and organise!)

func dynamic_camera(_delta):
	if !targets or targets.size() == 0:
		return

	# Keep the camera centered among all targets
	var p = Vector2.ZERO
	for index in targets.size():
		var target = targets[index]
		if is_instance_valid(target):
			p += target.position
		else:
			targets.remove_at(index)
			break
		index += 1
	
	if targets.size() <= 0: return
	p /= targets.size()
	position = p

	# Find the zoom that will contain all targets
	var r : Rect2 = Rect2(position, Vector2.ONE)
	for target in targets:
		if is_instance_valid(target):
			r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = 1 / clamp(r.size.x / screen_size.x, max_zoom, min_zoom)
	else:
		z = 1 / clamp(r.size.y / screen_size.y, max_zoom, min_zoom)
		
	zoom = Vector2.ONE * z
	
	#get_parent().draw_cam_rect(r)

#Helper function to add targets at runtime
func add_target(object):
	if not object in targets:
		targets.append(object)

#Helper function to remove targets at runtime
func remove_target(object):
	if object in targets:
		targets.erase(object)
#endregion
