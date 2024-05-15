extends Node2D
class_name SpellPickup
#Authored by Xander. Please consult for any modifications or major feature requests.

@export var spell_string: String
@export var spell: Spell

var i = 0
@onready var sprite_2d = $Sprite2D
@onready var info_box = $InfoBox
var base_sprite_pos: Vector2
var amp = 10
var freq = 2

var target_info_modulate_a = 0

func _ready():
	i = randf_range(0, 360)
	base_sprite_pos = sprite_2d.position
	if spell_string:
		set_spell_from_string(spell_string)
	info_box.modulate.a = 0

func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$Sprite2D.position.y = base_sprite_pos.y + (sin(i*freq)*amp)
	$Outline.position.y = base_sprite_pos.y + (sin(i*freq)*amp)
	
	info_box.modulate.a = move_toward(info_box.modulate.a, target_info_modulate_a, delta*10)
	
	var cam = get_viewport().get_camera_2d()
	info_box.scale = Vector2(1,1) / cam.zoom
	

func set_spell_from_string(s):
	spell_string = s
	spell = SpellManager.get_spell_from_string(spell_string)
	$Sprite2D.texture = spell.ui_texture
	$Sprite2D.self_modulate = spell.element.colour
	$InfoBox/VBoxContainer/Name.text = spell.element.prefix + spell.suffix
	
	var string = "[center][font_size=18]" + spell.description + "[/font_size]"
	if spell.element.descrption_bb != "":
		string = string + "\n\n" + spell.element.descrption_bb
	$InfoBox/VBoxContainer/Description.text = string

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
