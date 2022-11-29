extends Control


onready var bufftable = get_node("VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/VBoxContainer")


func _ready():

	Signals.connect("update_player_buff_hud", self, "_on_update_player_buff_hud")
	
	
func _on_update_player_buff_hud(buffnumbers):
	clear_labels()
	for buff in buffnumbers:
		var new_label = Label.new()
		new_label.text = buff[0] + ": " + str(buff[1])
		bufftable.add_child(new_label)


func clear_labels():
	for child in bufftable.get_children():
		child.queue_free()
