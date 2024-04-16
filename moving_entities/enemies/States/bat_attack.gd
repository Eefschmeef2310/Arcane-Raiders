extends State
class_name BatAttack
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
@export var prefered_range: float = 400
@export var far_range: float = 600
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var player: CharacterBody2D
#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	set_position()
	
func update(delta):
	super.update(delta)
	#enemy.attempt_cast(0)
	
func physics_update(delta):
	super.physics_update(delta)
	var distance = player.global_position.distance_to(enemy.global_position)
	if(distance > far_range):
		Transitioned.emit(self, "batchase")
	
	
func set_position():
	player = get_closest_player()
	print("position set")
	var distance = player.global_position.distance_to(enemy.global_position)
	var direction = enemy.global_position.direction_to(player.global_position)
	var final_direction: Vector2 = Vector2.ZERO
	if(distance < prefered_range): final_direction = -direction
	else: final_direction = direction
	#Add "left or right" movement using dotproduct
	
	navigation_agent.target_position = enemy.global_position + 2 * final_direction * nav_timer_interval * enemy.movement_speed
#endregion

