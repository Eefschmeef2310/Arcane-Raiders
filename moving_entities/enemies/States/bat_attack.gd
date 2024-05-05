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
var strafe_dir: int = 1
#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass

func _process(_delta):
	#Runs per frame
	pass
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func enter():
	set_position()
	play_anim()
	
func update(delta):
	super.update(delta)
	if player:
		if "can_dodge" in enemy:
			if enemy.can_dodge && can_cast_spell(1):
				enemy.aim_direction = enemy.global_position.direction_to(enemy.dodge_spell_pos).rotated(deg_to_rad(90))
				Transitioned.emit(self, "dodge")
				return
				
		if(can_cast_spell(0)):
			enemy.aim_direction = enemy.global_position.direction_to(player.global_position)
			Transitioned.emit(self, "attack")
	
func physics_update(delta):
	super.physics_update(delta)
	if player:
		var distance = player.global_position.distance_to(enemy.global_position)
		if(distance > far_range):
			Transitioned.emit(self, "batchase")
	
	
func set_position():
	player = get_closest_player()
	if player:
		var distance = player.global_position.distance_to(enemy.global_position)
		var direction = enemy.global_position.direction_to(player.global_position)
		var final_direction: Vector2 = Vector2.ZERO
		
		final_direction = direction if (distance > prefered_range) else -direction
		
		#Strafe direction
		final_direction = direction.rotated(deg_to_rad(90*strafe_dir))
		if (distance < prefered_range): final_direction -= direction
		
		if(randi() % 100 < 40*nav_timer_interval):
			strafe_dir *= -1
		
		navigation_agent.target_position = enemy.global_position + 2 * final_direction * nav_timer_interval * enemy.movement_speed
	else:
		Transitioned.emit(self, "idle")
#endregion

