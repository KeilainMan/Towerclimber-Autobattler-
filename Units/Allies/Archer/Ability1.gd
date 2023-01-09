extends Node


onready var ability_buff_timer: Node = get_node("AbilityBuffTimer")

export var attack_speed_modifier: float = 4 # in Prozent
export var attack_damage_modifier: float = 2 # in Prozent
export var buff_time: int = 2
var base_damage: int 
var base_attack_speed: float


var parent: Node


func _ready():
	parent = get_parent()
	_set_ability_buff_timer(buff_time)
	safe_pre_ability_stats()
	parent.ongoing_ability_running = true
	
	parent.damage *= attack_damage_modifier
	parent.attack_speed *= attack_speed_modifier
	parent.set_attackcooldowntimer(1/parent.attack_speed)
	ability_buff_timer.start()


func _set_ability_buff_timer(time) -> void:
	ability_buff_timer.wait_time = time


func safe_pre_ability_stats() -> void:
	base_damage = parent.damage
	base_attack_speed = parent.attack_speed


func _on_AbilityBuffTimer_timeout() -> void:
	_finish_ability()


func _reset_to_base_stats() -> void:
	parent.damage = base_damage
	parent.attack_speed = base_attack_speed
	parent.set_attackcooldowntimer(1/parent.attack_speed)


func _finish_ability() -> void:
	_reset_to_base_stats()
	ability_buff_timer.one_shot = true
	parent.ongoing_ability_running = false
	parent.state = parent.UnitState.INACTIVE
	queue_free()
