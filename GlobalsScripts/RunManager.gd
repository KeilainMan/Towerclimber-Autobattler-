extends Node

#RUNVARIABLES
	#party variables
var party_units: Array = []

	#reward variables
var all_rewards: Array = []

	# levelcount
var level: int = 1


func _ready():
	pass # Replace with function body.


#RUN START FUNCTIONS
	#RUNINITIALIZATION
func run_initialization():
	reset_all_run_variables()
	get_run_party()


# resets all run specific variables to null
func reset_all_run_variables() -> void:
	all_rewards.clear()
	party_units.clear()
	level = 1


# gets the run party from party manager
func get_run_party() -> void:
	var current_party = PartyManager.get_current_party()
	for unitinfo in current_party:
		party_units.append(unitinfo[0])


# gets the current party that is used in this run, requested by other objects
func get_current_run_party() -> Array:
	return party_units

# nach Abschluss eines Levels wird der Levelcounter erhöht
func increase_level() -> void:
	if level < 100:
		level += 1
	else:
		return

# andere Objecte können den Levelcounter holen
func get_level() -> int:
	return level
