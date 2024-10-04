extends Control
class_name DamageNumber
#Authored by Xander. Please consult for any modifications or major feature requests.

@onready var label: Label = $Label

var _s: float = 1.0
var _number: int = 0

var tween: Tween
var random_offset : Vector2

func set_s(s: float):
	_s = s

func set_color(c: Color):
	label.add_theme_color_override("font_color", c)

func set_critical(crit: bool):
	if crit:
		set_s(2)
		label.add_theme_color_override("font_outline_color", Color.LIGHT_YELLOW)
		z_index += 1
	else:
		pass
		#set_s(1.0)
		#label.add_theme_color_override("font_outline_color", Color.BLACK)

func add(n: int):
	_number += n
	label.text = str(_number)
	animate()

func _ready():
	random_offset = Vector2(randf_range(-24, 24), randf_range(-24, 24))

func animate():
	#var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	#var dist = randf_range(0, 24)
	scale = Vector2(_s, _s)
	
	if tween:
		tween.kill()
	tween = create_tween()
	#tween.tween_property(self, "global_position", global_position + (dir*dist), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(_s*2, _s*2), 0.1)
	tween.tween_property(self, "scale", Vector2(_s, _s), 0.1)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 0, 0.1)
	tween.tween_callback(queue_free)
	
	global_position += random_offset
