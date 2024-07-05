extends Node2D
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const DEFAULT_FROG = preload("res://dialogic_timelines_and_characters/characters/default_frog.dch")

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export_group("Timeline")
@export var timeline: DialogicTimeline

@export_group("Node References")
@export var prompt : Label
@export var player_enter_zone : Area2D
@export var marker : Marker2D

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _process(_delta):
	if Dialogic.Styles.get_layout_node():
		print(Dialogic.Styles.get_layout_node().bubbles[1].node_to_point_at)
		pass
	

func _input(event):
	if prompt.visible and event.is_action_pressed("interact"):
		prompt.visible = false
		if !Dialogic.timeline_ended.is_connected(dialogue_ended): Dialogic.timeline_ended.connect(dialogue_ended)
		
		Dialogic.start(timeline if is_instance_valid(timeline) else "random_" + str(randi_range(0, 1))).register_character(DEFAULT_FROG, marker)
#endregion

#region Signal methods
func _on_player_enter_zone_area_entered(area):
	if area.owner is Player:
		prompt.visible = true
		
func _on_player_enter_zone_area_exited(_area):
	for ar in player_enter_zone.get_overlapping_areas():
		if ar.owner is Player:
			return
			
	#If the currently open dialogue involves this character, but no players in proximity, end the chat early
	if Dialogic.Styles.get_layout_node() and Dialogic.Styles.get_layout_node().bubbles[1].node_to_point_at.owner == self:
		Dialogic.end_timeline()
	
	prompt.visible = false

func dialogue_ended():
	Dialogic.timeline_ended.disconnect(dialogue_ended)
	for ar in player_enter_zone.get_overlapping_areas():
		if ar.owner is Player:
			prompt.visible = true
#endregion

#region Other methods (please try to separate and organise!)

#endregion
