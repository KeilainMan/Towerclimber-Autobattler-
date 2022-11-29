extends Node


var current_team:Array = [
	#beinhaltet Arrays bestehend aus: [unitscene,level,ability]
	#[0] unitscene
	#[1] level
	#[2] ability
	
	#[unitscene,level,ability]
	#[unitscene,level,ability]
	#[unitscene,level,ability]
]


func _ready():
	pass # Replace with function body.


#PRERUN and INTERRUN PARTYASSEMBLY
	#adding a unit to the party
func permanently_add_unit_to_party(unit, level, ability):
	current_team.append([unit, level, ability])
	
	#removing a unit from the party
func permanently_remove_unit_from_party(unit):
	for unitinfo in current_team:
		if unitinfo[0] == unit:
			current_team.erase(unitinfo)
	
	#adds a abilitie to a unit
func add_ability_to_unit(unit, ability):
	for unitinfo in current_team:
		if unitinfo[0] == unit:
			unitinfo[2] = ability
			
	#updates the level of a unit
func update_unit_level(unit, new_level):
	for unitinfo in current_team:
		if unitinfo[0] == unit:
			unitinfo[1] = new_level
			
#ORGANIZATION FUNCTIONS
func get_current_party():
	return current_team
	
