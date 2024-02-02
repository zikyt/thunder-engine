@tool
extends GeneralMovementBody2D

@export var interval: float = 3
@export var jumping_height: float = 256

var jumping: bool
var as_projectile: bool

var _pos: Vector2

@onready var pos: Vector2 = global_position
@onready var timer_interval: Timer = $Interval
@onready var collision_shape_body: CollisionShape2D = $Body/CollisionShape2D


@onready var alpha: float = self_modulate.a


func _draw() -> void:
	if !Engine.is_editor_hint(): return
	if !owner: return
	if !Thunder.View.shows_tool(self): return
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE / global_scale)
	draw_line(Vector2.ZERO, Vector2.UP * jumping_height, Color.DARK_ORANGE, 4)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	
	if speed.y > 0:
		sprite_node.flip_v = true
	
	if sprite_node:
		sprite_node.visible = jumping
	collision_shape_body.set_deferred(&"disabled", !jumping)
	
	
	if as_projectile:
		super(delta)
		return
	
	if jumping:
		super(delta)
		if speed.y > 0 && (_pos - pos).dot(global_position - pos) < 0:
			global_position = pos
			_pos = global_position
			vel_set_y(0)
			jumping = false
			timer_interval.start(interval)
			return
		_pos = global_position


func _on_jump() -> void:
	var gravity: float = gravity_scale * GRAVITY
	var _speed: float = sqrt(2 * gravity * jumping_height)
	jump(_speed)
	jumping = true
	
	if !sprite_node: return
	sprite_node.flip_v = false
