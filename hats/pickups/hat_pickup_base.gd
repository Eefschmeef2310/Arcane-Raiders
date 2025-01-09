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
@export var condition_box : Control
@export var condition_label : Label
@export var hat_string : String
@export var highest_difficulty : RichTextLabel
@export var unlocked = true
@export var locked_color : Color = Color.BLACK

@export var icon : Node2D
@export var unlock_condition_script : HatUnlockCondition

	#Onready Variables
@onready var init_pos = $Shadow.scale

	#Other Variables (please try to separate and organise!)
var target_info_modulate_a = 0
var i = 0
var base_sprite_pos: Vector2
var amp = 10
var freq = 2

#endregion

#region Godot methods
func _ready():
	#For the hat destroyer. checks if any hats are available. if not, it will destroy itself
	if hat_string == "":
		var unlocked_hat_found = false
		for child in owner.get_children():
			if child is HatPickup and child.unlocked and child != self:
				unlocked_hat_found = true
				break
		if !unlocked_hat_found:
			queue_free()
			return
	
	i = randf_range(0, 360)
	base_sprite_pos = icon.position
	
	get_highest_completion_difficulty()
	
	if !unlocked:
		icon.modulate = locked_color
		if is_instance_valid(unlock_condition_script):
			info_container = condition_box
			condition_label.text = unlock_condition_script.condition_text
	
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

func set_unlock():
	unlocked = true
	icon.modulate = Color.WHITE
#endregion
