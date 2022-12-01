extends Resource
class_name Unit_Stats

# Character Info, hpts. für den Shop
export var character_name: String = ""
export var character_discription: String = ""

# Character Stats
export var health: int = 0
export var damage: int = 0
export var ranged: bool = false
export var attack_range: int = 0
export var attack_speed: float = 0
export var movement_speed: int = 0
export var armor: int = 0 
export var starting_mana: int = 0
export var maximum_mana: int = 100
export(Array, String) var traits = []


