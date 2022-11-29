extends Node2D


var direction = Vector2(3,4)

func _ready():
#	get_moving_vector()
	


func get_moving_vector():
	#var direction:Vector2 = focused_enemy.position - position 
	var dir = direction.normalized().length()
	print(dir)
