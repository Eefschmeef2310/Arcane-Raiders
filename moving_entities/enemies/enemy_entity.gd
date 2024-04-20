extends Entity
class_name EnemyEntity
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants
@export_group("Enemy Stats")
@export var movement_speed: float = 500
@export var base_damage: int = 100

@export_group("Required Nodes")
@export var nav_agent: NavigationAgent2D
@export var state_machine : StateMachine
@export var enemy_spells: EnemySpells

var aim_direction: Vector2
var can_cast: bool = true
var nav_server_synced = false
#endregion

#region Godot methods
func _ready():
	aim_direction = Vector2(1,1)
	call_deferred("actor_setup")
	health = max_health
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)

func actor_setup():
	await get_tree().physics_frame
	nav_server_synced = true
	nav_agent.max_speed = movement_speed
	state_machine.start_state_machine(nav_agent)

func _physics_process(delta):
	if nav_server_synced:
		if !is_multiplayer_authority() or nav_agent.is_navigation_finished():
			return
		
		var current_agent_pos: Vector2 = global_position
		var next_path_pos: Vector2 = nav_agent.get_next_path_position()
		
		var intended_velocity = current_agent_pos.direction_to(next_path_pos) * movement_speed * frost_speed_scale
		
		#knockback code
		if !can_input:
			#nav_agent.set_velocity(Vector2.ZERO)
			intended_velocity = Vector2.ZERO
			
		nav_agent.set_velocity(intended_velocity + knockback_velocity * knockback_direction + attraction_direction * attraction_strength)

		knockback_velocity = lerp(knockback_velocity, 0.0, delta * knockback_timeout)
		
		if knockback_velocity < 0.01 && can_cast:
			can_input = true
#endregion

#region Signal methods
func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if is_multiplayer_authority():
		velocity = safe_velocity
		move_and_slide()
	
func _on_hurtbox_area_entered(area):
	on_hurt(area as Node2D)
	
func _on_zero_health():
	if is_multiplayer_authority():
		queue_free()
	
func attempt_cast(slot: int):
	if is_multiplayer_authority():
		if can_cast && enemy_spells.spell_cooldowns[slot] <= 0:
			use_spell(slot)

@rpc("authority", "call_local", "reliable")
func use_spell(slot: int):
	can_input = false
	can_cast = false
	#TODO Add initial start up frames so not an instant attack
	var spell_node = enemy_spells.spells[slot].scene.instantiate()
	spell_node.caster = self
	spell_node.resource = enemy_spells.spells[slot]
	add_sibling(spell_node)
	
	#Set cooldown of spell
	enemy_spells.spell_cooldowns[slot] = spell_node.cooldown_time
	
	await get_tree().create_timer(spell_node.end_time).timeout
	can_cast = true
#endregion


#region Other methods (please try to separate and organise!)

#endregion
