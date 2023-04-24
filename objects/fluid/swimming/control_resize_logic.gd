extends VBoxContainer

@onready var area: Area2D = $TextureRect/Area2D



func _ready() -> void:
	assert(area, "[%s]: The child_area node is not set" % get_path())
	
	if !area: return
	
	resized.connect(_set_scale)
	_set_scale()

func _set_scale() -> void:
	area.scale = get_rect().size
	area.position = make_canvas_position_local(get_rect().get_center())
