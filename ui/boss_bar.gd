extends VBoxContainer
class_name BossBar
#Authored by Xander. Please consult for any modifications or major feature requests.

var entity: Entity

func set_entity(e: Entity):
	entity = e
	if "boss_name" in entity:
		$Name.text = entity.boss_name
	entity.zero_health.connect(_on_entity_zero_health)
	
func _ready():
	$HealthBar.custom_minimum_size.x = 0

func _process(delta):
	if is_instance_valid(entity):
		$HealthBar.max_value = entity.max_health
		$HealthBar.value = entity.health
		
		$HealthBar.custom_minimum_size.x = move_toward($HealthBar.custom_minimum_size.x, 800, 800*delta)

func _on_entity_zero_health():
	queue_free()
