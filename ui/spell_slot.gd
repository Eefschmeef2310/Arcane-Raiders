extends Control
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

var i = 0
var base_arrow_pos: Vector2
var amp = 3
var freq = 10

@onready var null_icon = preload("res://spells/sprites/icons/blank_spell_icon.png")

func _ready():
	base_arrow_pos = $EquipArrow.position

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$EquipArrow.position.y = base_arrow_pos.y + (sin(i*freq)*amp)

func set_spell(spell: Spell):
	if spell:
		if spell is CombinedSpell:
			$SpellSingle.hide()
			$SpellDouble0.show()
			$SpellDouble1.show()
			$ProgressBar.texture_progress = null_icon
			
			$SpellDouble0.texture = spell.spells[0].ui_texture
			if spell.spells[0].element.gradient:
				($SpellDouble0.material as ShaderMaterial).set_shader_parameter("gradient", spell.spells[0].element.gradient)
			else:
				$SpellDouble0.self_modulate = spell.spells[0].element.colour
			
			$SpellDouble1.texture = spell.spells[1].ui_texture
			if spell.spells[1].element.gradient:
				($SpellDouble1.material as ShaderMaterial).set_shader_parameter("gradient", spell.spells[1].element.gradient)
			else:
				$SpellDouble1.self_modulate = spell.spells[1].element.colour
			
		else:
			$SpellSingle.show()
			$SpellDouble0.hide()
			$SpellDouble1.hide()
			$ProgressBar.texture_progress = spell.ui_texture
			
			$SpellSingle.texture = spell.ui_texture
			if spell.element.gradient:
				($SpellSingle.material as ShaderMaterial).set_shader_parameter("gradient", spell.element.gradient)
			else:
				$SpellSingle.self_modulate = spell.element.colour

func set_cooldown_percent(p: float):
	$ProgressBar.value = p

func change_prompt(tex: Texture2D):
	$Prompt.texture = tex
	
func hide_prompt():
	$Prompt.hide()

func show_prompt():
	$Prompt.show()

func hide_arrow():
	$EquipArrow.hide()

func show_arrow():
	$EquipArrow.show()
