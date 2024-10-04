extends Control
class_name PlayerNotif
#Authored by Xander. Please consult for any modifications or major feature requests.

@onready var label = $Label

@export var spell_box : HBoxContainer
@export var spell_rect : TextureRect
@export var spell_label : Label

@export var synergy_box : HBoxContainer
@export var element_pip : TextureRect
@export var synergy_label : Label

var move_distance = 48
var fade_time = 0.75

func _process(_delta):
	(spell_rect.material as ShaderMaterial).set_shader_parameter("alpha", modulate.a)

func start_tween():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - move_distance, fade_time)
	tween.parallel().tween_property(self, "modulate:a", 0, fade_time)
	tween.tween_callback(queue_free)

func set_recharging(_seconds: float):
	label.text = "Recharging!"
	#label.text = "Recharging! " + str(snappedf(seconds, 0.1)) + " sec"
	label.show()
	spell_box.hide()

func set_spell_ready(spell: Spell):
	if spell != null:
		spell_rect.texture = spell.ui_texture
		if spell.element.gradient:
			(spell_rect.material as ShaderMaterial).set_shader_parameter("gradient", spell.element.gradient)
		else:
			spell_rect.self_modulate = spell.element.colour
		
	label.hide()
	spell_box.show()

func init_synergy(element : ElementResource, amount : float, col : Color):
	synergy_box.visible = true
	spell_box.visible = false
	label.visible = false
	
	element_pip.texture = element.pip_texture
	synergy_label.text = "+" + str(amount) + "x synergy bonus!"
	synergy_label.add_theme_color_override("font_color", col)
