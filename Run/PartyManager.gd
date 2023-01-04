extends Node
class_name Party_Manager

var units_in_party_res: Array = []




func _ready():
	Signals.connect("unit_purchased", self, "_on_unit_purchased")
	Signals.connect("I_need_a_party_to_display", self, "_on_i_need_a_party_to_display")

func _on_unit_purchased(unit_shop_res: Resource) -> void:
	if _is_unit_in_party(unit_shop_res.character_id):
		_upgrade_unit(unit_shop_res)
		print("Unit is already in Party, normally a Tierupgradefunction would take place")
	else:
		units_in_party_res.append(unit_shop_res)


func _is_unit_in_party(id: int) -> bool:
	for unit_res in units_in_party_res:
		if unit_res.character_id == id:
			return true
	return false


func _upgrade_unit(unit_shop_res) -> void:
	for unit_res in units_in_party_res:
		if unit_res.character_id == unit_shop_res.character_id:
			unit_res.increase_unit_count(1)


func get_current_party_scenes() -> Array:
	var current_party_scenes: Array = _collect_all_current_party_scenes()
	return current_party_scenes


func _collect_all_current_party_scenes() -> Array:
	var current_party_scenes: Array
	for unit_res in units_in_party_res:
		current_party_scenes.append(unit_res.unit_scene)
	return current_party_scenes


func _on_i_need_a_party_to_display(receiver) -> void:
	receiver.set_party(units_in_party_res)
	
	
#PRERUN and INTERRUN PARTYASSEMBLY
	#adding a unit to the party
#func permanently_add_unit_to_party(unit, level, ability):
#	current_team.append([unit, level, ability])
#
#	#removing a unit from the party
#func permanently_remove_unit_from_party(unit):
#	for unitinfo in current_team:
#		if unitinfo[0] == unit:
#			current_team.erase(unitinfo)
#
#	#adds a abilitie to a unit
#func add_ability_to_unit(unit, ability):
#	for unitinfo in current_team:
#		if unitinfo[0] == unit:
#			unitinfo[2] = ability
#
#	#updates the level of a unit
#func update_unit_level(unit, new_level):
#	for unitinfo in current_team:
#		if unitinfo[0] == unit:
#			unitinfo[1] = new_level
#
##ORGANIZATION FUNCTIONS
#func get_current_party():
#	return current_team
	
