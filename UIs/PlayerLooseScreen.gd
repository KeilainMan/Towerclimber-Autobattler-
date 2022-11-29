extends Control


onready var appearance_tween = get_node("Tween")


signal Player_wants_to_return_to_the_city

func _ready():
	modulate = Color(1,1,1,0)
	appearance_tween.interpolate_property(self, "modulate", modulate, Color(1,1,1,1), 1.5, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
	appearance_tween.start()
	
	
	#connect button
	
	

func _on_ReturnToCityButton_pressed():
	emit_signal("Player_wants_to_return_to_the_city")
