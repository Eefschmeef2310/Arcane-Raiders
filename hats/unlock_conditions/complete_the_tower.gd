extends HatUnlockCondition
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Godot methods
func _ready():
	if SaveManager.runs_completed > 0:
		owner.set_unlock()
#endregion
