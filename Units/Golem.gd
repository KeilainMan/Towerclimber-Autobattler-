extends Unitbase

onready var golem_resource = load("res://Units/Golem.tres")

const ABILITY_RANGE: int = 100
const ABILITY_DAMAGE: int = 100
const STUN_DURATION: float = 5.0

func _ready():
	set_character_stats(golem_resource)
	prepare_unit()


func perform_attack() -> void:
	if is_focused_enemy_viable(focused_enemy):
		if sprites.animation == "Attack_1":
			sprites.frame = 0
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()


func perform_special_ability() -> void:
	stop_attack_state()
	state = UnitState.CASTING_ABILITY
	#ongoing_ability_running = true
	
	var enemys_hit: Array = gather_enemys_hit_by_ability()
	perform_ability_damage(enemys_hit)
	stun_enemys(enemys_hit)
	
	#ongoing_ability_running = false
	state = UnitState.INACTIVE
	

func gather_enemys_hit_by_ability() -> Array:
	var all_enemys: Array = current_enemy_team
	var all_enemys_hit_by_ability: Array = []
	for enemy in current_enemy_team:
		if focused_enemy.global_position.distance_to(enemy.global_position) < ABILITY_RANGE:
			all_enemys_hit_by_ability.append(enemy)
			
	return all_enemys_hit_by_ability


func perform_ability_damage(enemys_hit: Array)-> void:
	for enemy in enemys_hit:
		enemy.receive_damage(ABILITY_DAMAGE)


func stun_enemys(enemys_hit: Array) -> void:
	for enemy in enemys_hit:
		enemy.apply_stun_effect(STUN_DURATION)



