extends Node


const ABILITY_RANGE: int = 100
const ABILITY_DAMAGE: int = 100
const STUN_DURATION: float = 5.0

var parent: Node 


func _ready():
	parent = get_parent()

	var enemys_hit: Array = gather_enemys_hit_by_ability()
	perform_ability_damage(enemys_hit)

	parent.state = parent.UnitState.INACTIVE
	queue_free()


func gather_enemys_hit_by_ability() -> Array:
	var all_enemys: Array = parent.current_enemy_team
	var all_enemys_hit_by_ability: Array = []
	for enemy in all_enemys:
		if parent.focused_enemy.global_position.distance_to(enemy.global_position) < ABILITY_RANGE:
			all_enemys_hit_by_ability.append(enemy)
			
	return all_enemys_hit_by_ability


func perform_ability_damage(enemys_hit: Array)-> void:
	for enemy in enemys_hit:
		if parent.is_focused_enemy_viable(enemy):
			enemy.receive_damage(ABILITY_DAMAGE)
			stun_enemy(enemy)


func stun_enemy(enemy: Unitbase) -> void:
	if parent.is_focused_enemy_viable(enemy):
		enemy.apply_stun_effect(STUN_DURATION)

