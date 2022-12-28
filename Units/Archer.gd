extends Unitbase

onready var archer_resource = load("res://Units/Archer.tres")

onready var ability_buff_timer: Node = get_node("AbilityBuffTimer")

export var attack_speed_modifier: float = 4 # in Prozent
export var attack_damage_modifier: float = 2 # in Prozent
export var buff_time: int = 4
var base_damage: int 
var base_attack_speed: float

func _ready():
	set_character_stats(archer_resource)
	prepare_unit()
	_set_ability_buff_timer(buff_time)

func perform_attack():
	if _check_if_enemy_exists(focused_enemy_path):
		if sprites.animation == "Attack_1":
			sprites.frame = 0
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()


func _set_ability_buff_timer(time) -> void:
	ability_buff_timer.wait_time = time


func perform_special_ability() -> void:
	state = UnitState.CASTING_ABILITY
	safe_pre_ability_stats()
	ongoing_ability_running = true
	damage *= attack_damage_modifier
	attack_speed *= attack_speed_modifier
	set_attackcooldowntimer(1/attack_speed)
	ability_buff_timer.start()
	state = UnitState.INACTIVE


func safe_pre_ability_stats() -> void:
	base_damage = damage
	base_attack_speed = attack_speed


func _on_AbilityBuffTimer_timeout() -> void:
	_finish_ability()


func _finish_ability() -> void:
	_reset_to_base_stats()
	ability_buff_timer.one_shot = true
	ongoing_ability_running = false


func _reset_to_base_stats() -> void:
	damage = base_damage
	attack_speed = base_attack_speed
	set_attackcooldowntimer(1/attack_speed)
