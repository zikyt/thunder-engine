extends Control
class_name MenuSelection
## This class represents the menu item

## Is this item currently selected?
var focused: bool = false
## Played when player selects this item
@export var selected_sound: AudioStream = preload("res://engine/components/ui/_sounds/select_enter.wav")
## Trigger action name
@export var trigger_action: StringName = "ui_accept"

## Focus handler
func _handle_focused(focus: bool) -> void:
	focused = focus

## Called when this item has been selected, extend this
func _handle_select() -> void:
	if selected_sound:
		Audio.play_1d_sound(selected_sound)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(trigger_action) && focused:
		print(!focused, !get_parent().focused)
	if !focused || !get_parent().focused: return
	
	if Input.is_action_just_pressed(trigger_action):
		_handle_select()
