# Base level node

#@tool
@icon("./icon.svg")
extends Stage2D
class_name Level

@export var time: int = 360

@export_enum("Nothing", "Death", "Wrap") var falling_below_screen_action: int = 1


func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		prepare_template()
		return
	
	Data.values.time = time

# Adding neccessary nodes to our level scene
func prepare_template() -> void:
	pass
