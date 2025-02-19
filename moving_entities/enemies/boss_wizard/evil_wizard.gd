extends Player
class_name ShadowWizard
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
signal wizard_hurt
signal wizard_died(wizard: Node)

@onready var nav_agent = $NavigationAgent2D

@export var is_ranged:bool = true
@export var wizard_dash_cooldown: float = 1
@export var wizard_dash_cooldown_max: float = 10

@export var default_spells: Array[Spell]

var spell_position: Vector2 = Vector2.ZERO

var element_array: Array = ["burn", "frost", "wind", "stun"]
var element_index: int

@export var enemy_raiders : Array[RaiderRes]

#endregion

#region Godot methods
func _ready():
	super._ready()
	
	remove_from_group("player")
	
	data.spells.resize(4)
	data.spell_cooldowns.resize(4)
	data.spell_cooldowns_max.resize(4)
	
	$Input.start_state_machine(nav_agent)

func _physics_process(delta):
	nav_agent.set_velocity(global_position.direction_to(nav_agent.get_next_path_position()))
	super._physics_process(delta)
	wizard_dash_cooldown -= delta
#endregion

#region Signal methods

#endregion
@rpc("authority", "call_local", "reliable")
func set_spell_element(i: int):
	element_index = i
	var element : ElementResource = SpellManager.elements[element_array[element_index]]
	for slot in default_spells.size():
		data.spells[slot] = default_spells[slot].duplicate()
		data.spells[slot].element = element
	data.main_color = element.colour.darkened(0.8)
	data.character = enemy_raiders[i]
	set_data(data, false)

func on_hurt(attack):
	super.on_hurt(attack)
	if is_multiplayer_authority():
		wizard_hurt.emit()

func _on_zero_health():
	if is_multiplayer_authority():
		wizard_died.emit(self)
		call_deferred("queue_free")

#Set move direction to direction of safe velocity
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2):
	move_direction = safe_velocity.normalized()
