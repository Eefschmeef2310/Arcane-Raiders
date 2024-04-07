extends Node

@export var elements : Dictionary
@export var spell_scenes : Dictionary
@export var reactions : Dictionary

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
	
	#Create fresh spell
	var new_spell = spell.duplicate()
	new_spell.element = element
	return new_spell

func get_spell_fron_string(s: String) -> Spell:
	var element_key = s.get_slice("-", 0)
	var spell_key = s.get_slice("-", 1)
	
	var new_spell : Spell = spell_scenes[spell_key].duplicate()
	new_spell.element = elements[element_key]
	
	return new_spell
	

func get_reaction(element_1, element_2):
	if element_1 != element_2:
		for key in reactions.keys():
			if (element_1 in key) and (element_2 in key):
				return reactions[key]
