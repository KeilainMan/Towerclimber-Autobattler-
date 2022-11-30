extends Node

#RUNVARIABLES
	#party variables
var party_units:Array = []

	#reward variables
var all_rewards:Array = []


func _ready():
	pass # Replace with function body.


#RUN START FUNCTIONS
	#RUNINITIALIZATION
func run_initialization():
	reset_all_run_variables()
	get_run_party()
	
# resets all run specific variables to null
func reset_all_run_variables():
	all_rewards.clear()
	party_units.clear()
	
# gets the run party from party manager
func get_run_party():
	var current_party = PartyManager.get_current_party()
	for unitinfo in current_party:
		party_units.append(unitinfo[0])
		
func get_current_run_party():
	return party_units
