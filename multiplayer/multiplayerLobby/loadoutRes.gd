extends Resource
class_name LoadoutRes

@export var loadout_name : String
@export var loadout_desc : String
@export var spells : Array[Spell]
# loadout desc is probably temporary, we can change this to an array of starter
# spells and display them as icons in the spot instead!
