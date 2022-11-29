extends Control


onready var timer = get_node("Despawntimer")
onready var healthbar = get_node("HealthbarOver")
onready var healthbar_for_tweening = get_node("HealthbarUnder")
onready var update_tween = get_node("update_tween")
onready var despawn_tween = get_node("despawn_tween")




func _ready():
	healthbar.visible = false
	healthbar_for_tweening.visible = false


func initialize_healthbar(health):
	healthbar.max_value = health
	healthbar.value = health
	healthbar_for_tweening.max_value = health
	healthbar_for_tweening.value = health

func _on_update_healthbar(health):
	if !healthbar.visible and !healthbar_for_tweening.visible:
		healthbar.visible = true
		healthbar_for_tweening.visible = true
	if !healthbar.modulate == Color(1,1,1,1) and !healthbar_for_tweening.modulate == Color(1,1,1,1):
		healthbar.modulate == Color(1,1,1,1)
		healthbar_for_tweening.modulate == Color(1,1,1,1)
	healthbar.value = health
	update_tween.interpolate_property(healthbar_for_tweening, "value", healthbar_for_tweening.value, health, 0.5)#, Tween.EASE_OUT, Tween.TRANS_BOUNCE)
	update_tween.start()
	reset_timer()


func reset_timer():
	if !timer.is_stopped():
		timer.stop()
	timer.set_wait_time(3)
	timer.start()


func _on_Healthbar_visibility_changed():
	if healthbar.visible:
		timer.start()


func _on_Despawntimer_timeout():
	despawn_tween.interpolate_property(self, "modulate", healthbar.modulate, Color(1,1,1,0), 0.5, Tween.EASE_IN, Tween.TRANS_LINEAR)
	despawn_tween.interpolate_property(self, "modulate", healthbar_for_tweening.modulate, Color(1,1,1,0), 0.5, Tween.EASE_IN, Tween.TRANS_LINEAR)
	despawn_tween.start()
	timer.stop()
	yield(despawn_tween, "tween_all_completed")
	healthbar.visible = false
	healthbar_for_tweening.visible = false
