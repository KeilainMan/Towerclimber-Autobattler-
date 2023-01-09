extends Node


var parent: Node

var attack_damage_modifier: float = 1.3
var attack_speed_modifier: float = 1.3


func _ready():
	parent = get_parent()
	_apply_buff()
	queue_free()


func _apply_buff() -> void:
	print(parent.damage, attack_damage_modifier)
	parent.damage *= attack_damage_modifier
	print(parent.damage)
	parent.attack_speed *= attack_speed_modifier
	parent.set_attackcooldowntimer(1/parent.attack_speed)
