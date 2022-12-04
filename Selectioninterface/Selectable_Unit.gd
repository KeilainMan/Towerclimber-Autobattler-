extends TextureRect


onready var button: Node = get_node("Button")
var hold_unit: PackedScene = null


func _ready() -> void:
	
	
	button.connect("pressed", self, "on_interface_unit_button_selected")
	
func on_interface_unit_button_selected():
	Signals.emit_signal("wants_to_place_a_unit", hold_unit)
	Signals.emit_signal("unit_choosen")
