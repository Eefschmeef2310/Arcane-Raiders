extends SpellBase
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables
@onready var hitbox = $Hitbox
	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	transfer_data(hitbox)
	hitbox.monitorable = false
	
	#await get_tree().create_timer(start_time).timeout
	hitbox.monitorable = true
	
	if(caster):global_position = caster.global_position
	
	await get_tree().create_timer(end_time).timeout
	queue_free()

#func _process(_delta):
	#if is_instance_valid(caster):
		#global_position = caster.global_position
	#else:
		#queue_free()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

