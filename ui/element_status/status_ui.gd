extends HBoxContainer
class_name StatusUI
#Authored by Xander. Please consult for any modifications or major feature requests.

@onready var STATUS_ICON = preload("res://ui/element_status/status_icon.tscn")

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	if owner is Entity:
		var dict : Dictionary = owner.current_inflictions_dictionary
		
		# Resize number of icons if numbers mismatch
		if dict.size() != get_child_count():
			#print("!!!")
			for child in get_children():
				child.free()
			for element in dict:
				var icon = STATUS_ICON.instantiate()
				add_child(icon)
				
		# Update values
		var i = 0
		var children = get_children()
		for element in dict:
			children[i].set_data(element, dict[element])
			i += 1
		
#endregion

#region Other methods (please try to separate and organise!)

#endregion
