extends Line2D
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Other methods (please try to separate and organise!)\

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "width", 0, $Timer.wait_time)

func _on_timer_timeout():
	queue_free()
#endregion
