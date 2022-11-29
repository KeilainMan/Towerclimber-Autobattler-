extends Control


onready var manabar = get_node("Manabar")
onready var update_tween = get_node("update_tween")

#var mana = 50
#var max_mana = 100

signal mana_fully_charged()

func _ready():
	pass


func initialize_manabar(maximum_mama, starting_mana):
	manabar.max_value = maximum_mama
	manabar.value = starting_mana
	
	
func on_update_manabar(added_mana):
	if added_mana == -100:
		update_tween.interpolate_property(manabar, "value", manabar.value, 0, 1.25, Tween.EASE_OUT, Tween.TRANS_LINEAR)
		update_tween.start()
	else:
		var new_mana_value = manabar.value + added_mana
		update_tween.interpolate_property(manabar, "value", manabar.value, new_mana_value, 0.25, Tween.EASE_OUT, Tween.TRANS_LINEAR)
		update_tween.start()
		if manabar.value >= manabar.max_value:
			emit_signal("mana_fully_charged")

