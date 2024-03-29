extends Node


export var ability_damage: int = 50
const ENEMIES_TO_HIT_WITH_ABILITY: int = 4


var parent: Node


func _ready() -> void:
	parent = get_parent()
	
	var start_position: Vector2 = parent.position
	var enemys_hit_by_ability: Array = get_enemys_hit_by_ability()
	var enemy_paths: Array = []
	
	for enemy in enemys_hit_by_ability:
		enemy_paths.append(enemy.get_path())
		
	for enemy_index in enemys_hit_by_ability.size():
		if parent.is_focused_enemy_viable(enemys_hit_by_ability[enemy_index]):
			teleport_in_front_of_enemy(enemys_hit_by_ability[enemy_index].position)
			perform_ability_damage(enemys_hit_by_ability[enemy_index])
			yield(get_tree().create_timer(0.5), "timeout")
	
	parent.position = start_position
	parent.state = parent.UnitState.INACTIVE
	queue_free()

func get_enemys_hit_by_ability() -> Array:
	var enemys_with_diffs: Array = parent.get_differences_to_enemys()
	var enemys_that_will_get_hit: Array = []
	var enemy_number: int = min(enemys_with_diffs.size(), ENEMIES_TO_HIT_WITH_ABILITY)
	
	for _i in range(enemy_number):
		var closest_enemy = find_closest_enemy_for_ability(enemys_with_diffs)
		enemys_that_will_get_hit.append(closest_enemy[0])
		enemys_with_diffs.erase(closest_enemy)
	return enemys_that_will_get_hit


func find_closest_enemy_for_ability(enemys_with_diffs) -> Array:
	var smallest: int = 100000
	var enemy_with_distance
	for i in enemys_with_diffs:
		if i[1]<smallest:
			smallest = i[1]
			enemy_with_distance = i
	return enemy_with_distance


func teleport_in_front_of_enemy(enemy_position: Vector2) -> void:
	parent.position = enemy_position - Vector2(25, 0)


func perform_ability_damage(enemy: Unitbase) -> void:
	if parent.sprites.animation == "Attack_1":
		parent._play_sprite_animation("Attack_2")
	elif !parent.sprites.animation == "Attack_1":
		parent._play_sprite_animation("Attack_1")
	enemy.receive_damage(ability_damage)
