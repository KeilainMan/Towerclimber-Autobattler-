extends Control


onready var manabar: Node = get_node("Manabar")
onready var update_tween: Node = get_node("update_tween")


signal mana_fully_charged()

func _ready() -> void:
	pass


func initialize_manabar(maximum_mana: int, starting_mana: int) -> void:
	manabar.max_value = maximum_mana
	manabar.value = starting_mana
	
	
func on_mana_udpated(new_mana: int) -> void:
	if !new_mana == 0:
		manabar.value = new_mana
		if manabar.value >= manabar.max_value:
			emit_signal("mana_fully_charged")
#		update_tween.interpolate_property(manabar, "value", manabar.value, 0, 1.25, Tween.EASE_OUT, Tween.TRANS_LINEAR)
#		update_tween.start()
	else:
		return
		#update_tween.interpolate_property(manabar, "value", manabar.value, new_mana, 0.25, Tween.EASE_OUT, Tween.TRANS_LINEAR)
		#update_tween.start()
		


func _on_ability_casted() -> void:
	manabar.value = 0
