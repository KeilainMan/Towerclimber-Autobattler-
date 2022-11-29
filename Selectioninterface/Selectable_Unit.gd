extends TextureRect


onready var button = get_node("Button")
var hold_unit = null


func _ready():
	
	
	button.connect("pressed", self, "on_interface_unit_button_selected")
	
func on_interface_unit_button_selected():
	Signals.emit_signal("wants_to_place_a_unit", hold_unit)
