extends Unitbase

onready var warrior_resource: Resource = load("res://Units/Warrior.tres")
export var ability_damage: int = 50

const ENEMIES_TO_HIT_WITH_ABILITY: int = 4

func _ready() -> void:
	set_character_stats(warrior_resource)
	prepare_unit()
	

func perform_attack() -> void:
	if _check_if_enemy_exists(focused_enemy_path):
		if sprites.animation == "Attack_1":
			sprites.play("Attack_2")
		elif !sprites.animation == "Attack_1":
			sprites.play("Attack_1")
	.perform_attack()

#special ability: teleportiert sich zu den nächsten 4 Gegner und fügt Schaden zu (wie Alpha Strike)
func perform_special_ability() -> void:
	state = UnitState.CASTING_ABILITY
	var start_position: Vector2 = position
	var enemys_hit_by_ability: Array = get_enemys_hit_by_ability()
	var enemy_paths: Array = []
	
	for enemy in enemys_hit_by_ability:
		enemy_paths.append(enemy.get_path())
		
	for enemy_index in enemys_hit_by_ability.size():
		if _check_if_enemy_exists(enemy_paths[enemy_index]):
			teleport_in_front_of_enemy(enemys_hit_by_ability[enemy_index].position)
			perform_ability_damage(enemys_hit_by_ability[enemy_index])
			yield(get_tree().create_timer(0.5), "timeout")
	
	position = start_position
	state = UnitState.INACTIVE
	
	
func get_enemys_hit_by_ability() -> Array:
	var enemys_with_diffs: Array = get_differences_to_enemys()
	var enemys_that_will_get_hit: Array = []
	
	for _i in range(ENEMIES_TO_HIT_WITH_ABILITY):
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
	position = enemy_position - Vector2(25, 0)


func perform_ability_damage(enemy: Unitbase) -> void:
	if sprites.animation == "Attack_1":
		sprites.play("Attack_2")
	elif !sprites.animation == "Attack_1":
		sprites.play("Attack_1")
	enemy.receive_damage(ability_damage)
