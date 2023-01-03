extends Node

#RUNVARIABLES
	#party variables
var party_units: Array = []

	#reward variables
var gold: int = 1 setget set_gold, get_gold

	# levelcount
var level: int = 1 setget , get_level


func _ready():
	pass # Replace with function body.


#RUN START FUNCTIONS
	#RUNINITIALIZATION
func run_initialization():
	reset_all_run_variables()
#	get_current_party_scenes()


# resets all run specific variables to null
func reset_all_run_variables() -> void:
	gold = 1
#	party_units.clear()
	level = 1


## gets the run party from party manager
#func get_run_party() -> void:
#	var current_party = PartyManager.get_current_party()
#	for unitinfo in current_party:
#		party_units.append(unitinfo[0])
#
#
## gets the current party that is used in this run, requested by other objects
#func get_current_run_party() -> Array:
#	return party_units


# nach Abschluss eines Levels wird der Levelcounter erhöht
func increase_level() -> void:
	if level < 100:
		level += 1
	else:
		return


func increase_gold(amount: int) -> void:
	gold += amount
	Signals.emit_signal("gold_changed", gold)


func decrease_gold(amount: int) -> void:
	gold -= amount
	Signals.emit_signal("gold_changed", gold)


# andere Objecte können den Levelcounter holen
func get_level() -> int:
	return level


func set_gold(amount: int) -> void:
	gold = amount


func get_gold() -> int:
	return gold
