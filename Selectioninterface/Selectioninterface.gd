extends Control

onready var warrior_scene = preload("res://Units/Warrior.tscn")
onready var archer_scene = preload("res://Units/Archer.tscn")
onready var golem_scene = preload("res://Units/Golem.tscn")
onready var unit_array = [warrior_scene, archer_scene, golem_scene]



onready var button_scene = preload("res://Selectioninterface/Selectable_Unit.tscn")
onready var button_holder = get_node("BottomUI/ScrollContainer/HBoxContainer")

var party:Array = [] setget set_party





onready var tween = get_node("Tween")
var hovered: bool = false
var active_position:Vector2
var hidden_position:Vector2
var active = false

signal party_set()

func _ready():
	connect("party_set", self, "_on_party_set")
	Signals.emit_signal("I_need_a_party_to_display", self)
	
#	init_unit_buttons()
	active_position = rect_position
	hidden_position = Vector2(active_position.x, active_position.y +180)
	rect_position = hidden_position
	
	Signals.connect("unit_choosen", self, "_on_unit_choosen")
	
	
	
func _on_party_set() -> void:
	print(party)
	init_unit_buttons()


func init_unit_buttons():
	for unit_number in party.size():
		var new_button = button_scene.instance()
		new_button.hold_unit = party[unit_number].unit_scene
		new_button.modulate = Color(randf(),randf(),randf(),randf())
		button_holder.add_child(new_button)
	
	
func _on_Mousedetector_mouse_entered():
	hovered = true
#	print("mouse")
#	if active:
#		tween.interpolate_property(self, "rect_position", active_position, hidden_position, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
#		active = false
#	else:
#		tween.interpolate_property(self, "rect_position", hidden_position, active_position, 0.5, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
#		active = true
#	tween.start()



func _on_ShowMenu_toggled(button_pressed):
	if button_pressed:
		rect_position = active_position
	elif !button_pressed:
		rect_position = hidden_position


func _on_unit_choosen():
	$ShowMenu.pressed = false
	

func set_party(new_party:Array) -> void:
	party = new_party
	if party.size()==0:
		party = unit_array.duplicate()
	emit_signal("party_set")
