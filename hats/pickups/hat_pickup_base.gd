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
@export var info_container : Control
@export var hat_string : String
@export var highest_difficulty : RichTextLabel

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
	
	get_highest_completion_difficulty()
	
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
func get_highest_completion_difficulty():
	if is_instance_valid(highest_difficulty):
		highest_difficulty.text = "[center]Highest Completed Difficulty:"
		if SaveManager.hats_highest_difficulty_completed.has(hat_string):
			match int(SaveManager.hats_highest_difficulty_completed[hat_string]):
				0:
					highest_difficulty.text += "[color=green]\nEasy"
				1:
					highest_difficulty.text += "[color=yellow]\nMedium"
				2:
					highest_difficulty.text += "[color=red]\nHard"
				3:
					highest_difficulty.text += "[color=purple]\nExtreme"
				_:
					highest_difficulty.text = "[center]No runs completed with this hat!"
		else:
			highest_difficulty.text = "[center]No runs completed with this hat!"
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
