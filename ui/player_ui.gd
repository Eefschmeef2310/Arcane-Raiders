extends VBoxContainer
class_name PlayerUI
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var icons_keyb: Array[Texture2D]
@export var icons_xbox: Array[Texture2D]
@export var icons_ps: Array[Texture2D]

@onready var spells: Array = [$HBox/Stats/Spells/Spell0, $HBox/Stats/Spells/Spell1, $HBox/Stats/Spells/Spell2]

@export var data: PlayerData

var input_prompts: Array

#region Godot methods
func _ready():
	if is_instance_valid(data):
		data.device_changed.connect(update_prompts)
		update_prompts(data.device_id)

func _process(delta):
	if is_instance_valid(data):
		for i in spells.size():
			var p = (data.spell_cooldowns[i] / data.spell_cooldowns_max[i]) * 100
			print(p)
			spells[i].set_cooldown_percent(p)
		
#endregion

#region Signal methods
func update_prompts(id: int):
	if id <= -2:
		print("lol")
		for spell in spells:
			spell.hide_prompt()
	else:
		var lib: PromptLibrary = PromptManager.get_prompt_lib(id)
		if lib:
			var icons = [lib.spell0, lib.spell1, lib.spell2]
			for i in spells.size():
				spells[i].show_prompt()
				spells[i].change_prompt(icons[i])
	
#endregion

#region Other methods (please try to separate and organise!)
func set_data(d: PlayerData):
	if is_instance_valid(data):
		data.device_changed.disconnect(update_prompts)
	data = d
	data.device_changed.connect(update_prompts)
	update_prompts(data.device_id)
#endregion
