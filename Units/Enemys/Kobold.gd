extends Unitbase


onready var kobold_resource = load("res://Units/Enemys/Kobold.tres")




func _ready():
	set_character_stats(kobold_resource)
	prepare_unit()
	
	

func perform_attack():
	if is_focused_enemy_viable(focused_enemy):
		if sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_2")
		elif !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
	.perform_attack()


