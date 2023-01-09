extends Node


var parent: Node 

export var ability_damage: int = 60


func _ready():
	parent = get_parent()
	if parent.focused_enemy.has_method("receive_damage"):
		parent.focused_enemy.receive_damage(ability_damage)
	queue_free()
	
	
	
