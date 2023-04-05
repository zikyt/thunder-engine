extends AnimatedSprite2D

@export var flip_as_parent: bool = true

@onready var sprite: AnimatedSprite2D = get_parent() as AnimatedSprite2D
@onready var pos_x: float = position.x


func _ready() -> void:
	if sprite:
		sprite_frames.set_animation_speed(animation, sprite.sprite_frames.get_animation_speed(sprite.animation))


func _physics_process(_delta: float) -> void:
	if flip_as_parent:
		position.x = -pos_x if sprite.flip_h else pos_x
		flip_h = sprite.flip_h
