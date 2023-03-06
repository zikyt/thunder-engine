# Node should be placed as a child of Area2D
extends Node

@export_category("EnemyAttacked")
@export_group("General")
@export_node_path("Node2D") var center_node: NodePath = ^"../.."
@export_group("Stomping","stomping_")
@export var stomping_enabled: bool = true
@export var stomping_available: bool = true
@export var stomping_hurtable: bool = true
@export var stomping_standard: Vector2 = Vector2.DOWN
@export var stomping_offset: Vector2
@export var stomping_creation: InstanceNode2D
@export var stomping_scores: int
@export var stomping_sound: AudioStream
@export var stomping_player_jumping_min: float = 500
@export var stomping_player_jumping_max: float = 700
@export_group("Killing","killing_")
@export var killing_enabled: bool = true
@export var killing_immune: Dictionary = {
	Data.ATTACKERS.head: false,
	Data.ATTACKERS.starman: false,
	Data.ATTACKERS.shell: false,
	&"shell_defence": 0, # Available only when Data.ATTACKERS.shell is "true"
	Data.ATTACKERS.fireball: false,
	Data.ATTACKERS.beetroot: false,
	Data.ATTACKERS.iceball: false,
	Data.ATTACKERS.hammer: false,
	Data.ATTACKERS.boomerang: false,
}
@export var killing_creation: InstanceNode2D
@export var killing_scores: int
@export var killing_sound_succeeded: AudioStream
@export var killing_sound_failed: AudioStream
@export_group("Extra")
## Custom vars for [member custom_scipt][br]
@export var custom_vars: Dictionary
## Custom [ByNodeScript] to extend functions
@export var custom_script: Script

var stomping_delayer: SceneTreeTimer

@onready var extra_script: Script = ByNodeScript.activate_script(custom_script, self, custom_vars)
@onready var area: Area2D = get_parent()
@onready var center: Node2D = get_node_or_null(center_node)

signal stomped
signal stomped_succeeded
signal stomped_failed
signal killed
signal killed_succeeded
signal killed_failed


func _ready() -> void:
	stomped_succeeded.connect(_lss)
	killed_succeeded.connect(_lks)
	killed_failed.connect(_lkf)

func _lss():
	Audio.play_sound(stomping_sound, center)
func _lks():
	Audio.play_sound(killing_sound_succeeded, center)
func _lkf():
	Audio.play_sound(killing_sound_failed, center)

func got_stomped(by: Node2D, offset: Vector2 = Vector2.ZERO) -> Dictionary:
	var result: Dictionary
	
	if !center:
		push_error("[No Center Node Error] No center node set. Please check if you have set the center node of EnemyAttacked. At " + str(get_path()))
		return result
	
	var dot: float = by.global_position.direction_to(
		center.global_transform.translated(stomping_offset + offset).get_origin()
	).dot(stomping_standard)
	
	if stomping_delayer: return result
	
	stomped.emit()
	
	if dot > 0 && stomping_available:
		stomped_succeeded.emit()
		
		stomping_delayer = get_tree().create_timer(get_physics_process_delta_time() * 5)
		stomping_delayer.timeout.connect(
			func() -> void:
				stomping_delayer = null
		)
		
		if stomping_scores > 0:
			ScoreText.new(str(stomping_scores), center)
			Data.values.score += stomping_scores
		
		_creation(stomping_creation)
		
		result = {
			result = true,
			jumping_min = stomping_player_jumping_min,
			jumping_max = stomping_player_jumping_max
		}
	else:
		stomped_failed.emit()
		result = {result = false}
	
	return result

func got_killed(by: StringName, special_tags:Array[StringName]) -> Dictionary:
	var result: Dictionary
	
	if !killing_enabled || !by in killing_immune: return result
	
	if killing_immune[by]:
		killed_failed.emit()
		
		result = {
			result = false,
			attackee = self
		}
	else:
		killed_succeeded.emit()
		
		_creation(killing_creation)
		
		if killing_scores > 0:
			ScoreText.new(str(killing_scores), center)
			Data.values.score += killing_scores
		
		result = {
			result = true,
			attackee = self
		}
	
	return result


func _creation(creation: InstanceNode2D) -> void:
	if !creation: return
	
	var vars: Dictionary = {enemy_attacked = self}
	NodeCreator.prepare_ins_2d(creation, center).execute_instance_script(vars).create_2d()
