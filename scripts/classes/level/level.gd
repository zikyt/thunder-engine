# Base level node

#@tool
@icon("./icon.svg")
extends Stage2D
class_name Level


#func _ready() -> void:
#	super()
#	if Engine.is_editor_hint(): prepare_template()

# Adding neccessary nodes to our level scene
#func prepare_template() -> void:
#	var tilemap = TileMap.new()
#	add_child(tilemap)
#	tilemap.set_owner(self)