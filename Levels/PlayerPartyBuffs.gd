extends Node


var all_possible_traits: Array = ["Knight", "Fighter", "Archer", "Elves", "Golem", "Hard"]
var all_trait_numbers: Array = [] # in the order of the traits of all possible traits

var all_player_party_traits: Array = []

func _ready():
	#var current_party = RunManager.get_run_party()
	#var all_traits = append_all_traits(current_party)
	#count_all_trait_numbers(all_traits)
	
	Signals.connect("Player_fielded_a_unit", self, "_on_Player_fielded_a_unit")
	Signals.connect("Player_deleted_a_unit", self, "_on_Player_deleted_a_unit")
	
func _on_Player_fielded_a_unit(unit: Unitbase) -> void:
	reset_all_trait_numbers()
	append_unit_traits(unit.traits)
	count_all_trait_numbers()
	update_buff_counter()
	
func _on_Player_deleted_a_unit(unit: Unitbase) -> void:
	reset_all_trait_numbers()
	erase_unit_traits(unit.traits)
	count_all_trait_numbers()
	update_buff_counter()
	
func reset_all_trait_numbers() -> void:
	all_trait_numbers.clear()

	
	
func append_unit_traits(traits: Array) -> void:
	all_player_party_traits.append_array(traits)
	
	
func erase_unit_traits(traits: Array) -> void:
	for individual_trait in traits:
		all_player_party_traits.erase(individual_trait)
	
	
func count_all_trait_numbers() -> void:
	for trait in all_possible_traits:
		var count: int = all_player_party_traits.count(trait)
		if count > 0:
			all_trait_numbers.append([trait, count])
		
		
func update_buff_counter() -> void:
	Signals.emit_signal("update_player_buff_hud", all_trait_numbers)
