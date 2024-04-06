extends TextureRect
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

func set_spell(spell: Spell):
	texture = spell.ui_texture
	self_modulate = spell.element.colour

func set_cooldown_percent(p: float):
	$ProgressBar.value = p

func change_prompt(tex: Texture2D):
	$Prompt.texture = tex
	
func hide_prompt():
	$Prompt.hide()

func show_prompt():
	$Prompt.show()
