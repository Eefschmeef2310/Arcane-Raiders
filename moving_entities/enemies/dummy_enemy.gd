extends Entity
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")

	#Onready Variables

	#Other Variables (please try to separate and organise!)

#endregion

#region Godot methods
func _ready():
	#Runs when all children have entered the tree
	pass
	
func _process(delta):
	velocity = Vector2.LEFT * 100
	super._process(delta) #may apply effect, which may change velocity
	move_and_slide()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func _on_hurtbox_body_entered(body):
	on_hurt(body as Node2D)

func _on_hurtbox_area_entered(area):
	on_hurt(area as Node2D)
#endregion
