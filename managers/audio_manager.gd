extends Node
	#class_name
#Authored by Ethan. Please consult for any modifications or major feature requests.

#region Variables
	#Signals

	#Enums

	#Constants
const POINT_AUDIO_2D = preload("res://managers/point_audio_2d.tscn")

const MUSIC = {
	"sector": [
		{
			"calm": preload("res://sounds/music/fistfight_calm.ogg"),
			"battle": preload("res://sounds/music/fistfight_battle.ogg"),
			"boss": preload("res://sounds/music/fistfight_boss.ogg"),
			"end": preload("res://sounds/music/fistfight_end.ogg")
		},
		{
			"calm": preload("res://sounds/music/cruiser_calm.ogg"),
			"battle": preload("res://sounds/music/cruiser_battle.ogg"),
			"boss": preload("res://sounds/music/cruiser_boss.ogg"),
			"end": preload("res://sounds/music/cruiser_end.ogg")
		},
		{
			"calm": preload("res://sounds/music/rollover_calm.ogg"),
			"battle": preload("res://sounds/music/rollover_battle.ogg"),
			"boss": preload("res://sounds/music/rollover_boss.ogg"),
			"end": preload("res://sounds/music/rollover_end.ogg")
		},
	],
	"shop": preload("res://sounds/music/thatoneplace.ogg"),
	"menu": preload("res://sounds/music/menu.ogg"),
	"lose": preload("res://sounds/music/you_suck.ogg"),
	"win": preload("res://sounds/music/you_rock.ogg")
}

	#Exported Variables
	#@export_group("Group")
	#@export_subgroup("Subgroup")
	
	#Onready Variables
@onready var music_stream = $MusicStream
@onready var calm_stream: AudioStreamPlayer = $CalmStream
@onready var battle_stream = $BattleStream

	

	#Other Variables (please try to separate and organise!)
var fade_tween: Tween
var switch_tween: Tween
var current_sector = -1
var last_track = ""

#endregion

#region Godot methods
#endregion

#region Signal methods

#endregion

#region Other methods (please try to separate and organise!)
func play_audio2D_at_point(position : Vector2, stream : AudioStream):
	#This method creates 2D audio with a given position and sound source
	var new_player : AudioStreamPlayer2D = POINT_AUDIO_2D.instantiate()
	new_player.position = position
	new_player.stream = stream
	get_tree().root.add_child(new_player)

func play_track_fade(key: String = ""):
	current_sector = -1
	
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(calm_stream, "volume_db", -80, 0.5)
	fade_tween.parallel().tween_property(battle_stream, "volume_db", -80, 0.5)
	fade_tween.parallel().tween_property(music_stream, "volume_db", -80, 0.5)
	if key != "":
		fade_tween.tween_callback(play_track_instant.bind(key))

func play_track_instant(key: String):
	if last_track == key:
		return
	last_track = key
	
	if fade_tween:
		fade_tween.kill()
	current_sector = -1
	
	calm_stream.stop()
	battle_stream.stop()
	
	if key != "":
		music_stream.stream = MUSIC[key]
	music_stream.volume_db = 0
	music_stream.stop()
	music_stream.play()

func play_sector(sector: int):
	if !calm_stream.playing or (sector != current_sector and sector < MUSIC.sector.size()):
		
		current_sector = sector
		last_track = "sector"+str(sector)
		
		if fade_tween:
			fade_tween.kill()
		fade_tween = create_tween()
		fade_tween.tween_property(music_stream, "volume_db", -80, 0.5)
		fade_tween.tween_callback(start_sector_music.bind(sector))

# PRIVATE FUNCTION, DO NOT CALL OUTSIDE
func start_sector_music(sector):
	current_sector = sector
	
	music_stream.stop()
		
	calm_stream.stream = MUSIC.sector[sector].calm
	calm_stream.volume_db = 0
	calm_stream.stop()
	calm_stream.play()
	
	battle_stream.stream = MUSIC.sector[sector].battle
	battle_stream.volume_db = -80
	battle_stream.stop()
	battle_stream.play()

func switch_to_calm():
	if switch_tween:
		switch_tween.kill()
	switch_tween = create_tween()
	switch_tween.set_parallel()
	switch_tween.tween_property(calm_stream, "volume_db", 0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	switch_tween.tween_property(battle_stream, "volume_db", -80, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func switch_to_battle():
	if switch_tween:
		switch_tween.kill()
	switch_tween = create_tween()
	switch_tween.set_parallel()
	switch_tween.tween_property(battle_stream, "volume_db", 0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	switch_tween.tween_property(calm_stream, "volume_db", -80, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func switch_to_boss():
	if switch_tween:
		switch_tween.kill()
	
	music_stream.stop()
	calm_stream.stop()
	battle_stream.stop()
	
	music_stream.stream = MUSIC.sector[current_sector].boss
	music_stream.volume_db = 0
	music_stream.stop()
	music_stream.play()

func switch_to_end():
	if switch_tween:
		switch_tween.kill()
	
	music_stream.stop()
	calm_stream.stop()
	battle_stream.stop()
	
	music_stream.stream = MUSIC.sector[current_sector].end
	music_stream.volume_db = 0
	music_stream.stop()
	music_stream.play()

func stop_all():
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
#endregion
