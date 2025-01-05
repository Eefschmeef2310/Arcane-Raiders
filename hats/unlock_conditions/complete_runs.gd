extends HatUnlockCondition
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Godot methods
func _ready():
	if SaveManager.games_played > 9:
		owner.set_unlock()
	else:
		condition_text = "Play 10 Times to Unlock!\n(" + str(10 - SaveManager.games_played) + " more plays left!)"
#endregion
