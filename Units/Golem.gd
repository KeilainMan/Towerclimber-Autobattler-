extends Unitbase

onready var golem_resource = load("res://Units/Golem.tres")

func _ready():
	set_character_stats(golem_resource)
	prepare_unit()


func perform_attack():
	if _check_if_enemy_exists(focused_enemy_path):
		if sprites.animation == "Attack_1":
			sprites.frame = 0
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()
