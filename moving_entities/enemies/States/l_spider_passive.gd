extends State
class_name LSpiderPassive
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var distance: float = 100
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var player: CharacterBody2D
var target_pos: Vector2
var direction: Vector2
#endregion

#region Godot methods

#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	enemy.movement_speed = enemy.passive_movespeed
	play_anim()
	set_position()
	
func update(_delta):
	super.update(_delta)
	if(can_cast_spell(0) && enemy.can_spawn):
		Transitioned.emit(self, "spawnnest")
	
func physics_update(_delta):
	super.physics_update(_delta)
	if(!player): return
	
	if(player.global_position.distance_to(enemy.global_position) < enemy.aggro_range || enemy.health < 200):
		Transitioned.emit(self, "lspideraggro")
		

func set_position():
	player = get_closest_player()
	if(enemy.global_position.distance_to(enemy.zone_pos) > enemy.zone_radius):
		direction = enemy.global_position.direction_to(enemy.zone_pos).rotated(deg_to_rad((randi() % 45) - 22.5))
	else: direction = Vector2.UP.rotated(randi() % 360)
	target_pos = enemy.global_position + direction * distance
	navigation_agent.target_position = target_pos
#endregion

