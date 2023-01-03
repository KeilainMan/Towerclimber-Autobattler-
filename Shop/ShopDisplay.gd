extends Button

onready var held_unit: Resource 

onready var shop_display: PackedScene = preload("res://Shop/ShopDisplay.tscn")

var current_gold: int = 0 setget set_current_gold

func _init(unit: Resource) -> void:
	held_unit = unit


func _ready():
	_configure_button()
	_instance_shop_display()
	_configure_shop_display()
	connect("pressed", self, "_on_Button_pressed")
	Signals.connect("gold_changed", self, "_on_gold_changed")

func _configure_button() -> void:
	rect_min_size = Vector2(300,300)
	set_h_size_flags(3)
	set_v_size_flags(3)


func _instance_shop_display() -> void:
	var new_shop_display = shop_display.instance()
	add_child(new_shop_display)


func _configure_shop_display() -> void:
	var character_portait: Node = get_node("ShopDisplay").get_node("FullDivider").get_node("TextureRect")
	var trait_parent: Node = get_node("ShopDisplay").get_node("FullDivider").get_node("TraitDivider")
	var cost_label: Node = get_node("ShopDisplay").get_node("FullDivider").get_node("CostLabel")
	_create_trait_labels(trait_parent)
	_place_character_portrait(character_portait)
	_set_cost(cost_label)


func _create_trait_labels(trait_parent: Node) -> void:
	for trait in held_unit.traits:
		var new_label: Label = Label.new()
		
		new_label.set_text(trait)
		new_label.set_align(ALIGN_CENTER)
		new_label.set_valign(ALIGN_CENTER)
		new_label.set_h_size_flags(3)
		new_label.set_v_size_flags(3)
		
		trait_parent.add_child(new_label)


func _place_character_portrait(character_portait: Node) -> void:
	character_portait.set_texture(held_unit.character_pic)


func _set_cost(cost_label: Node) -> void:
	cost_label.set_text(str(held_unit.gold_cost))


func _on_Button_pressed():
	if held_unit.gold_cost <= current_gold:
		Signals.emit_signal("unit_purchased", held_unit)
		Signals.emit_signal("gold_spend", held_unit.gold_cost)
	else:
		print("Not enough money!")



func _on_gold_changed(gold: int) -> void:
	set_current_gold(gold)


func set_current_gold(gold: int) -> void:
	current_gold = gold
