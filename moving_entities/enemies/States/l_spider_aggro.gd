extends State
class_name LSpiderAggro
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)
var player: CharacterBody2D
#endregion

#region Godot methods
func update(_delta):
	#if enemy is close to the targeted player, attack em
	if(!player): return
	if(enemy.global_position.distance_to(player.global_position) < 100 && can_cast_spell(1)):
		enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
		Transitioned.emit(self, "webattack")

func physics_update(delta):
	super.physics_update(delta)
	if(!player): return
	
	#if enemy is too far away from its zone and is not low health
	if(enemy.global_position.distance_to(enemy.zone_pos) > enemy.too_far && enemy.health >= 200):
		Transitioned.emit(self, "lspiderretreat")
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	enemy.movement_speed = enemy.agrro_movespeed
	play_anim()
	set_position()
	
func set_position():
	player = get_closest_player()
	if player: navigation_agent.target_position = player.global_position
	else: Transitioned.emit(self, "lspiderretreat")
#endregion

