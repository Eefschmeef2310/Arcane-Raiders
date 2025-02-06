extends Entity
class_name EnemyEntity
#class_name
#Authored by AlexV. Please consult for any modifications or major feature requests.

#region Variables
#Signals

#Enums

#Constants
const HEALTH_PICKUP = preload("res://items/pickups/health_pickup.tscn")

#Exported variables
@export_group("Enemy Stats")
@export var movement_speed: float = 500
@export var base_damage: int = 0
#@export var health_pickup_chance = 0.2
@export var create_pickup : bool = true

@export_group("Dash Stats")
@export var dash_speed = 800

@export_group("Boss Data")
@export var is_boss: bool = false
@export var boss_name: String
@export var show_boss_bar: bool = true

@onready var state_machine = $StateMachine
@onready var nav_agent = $NavigationAgent2D
@onready var enemy_spells = $EnemySpells
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var attack_sound = $AttackSound

@export var aim_direction: Vector2
var target_area: Vector2
var can_cast: bool = true
var cast_timer_end: float = 0

var nav_server_synced = false

var is_dashing: bool = false  
var dash_timer: float = 0.0
var dash_direction: Vector2
#endregion

#region Godot methods
func _ready():
	aim_direction = Vector2(1,1)
	call_deferred("actor_setup")
	health = max_health
	nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)
	
	# Connect to room
	var room: CastleRoom = get_parent() as CastleRoom
	if is_boss and show_boss_bar:
		$ProgressBar.hide()
		if room:
			room.create_boss_bar.call_deferred(self)
	if room and room.james_mode: movement_speed *= 1.5

func actor_setup():
	if is_inside_tree():
		await get_tree().physics_frame
		nav_server_synced = true
		nav_agent.max_speed = movement_speed
		state_machine.start_state_machine(nav_agent)

func _physics_process(delta):
	if nav_server_synced:
		if !is_multiplayer_authority():
			return
		
		var current_agent_pos: Vector2 = global_position
		var next_path_pos: Vector2 = nav_agent.get_next_path_position()
		
		var intended_velocity = current_agent_pos.direction_to(next_path_pos) * movement_speed * frost_speed_scale
		
		#knockback code
		if (!can_input or nav_agent.is_navigation_finished()) and !is_dashing:
			#nav_agent.set_velocity(Vector2.ZERO)
			intended_velocity = Vector2.ZERO
			nav_agent.set_velocity(Vector2.ZERO)
			velocity = get_knockback_velocity() + get_attraction_velocity()
			move_and_slide()
		else:
			nav_agent.set_velocity(intended_velocity + get_knockback_velocity() + get_attraction_velocity())
			
		
		#Update timers
		update_dash(delta)
		
	else:
		call_deferred("actor_setup")
	
	super._physics_process(delta)
	
#endregion

#region Signal methods
func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if is_multiplayer_authority():
		velocity = safe_velocity
		move_and_slide()
	
func _on_hurtbox_area_entered(area):
	#print("hit at " + str(area.name))
	on_hurt(area as Node2D)
	
func _on_zero_health():
	if get_parent() is CastleRoom and create_pickup:
		(get_parent() as CastleRoom).server_spawn_health_pickup(global_position)
	
	if is_multiplayer_authority():
		enemy_is_dead.rpc()
	
func attempt_cast(slot: int):
	if is_multiplayer_authority():
		if can_cast && enemy_spells.spell_cooldowns[slot] <= 0:
			use_spell.rpc(slot)

@rpc("authority", "call_local", "reliable")
func use_spell(slot: int):
	#play sound
	if is_instance_valid(attack_sound):
		attack_sound.play()
	
	can_cast = false
	await get_tree().create_timer(enemy_spells.cast_time[slot]).timeout
	var spell_node = enemy_spells.spells[slot].scene.instantiate()
	spell_node.caster = self
	spell_node.resource = enemy_spells.spells[slot]
	add_sibling(spell_node)
	#Set cooldown of spell
	enemy_spells.spell_cooldowns[slot] = spell_node.cooldown_time
	await get_tree().create_timer(spell_node.end_time).timeout
	can_cast = true
	
	
func attempt_anim(anim: String):
	if animation_player:
		animation_player.stop()
		animation_player.play(anim)
		
func dash(dir: Vector2, duration: float):
	dash_direction = dir
	nav_agent.avoidance_enabled = false
	dash_timer = duration
	is_dashing = true
	velocity = dash_direction * dash_speed

func dash_to(dir: Vector2, target: Vector2) -> float:
	dash_direction = dir
	nav_agent.avoidance_enabled = false
	dash_timer = global_position.distance_to(target)/dash_speed
	is_dashing = true
	velocity = dash_direction * dash_speed
	
	return dash_timer
#endregion

#region Other methods (please try to separate and organise!)
func update_dash(delta):
	if dash_timer > 0:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		move_and_slide()
	elif is_dashing:
		dash_timer = 0
		is_dashing = false
		nav_agent.avoidance_enabled = true
		
@rpc("authority", "call_local", "reliable")
func enemy_is_dead():
	#Responsible for particles ONLY
	var particles = load("res://moving_entities/enemies/enemy_death_particles.tscn").instantiate()
	particles.global_position = global_position
	get_tree().root.add_child(particles)
	call_deferred("queue_free")
#endregion
