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
@export_group("Bullets")
@export var bullet_scene: PackedScene
@export var cone_range_deg: float = 120
@export var bullets: int = 3

@export_group("Delay Fire")
@export var delay_fire: bool = false
@export var delay_time: float = 1
	#Onready Variables

	#Other Variables (please try to separate and organise!)
var initial_direction = Vector2.RIGHT
#endregion

#region Godot methods
func _ready():
	if caster != null:
		global_position = caster.global_position
		initial_direction = caster.aim_direction
		
	if delay_fire && $Sprite2D:
		$Sprite2D.visible = true
		var tween =  create_tween()
		tween.tween_property($Sprite2D, "scale", Vector2(2, 2), delay_time/2)
		tween.tween_property($Sprite2D, "scale", Vector2(1.5, 1.5), delay_time/2)
		await tween.finished
		
	for i in bullets:
		var bullet = bullet_scene.instantiate()
		bullet.set_direction(initial_direction.rotated(deg_to_rad(-cone_range_deg/2 + i*(cone_range_deg/(bullets-1)))))
		bullet.global_position = global_position
		transfer_data(bullet)
		add_sibling.call_deferred(bullet)
		
	queue_free()
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)

#endregion

