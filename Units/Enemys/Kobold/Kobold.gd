extends Unitbase


onready var kobold_resource = preload("res://Units/Enemys/Kobold/Kobold.tres")

var all_special_abilities: Array = [
	preload("res://Units/Enemys/Kobold/Ability1.tscn"),
	preload("res://Units/Enemys/Kobold/Ability2.tscn"),
]
var current_special_ability: PackedScene


func _ready():
	randomize()
	set_character_stats(kobold_resource)
	select_special_ability()
	prepare_unit()
	
	

func perform_attack():
	if is_focused_enemy_viable(focused_enemy):
		if sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_2")
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()


func select_special_ability() -> void:
	all_special_abilities.shuffle()
	current_special_ability = all_special_abilities[0]
	
	
func perform_special_ability() -> void:
	stop_attack_state()
	state = UnitState.CASTING_ABILITY
	instance_ability()
	
	state = UnitState.INACTIVE


func instance_ability() -> void:
	var new_ability = current_special_ability.instance()
	print(new_ability)
	add_child(new_ability)
