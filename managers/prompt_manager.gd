extends Node

@onready var lib_keyb: PromptLibrary = preload("res://ui/prompts/keyb.tres")
@onready var lib_ps: PromptLibrary  = preload("res://ui/prompts/ps.tres")

func get_prompt_lib(id: int) -> PromptLibrary:
	if id <= -2:
		return null
		
	if id == -1:
		return lib_keyb
	
	var s = Input.get_joy_name(id)
	return lib_ps
