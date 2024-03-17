class_name Map2D extends Node2D

signal player_fast_forwarded
signal next_level_ready(index: int) ## Emitted with the next level index on ready
signal player_entered_level ## Emitted when the player enters a level.

@export
var player: NodePath
@export_group("Map Customization")
@export
var dot_style: SpriteFrames
@export
var transition_sound: AudioStream = preload("res://engine/components/ui/_sounds/fadeout.wav")
@export
var jump_button_sound: AudioStream = preload("res://engine/objects/items/coin/coin.wav")

var to_level: String
var is_fading: bool


func _ready() -> void:
	Data.values.checkpoint = -1
	Data.values.checked_cps = []
	Data.values.onetime_blocks = true
	
	var music := _get_music()
	TransitionManager.transition_middle.connect(func():
		if is_instance_valid(music): music.stop()
		TransitionManager.current_transition.paused = true
		Scenes.goto_scene(get_node(player).current_marker.level)
		Scenes.scene_ready.connect(func():
			TransitionManager.current_transition.on(Thunder._current_player)
			TransitionManager.current_transition.paused = false
		, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT | CONNECT_DEFERRED)


func get_first_marker_space() -> MarkerSpace:
	var children = get_children()
	for child in children:
		if child is MarkerSpace:
			return child
	
	return null


func _physics_process(delta: float) -> void:
	if !get_node(player): return
	if !get_node(player).reached: return
	if !get_node(player).current_marker: return
	if !get_node(player).current_marker.level: return
	if is_fading: return
	if !Input.is_action_just_pressed(&"m_jump"): return
	Audio.play_1d_sound(jump_button_sound)
	
	is_fading = true
	player_entered_level.emit()
	
	var music := _get_music()
	if music && is_instance_valid(music):
		Audio.fade_music_1d_player(music, -40, 1.0, Tween.TRANS_LINEAR, true)
	
	await get_tree().create_timer(0.4, false).timeout
	TransitionManager.accept_transition(
		load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
			.instantiate()
			.with_speeds(0.015, -0.1)
	)
	
	Audio.play_1d_sound(transition_sound)
	Data.values.erase('map_force_selected_marker')


func _get_music() -> Node:
	return Audio._music_channels[1] if 1 in Audio._music_channels else null
