extends Unitbase

onready var archer_resource: Resource = preload("res://Units/Allies/Archer/Archer.tres")
onready var current_ability: PackedScene = preload("res://Units/Allies/Archer/Ability1.tscn")
onready var ability_buff_timer: Node = get_node("AbilityBuffTimer")

export var attack_speed_modifier: float = 4 # in Prozent
export var attack_damage_modifier: float = 2 # in Prozent
export var buff_time: int = 2
var base_damage: int 
var base_attack_speed: float

func _ready():
	set_character_stats(archer_resource)
	prepare_unit()


func perform_attack():
	if is_focused_enemy_viable(focused_enemy):
		if sprites.animation == "Attack_1":
			sprites.frame = 0
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()


func perform_special_ability() -> void:
	state = UnitState.CASTING_ABILITY
	_instance_ability()
	
	
func _instance_ability() -> void:
	var new_ability = current_ability.instance()
	add_child(new_ability)
