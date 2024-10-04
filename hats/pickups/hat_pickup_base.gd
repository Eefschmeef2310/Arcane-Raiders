extends Node
class_name HatPickup #THIS MUST BE A SEPARATE CLASS BCS THIS SCRIPT IS USED FOR THE HAT DESTROYER
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var info_container : HBoxContainer
@export var show_equip_prompt : bool = false
@export var hat_string : String

	#Onready Variables
@onready var init_pos = $Shadow.scale
@onready var icon = $Icon

	#Other Variables (please try to separate and organise!)
var target_info_modulate_a = 0
var i = 0
var base_sprite_pos: Vector2
var amp = 10
var freq = 2

#endregion

#region Godot methods
func _ready():
	i = randf_range(0, 360)
	base_sprite_pos = icon.position
	
func _process(delta):
	i += delta
	if i > 360:
		i -= 360
	$Icon.position.y = base_sprite_pos.y + (sin(i*freq)*amp)
	$Outline.position.y = base_sprite_pos.y + (sin(i*freq)*amp)
	
	if info_container:
		info_container.modulate.a = move_toward(info_container.modulate.a, target_info_modulate_a, delta*10)
	
	var test = 1 + sin(i*2)*0.25
	$Shadow.scale = Vector2(init_pos.x*test, init_pos.y*test)
#endregion

#region Signal methods
func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
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
#endregion

#region Other methods (please try to separate and organise!)
#func pickup_function(player):
	#for child in player.get_children():
		#if child is Hat:
			#child.queue_free()
			#player.crown.texture = null
	#
	#if hat_string:
		#var hat = HatManager.get_hat_from_string(hat_string).instantiate()
		#player.add_child(hat)
		#player.data.hat_sprite = hat.sprite
	#else:
		#player.data.hat_sprite = null
#endregion
