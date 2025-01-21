extends Node2D
class_name SpellPickup
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var spell_string: String
@export var spell: Spell
@export var show_equip_prompt : bool = true
@export var element_description : RichTextLabel
@export var spell_description : RichTextLabel

var i = 0
@onready var icon = $Icon
@onready var info_box = $HBoxContainer
@onready var init_pos = $Shadow.scale
var base_sprite_pos: Vector2
var amp = 10
var freq = 2

var target_info_modulate_a = 0

func _ready():
	i = randf_range(0, 360)
	base_sprite_pos = icon.position
	if spell_string:
		set_spell_from_string(spell_string)
	info_box.modulate.a = 0

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$Icon.position.y = base_sprite_pos.y + (sin(i*freq)*amp)
	$Outline.position.y = base_sprite_pos.y + (sin(i*freq)*amp)
	
	var test = 1 + sin(i*2)*0.25
	$Shadow.scale = Vector2(init_pos.x*test, init_pos.y*test)
	
	info_box.modulate.a = move_toward(info_box.modulate.a, target_info_modulate_a, delta*10)
	
	var cam = get_viewport().get_camera_2d()
	info_box.scale = Vector2.ONE / cam.zoom

func set_spell_from_string(s):
	spell_string = s
	spell = SpellManager.get_spell_from_string(spell_string)
	
	if spell is CombinedSpell:
		$Icon/SpriteSingle.hide()
		$Icon/Sprite0.show()
		$Icon/Sprite1.show()
		$HBoxContainer/InfoBox1.show()
		
		$Icon/Sprite0.texture = spell.spells[0].ui_texture
		if spell.spells[0].element.gradient:
			($Icon/Sprite0.material as ShaderMaterial).set_shader_parameter("gradient", spell.spells[0].element.gradient)
		else:
			$Icon/Sprite0.self_modulate = spell.spells[0].element.colour
			
		$Icon/Sprite1.texture = spell.spells[1].ui_texture
		if spell.spells[1].element.gradient:
			($Icon/Sprite1.material as ShaderMaterial).set_shader_parameter("gradient", spell.spells[1].element.gradient)
		else:
			$Icon/Sprite1.self_modulate = spell.spells[1].element.colour
			
		$HBoxContainer/InfoBox/VBoxContainer/Name.text = spell.spells[0].element.prefix + spell.spells[0].suffix
		$HBoxContainer/InfoBox.self_modulate = spell.spells[0].element.colour
		var string = "[center][font_size=20]" + spell.spells[0].description + "[/font_size]"
		$HBoxContainer/InfoBox/VBoxContainer/Description.text = string
		
		#Set element desc.
		if spell.spells[0].element.descrption_bb != "":
			element_description.text = spell.spells[0].element.descrption_bb
		
		$HBoxContainer/InfoBox1/VBoxContainer/Name.text = spell.spells[1].element.prefix + spell.spells[1].suffix
		$HBoxContainer/InfoBox1.self_modulate = spell.spells[1].element.colour
		string = "[center][font_size=18]" + spell.spells[1].description + "[/font_size]"
		if spell.spells[1].element.descrption_bb != "":
			string = string + "\n\n" + spell.spells[1].element.descrption_bb
		$HBoxContainer/InfoBox1/VBoxContainer/Description.text = string
	else:
		$Icon/SpriteSingle.show()
		$Icon/Sprite0.hide()
		$Icon/Sprite1.hide()
		$HBoxContainer/InfoBox1.hide()
		
		$Icon/SpriteSingle.texture = spell.ui_texture
		if spell.element.gradient:
			($Icon/SpriteSingle.material as ShaderMaterial).set_shader_parameter("gradient", spell.element.gradient)
		else:
			$Icon/SpriteSingle.self_modulate = spell.element.colour
	
		$HBoxContainer/InfoBox/VBoxContainer/Name.text = spell.element.prefix + spell.suffix
		$HBoxContainer/InfoBox.self_modulate = spell.element.colour
		var string = "[center]" + spell.description
		spell_description.text = string
		
		#Set element desc.
		if spell.element.descrption_bb != "":
			element_description.text = "[center]" + spell.element.descrption_bb

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		$Outline.self_modulate = body.data.main_color
		$Outline.show()
		target_info_modulate_a = 1

func _on_area_2d_body_exited(body):
	$Outline.hide()
	target_info_modulate_a = 0
	
	if $Area2D.get_overlapping_bodies().size() <= 0:
		pass
	
	for thing in $Area2D.get_overlapping_bodies():
		if thing.is_in_group("player"):
			$Outline.show()
			target_info_modulate_a = 1
	if body.is_in_group("player"):
		$Outline.hide()
		target_info_modulate_a = 0
