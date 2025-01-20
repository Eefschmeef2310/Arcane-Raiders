@tool
extends Path2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var speed : float = 0.5

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	draw.connect(_on_path_updated)
	child_order_changed.connect(_on_path_updated)
	_on_path_updated()

func _process(delta):
	for child in get_children():
		(child as PathFollow2D).progress_ratio += wrap(speed * delta, 0, 1)
#endregion

#region Signal methods
func _on_path_updated():
	for child in get_children():
		(child as PathFollow2D).progress_ratio = (child.get_index()) / float(get_child_count())
#endregion

#region Other methods (please try to separate and organise!)

#endregion
