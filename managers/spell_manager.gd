extends Node

#@export var spell_array: Array[Spell]
#var every_spell: Dictionary

@export var elements : Dictionary
@export var spell_scenes : Dictionary

func _ready():
	#for spell in spell_array:
		#every_spell[spell.resource_path.get_file().get_basename()] = spell
	#spell_array.clear()
	
	pass
	#var path = "res://spells/resources/"
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if !dir.current_is_dir():
				#var s = file_name.get_basename()
				#every_spell[s] = load(path + file_name)
			#file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")

func get_random_spell():
	#Get random element
	var element = elements[elements.keys().pick_random()]
	while element == null:
		element = elements[elements.keys().pick_random()]
		
	#Get random spell
	var spell = spell_scenes[spell_scenes.keys().pick_random()]
	while spell == null:
		spell = spell_scenes[spell_scenes.keys().pick_random()]
	
	return Spell.new(element, spell, true)
