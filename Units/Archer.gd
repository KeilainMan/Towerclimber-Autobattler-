extends Unitbase


onready var archer_resource = load("res://Units/Archer.tres")




func _ready():
	set_character_stats(archer_resource)
	prepare_unit()



func perform_attack():
	if _check_if_enemy_exists(focused_enemy_path):
		if sprites.animation == "Attack_1":
			sprites.frame = 0
		elif !sprites.animation == "Attack_1":
			sprites.play("Attack_1")
	.perform_attack()
