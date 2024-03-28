extends Node

var every_spell: Dictionary

func _ready():
	var path = "res://spells/resources/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var s = file_name.get_basename()
				every_spell[s] = load(path + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
