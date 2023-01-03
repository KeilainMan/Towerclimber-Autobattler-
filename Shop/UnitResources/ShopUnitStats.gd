extends Resource
class_name Shop_Unit_Stats

export var character_id: int = 0
export var character_name: String = ""
export var character_discription: String = ""
export var gold_cost: int = 0
export var tier: int = 0
export var unit_count: int = 1 setget set_unit_count, get_unit_count
export var unit_level: int = 1 setget set_unit_level
export var character_pic: Texture
export(Array, String) var traits = []
export var ability_name: String = ""

export var unit_scene: PackedScene 


func increase_unit_count(increase: int) -> void:
	var new_unit_count = unit_count + increase


func set_unit_count(new_count: int) -> void:
	unit_count = new_count
	if unit_count >= 3 && unit_count < 9:
		set_unit_level(2)
	elif unit_count == 9:
		set_unit_level(3)
	else:
		return


func get_unit_count() -> int:
	return unit_count


func set_unit_level(new_level: int) -> void:
	unit_level = new_level
	print(self, unit_level)
