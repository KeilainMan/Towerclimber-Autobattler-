extends Control


onready var manabar: Node = get_node("Manabar")
onready var update_tween: Node = get_node("update_tween")


var _mana: int


signal mana_fully_charged()

func _ready() -> void:
	pass


func initialize_manabar(maximum_mana: int, starting_mana: int) -> void:
	_mana = 0
	manabar.max_value = maximum_mana
	manabar.value = starting_mana
	
	
func on_update_manabar(added_mana: int) -> void:
	print("Füge Mana hinzu: %d" % added_mana)
	if added_mana == -100:
		manabar.value = 0
		#update_tween.interpolate_property(manabar, "value", manabar.value, 0, 1.25, Tween.EASE_OUT, Tween.TRANS_LINEAR)
		#update_tween.start()
	else:
		var new_mana_value: int = manabar.value + added_mana
		#update_tween.interpolate_property(manabar, "value", manabar.value, new_mana_value, 0.25, Tween.EASE_OUT, Tween.TRANS_LINEAR)
		#update_tween.start()
		manabar.value = new_mana_value
		if manabar.value >= manabar.max_value:
			emit_signal("mana_fully_charged")
	print("Gesamt mana: %d %s" % [manabar.value, self.get_parent()])

