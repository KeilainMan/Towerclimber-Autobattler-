extends Control

onready var unit_container: Node = get_node("MarginContainer/VBoxContainer/Unitspace/HBoxContainer/Center Container/Unitcontainer")
onready var gold_label: Label = get_node("MarginContainer/VBoxContainer/Unitspace/HBoxContainer/HBoxContainer/VBoxContainer/GoldSpacer/GoldLabel")
onready var shop_display_script: Script = preload("res://Shop/ShopDisplay.gd")
onready var all_units: Array = [
	preload("res://Shop/UnitResources/ShopArcher.tres"),
	preload("res://Shop/UnitResources/ShopGolem.tres"),
	preload("res://Shop/UnitResources/ShopWarrior.tres"),
]


var current_shop_display_units: Array = []
const shop_units_number: int = 5

var current_gold: int = 0

func _ready():
	randomize()
	_roll_five_shop_units_to_display()
	var current_gold = RunManager.get_gold()
	_update_gold_label(current_gold)
	
	Signals.connect("gold_changed", self, "_on_gold_changed")


func _roll_five_shop_units_to_display() -> void:
	for n in shop_units_number:
		var new_unit = _roll_a_random_unit()
		_instance_shop_display_script(new_unit)


func _roll_a_random_unit() -> Resource:
	all_units.shuffle()
	return all_units[0]


func  _instance_shop_display_script(unit: Resource) -> void:
	var new_shop_display_script = shop_display_script.new(unit)
	unit_container.add_child(new_shop_display_script)


func _on_ReRollButtonButton_pressed():
	_reroll_shop()


func _reroll_shop() -> void:
	if current_gold >= 2:
		_free_current_shop_displays()
		_roll_five_shop_units_to_display()
		Signals.emit_signal("gold_spend", 2)
	else:
		print("Not enough gold to reroll!")


func _free_current_shop_displays() -> void:
	for child in unit_container.get_children():
		child.queue_free()


func _update_gold_label(current_gold: int) -> void:
	gold_label.text = "Gold: " + str(current_gold)


func _on_gold_changed(current_gold: int) -> void:
	_set_current_gold(current_gold)
	_update_gold_label(current_gold)
	_tell_shop_displays_how_much_gold_is_left(current_gold)


func _tell_shop_displays_how_much_gold_is_left(current_gold) -> void:
	for shop_display in unit_container.get_children():
		shop_display.set_current_gold(current_gold)

##################################################################

func _on_NextLevelButton_pressed():
	Signals.emit_signal("proceed_to_next_level")
	
	
########################################################################
func _set_current_gold(gold) -> void:
	current_gold = gold
