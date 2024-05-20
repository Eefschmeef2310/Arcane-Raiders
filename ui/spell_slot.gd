extends TextureRect
#class_name
#Authored by Xander. Please consult for any modifications or major feature requests.

var i = 0
var base_arrow_pos: Vector2
var amp = 3
var freq = 10

func _ready():
	base_arrow_pos = $EquipArrow.position

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$EquipArrow.position.y = base_arrow_pos.y + (sin(i*freq)*amp)

func set_spell(spell: Spell):
	if spell:
		texture = spell.ui_texture
		if spell.element.gradient:
			(material as ShaderMaterial).set_shader_parameter("gradient", spell.element.gradient)
		else:
			self_modulate = spell.element.colour

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
