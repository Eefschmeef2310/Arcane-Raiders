extends Node

@onready var lib_keyb: PromptLibrary = preload("res://ui/prompts/keyb.tres")
@onready var lib_ps: PromptLibrary  = preload("res://ui/prompts/ps.tres")
@onready var lib_xb: PromptLibrary  = preload("res://ui/prompts/xb.tres")
@onready var lib_sw: PromptLibrary  = preload("res://ui/prompts/sw.tres")

func get_prompt_lib(id: int) -> PromptLibrary:
	if id <= -2:
		return null
		
	if id == -1:
		return lib_keyb
	
	var joy_name = Input.get_joy_name(id).to_lower()
	if "ps" in joy_name:
		return lib_ps
	
	if "nintendo" in joy_name:
		return lib_sw
	
	return lib_xb
