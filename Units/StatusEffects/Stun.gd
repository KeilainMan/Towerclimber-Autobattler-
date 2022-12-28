extends Node


var stun_time: float


func _init(stun_duration: float) -> void:
	stun_time = stun_duration


func _ready():
	var parent_node: Node = get_parent()
	parent_node.set_physics_process(false)
	parent_node.stop_attack_state()
	print(parent_node, "stunned for ", stun_time, " sec")
	yield(get_tree().create_timer(stun_time), "timeout")
	parent_node.set_physics_process(true)
	queue_free()


func _get_status_effect() -> String:
	return "Stun"
