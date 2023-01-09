extends Unitbase

onready var warrior_resource: Resource = preload("res://Units/Allies/Warrior/Warrior.tres")
export var ability_damage: int = 50

const ENEMIES_TO_HIT_WITH_ABILITY: int = 4

var current_ability: PackedScene = preload("res://Units/Allies/Warrior/Ability1.tscn")

func _ready() -> void:
	set_character_stats(warrior_resource)
	prepare_unit()
	

func perform_attack() -> void:
	if is_focused_enemy_viable(focused_enemy):
		if sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_2")
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()



func perform_special_ability() -> void:
	stop_attack_state()
	state = UnitState.CASTING_ABILITY
	instance_ability()
#	state = UnitState.INACTIVE
	
	
func instance_ability() -> void:
	var new_ability = current_ability.instance()
	add_child(new_ability)

