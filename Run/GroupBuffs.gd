extends Node


var all_possible_traits: Array = []
var all_trait_numbers: Array = [] # in the order of the traits of all possible traits


func _ready() -> void:
	var current_party = RunManager.get_run_party()
	var all_traits = append_all_traits(current_party)
	count_all_trait_numbers(all_traits)
	
	
	
func append_all_traits(current_party: Array) -> Array:
	var all_traits:Array = []
	for partymember in current_party:
		all_traits.append_array(partymember.traits)
	return all_traits
	
	
func count_all_trait_numbers(all_traits: Array) -> void:
	for trait in all_possible_traits:
		all_trait_numbers.append([trait, all_possible_traits.count(trait)])
