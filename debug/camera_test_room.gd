extends Node2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	#Runs per frame
	pass
	
func _draw():
	draw_circle($DynamicCamera.position, 10, Color.CORAL)
	draw_rect(cam_rect, Color.CORAL, false, 4.0)
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
var cam_rect = Rect2()
func draw_cam_rect(r):
	cam_rect = r
	queue_redraw()
#endregion
