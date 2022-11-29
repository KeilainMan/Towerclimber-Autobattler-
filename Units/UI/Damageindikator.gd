extends Node2D

export(int) var SPEED:int = 200
export(int) var FRICTION:int = 15
var SHIFT_DIRECTION: Vector2 = Vector2.UP



onready var label = get_node("Label")

func _ready():
	pass

func _process(delta):
	global_position += SPEED * SHIFT_DIRECTION * delta
	SPEED = max(SPEED - FRICTION * delta, 0)
