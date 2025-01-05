extends HatUnlockCondition
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Godot methods
func _ready():
	if SaveManager.area_1_complete:
		owner.set_unlock()
#endregion
