extends Control

onready var unitcontainer:Node = get_node("MarginContainer/VBoxContainer/Unitspace/HBoxContainer/MarginContainer2/Unitcontainer")
onready var units:Array = [
	preload("res://Units/Archer.tscn"),
	preload("res://Units/Warrior.tscn"),
	preload("res://Units/Golem.tscn")
]

#Speichern der Units, welche im Shop angezeigt werden,
#damit sie im Run genutzt werden können wenn gewollt
var unit1:PackedScene
var unit2:PackedScene
var unit3:PackedScene
var unit4:PackedScene
var unit5:PackedScene

func _ready():
	randomize()
	var child_count:int = 0
	for unitspace in unitcontainer.get_children():
		
		units.shuffle()
		var new_choosable_unit = units[0].instance()
		new_choosable_unit.set_spawn_environment(0)
		new_choosable_unit.scale *= Vector2(5,5)
		new_choosable_unit.position = Vector2(unitspace.rect_size.x/2, (3*unitspace.rect_size.y)/4)
		unitspace.add_child(new_choosable_unit)
		add_units_to_variables(units[0], child_count)
		child_count += 1
		
func add_units_to_variables(unit, child_count):
	if child_count == 0:
		unit1 = unit
	elif child_count == 1:
		unit2 = unit
	elif child_count == 2:
		unit3 = unit
	elif child_count == 3:
		unit4 = unit
	elif child_count == 4:
		unit5 = unit


func _on_BackButton_pressed():
	hide()
	


func _on_Unit1_Btn_pressed():
	PartyManager.permanently_add_unit_to_party(unit1, 1, null)

func _on_Unit2_Btn_pressed():
	PartyManager.permanently_add_unit_to_party(unit2, 1, null)

func _on_Unit3_Btn_pressed():
	PartyManager.permanently_add_unit_to_party(unit3, 1, null)

func _on_Unit4_Btn_pressed():
	PartyManager.permanently_add_unit_to_party(unit4, 1, null)

func _on_Unit5_Btn_pressed():
	PartyManager.permanently_add_unit_to_party(unit5, 1, null)
