extends Resource
class_name Unit_Stats

export var health:int = 0
export var meele_damage:int = 0
export var range_damage:int = 0
export var ranged:bool = false
export var attack_range:float = 0
export var attack_speed:float = 0
export var movement_speed:int = 0
export var armor:int = 0 
export var starting_mana:int = 0
export var maximum_mana:int = 100
export(Array, Vector2) var relative_positions = [Vector2.ZERO]
export(Array, String) var traits = []

export var unit_value = 0
