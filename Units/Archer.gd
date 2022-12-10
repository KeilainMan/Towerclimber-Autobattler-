extends Unitbase

onready var archer_resource: Resource = load("res://Units/Archer.tres")
const SPECIAL_ABILITY_COUNT: int = 10

func _ready():
	set_character_stats(archer_resource)
	prepare_unit()

func perform_attack() -> void:
	if _check_if_enemy_exists(focused_enemy_path):
		if sprites.animation == "Attack_1":
			sprites.frame = 0
		elif !sprites.animation == "Attack_1":
			sprites.play("Attack_1")
	.perform_attack()


# Rapid Fire 
func perform_special_ability() -> void:
	state = UnitState.CASTING_ABILITY
	var enemy_aimed_at: Unitbase = focused_enemy
	if enemy_aimed_at == null:
		return

	for attacks in range(SPECIAL_ABILITY_COUNT) :
		if _check_if_enemy_exists(focused_enemy_path) and enemy_aimed_at.health > 0:	
			enemy_aimed_at.receive_damage(damage)
			print("Special attack number %d on enemy %s with health %d" % [attacks, enemy_aimed_at, enemy_aimed_at.health])
		else:
			break

	state = UnitState.INACTIVE
