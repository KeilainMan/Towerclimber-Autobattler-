extends Unitbase

onready var golem_resource: Resource = preload("res://Units/Allies/Golem/Golem.tres")
onready var current_ability: PackedScene = preload("res://Units/Allies/Golem/Ability1.tscn")

const ABILITY_RANGE: int = 100
const ABILITY_DAMAGE: int = 100
const STUN_DURATION: float = 5.0


func _ready():
	set_character_stats(golem_resource)
	prepare_unit()


func perform_attack() -> void:
	if is_focused_enemy_viable(focused_enemy):
		if sprites.animation == "Attack_1":
			sprites.set_frame(0)# = 0
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()


func perform_special_ability() -> void:
	stop_attack_state()
	state = UnitState.CASTING_ABILITY
	_instance_ability()


func _instance_ability() -> void:
	var new_ability = current_ability.instance()
	add_child(new_ability)

