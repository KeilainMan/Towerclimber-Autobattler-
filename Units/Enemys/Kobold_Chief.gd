extends Unitbase


onready var kobold_chief_resource = load("res://Units/Enemys/Kobold_Chief.tres")




func _ready():
	set_character_stats(kobold_chief_resource)
	prepare_unit()
	

func perform_attack():
	if _check_if_enemy_exists(focused_enemy_path):
		if sprites.animation == "Attack_1":
			sprites.play("Attack_2")
		elif !sprites.animation == "Attack_1":
			sprites.play("Attack_1")
	.perform_attack()
