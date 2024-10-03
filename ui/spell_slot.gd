extends Control
class_name SpellUISlot
#Authored by Xander. Please consult for any modifications or major feature requests.

var i = 0
var base_arrow_pos: Vector2
var amp = 3
var freq = 10

@onready var null_icon = preload("res://spells/sprites/icons/blank_spell_icon.png")
@onready var shaker = $Shaker
@onready var flasher = $Flasher

@export var no_prompt = false
@export var base_alpha : float = 1

@export var element_particle : GPUParticles2D

func _ready():
	base_arrow_pos = $EquipArrow.position
	if no_prompt:
		hide_prompt()
	set_alpha(base_alpha)

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$EquipArrow.position.y = base_arrow_pos.y + (sin(i*freq)*amp)

func set_spell(spell: Spell):
	if spell:
		if spell is CombinedSpell:
			$Control/SpellSingle.hide()
			$Control/SpellDouble0.show()
			$Control/SpellDouble1.show()
			$Control/ProgressBar.texture_progress = null_icon
			
			$Control/SpellDouble0.texture = spell.spells[0].ui_texture
			if spell.spells[0].element.gradient:
				($Control/SpellDouble0.material as ShaderMaterial).set_shader_parameter("gradient", spell.spells[0].element.gradient)
			else:
				$Control/SpellDouble0.self_modulate = spell.spells[0].element.colour
			
			$Control/SpellDouble1.texture = spell.spells[1].ui_texture
			if spell.spells[1].element.gradient:
				($Control/SpellDouble1.material as ShaderMaterial).set_shader_parameter("gradient", spell.spells[1].element.gradient)
			else:
				$Control/SpellDouble1.self_modulate = spell.spells[1].element.colour
			
		else:
			$Control/SpellSingle.show()
			$Control/SpellDouble0.hide()
			$Control/SpellDouble1.hide()
			$Control/ProgressBar.texture_progress = spell.ui_texture
			
			$Control/SpellSingle.texture = spell.ui_texture
			element_particle.texture =  spell.element.pip_texture
			
			if spell.element.gradient:
				($Control/SpellSingle.material as ShaderMaterial).set_shader_parameter("gradient", spell.element.gradient)
			else:
				$Control/SpellSingle.self_modulate = spell.element.colour

func set_alpha(a):
	($Control/SpellSingle.material as ShaderMaterial).set_shader_parameter("alpha", a)

func set_cooldown_percent(p: float):
	$Control/ProgressBar.value = p

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

func shake():
	shaker.play("shake")

func pulse():
	shaker.play("pulse")

func flash():
	flasher.play("flash")

func set_particles(setting : bool):
	element_particle.emitting = setting
