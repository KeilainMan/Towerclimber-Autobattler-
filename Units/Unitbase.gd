extends KinematicBody2D
class_name Unitbase

#unitorganization
onready var sprites = get_node("CharacterAnimations")
onready var collision_zone = get_node("Charactercollision")
onready var attack_range_collision = get_node("CollisionArea/CollisionShape2D")
onready var healthbar = get_node("Healthbar")
onready var manabar = get_node("Manabar")
onready var damagenumber = preload("res://Units/UI/Damageindikator.tscn")

#unit stats
var health:int = 0
var meele_damage:int = 0
var range_damage:int = 0
var ranged:bool = false
var attack_range:float = 0
var attack_speed:float = 0
var movement_speed:int = 0
var armor:int = 0 
var starting_mana:int = 0
var maximum_mana:int = 0
var relative_positions:Array = []
var traits:Array = []

export var unit_value = 0

#statemachine
enum {
	INACTIVE,
	ATTACKING,
	MOVING,
	SEARCHING_NEXT_ENEMY_TO_ATTACK,
	DEAD
}
var state = INACTIVE
var already_attacking:bool = false

#maprelevant information
var current_enemy_team:Array
var focused_enemy
var focused_enemy_path:NodePath
var units_in_attack_range:Array = []

#gameorganization
enum {
	OUTSIDE_RUN,
	INSIDE_RUN
}
var spawn_environment = OUTSIDE_RUN
onready var preparation_time:bool = false #false wenn die unit noch nicht platziert ist. 
var game_started = false
var team:String = "PLAYER"




signal damage_enemy
signal I_died
signal update_healthbar
signal update_manabar



func _ready():
	match spawn_environment:
		OUTSIDE_RUN:
			set_process(false)
			sprites.play("Idle")
		INSIDE_RUN:
			set_process(true)

	
	
	connect("update_healthbar", healthbar, "_on_update_healthbar")
	connect("update_manabar", manabar, "on_update_manabar")
	manabar.connect("mana_fully_charged", self, "_on_mana_fully_charged")

#beim instanzieren wird diese Funktion aufgerufen um der Figur zu sagen,
#ob sie in der Gilde oder im Feld ist 
func set_spawn_environment(environment):
	spawn_environment = environment
	
#wenn die Figur in der Gilde ist, dann wird beim hovern eine Animation abgespielt
func _on_Shopdetector_mouse_entered():
	if spawn_environment == OUTSIDE_RUN:
		if !sprites.animation == "Attack_1":
			sprites.play("Attack_1")
			yield(sprites, "animation_finished")
			sprites.play("Idle")
	
#setzt die stats des characters
func set_character_stats(resource):
	health = resource.health
	meele_damage = resource.meele_damage
	range_damage = resource.range_damage
	ranged = resource.ranged
	attack_range = resource.attack_range
	attack_speed = resource.attack_speed
	movement_speed = resource.movement_speed
	armor = resource.armor
	unit_value = resource.unit_value
	starting_mana = resource.starting_mana
	maximum_mana = resource.maximum_mana
	relative_positions = resource.relative_positions
	traits = resource.traits
	
	

	
func prepare_unit():
	$AttackcooldownTimer.set_wait_time(1/attack_speed)
	set_attack_range(attack_range)
	set_healthbar()
	set_manabar()
	
func set_attack_range(attack_range):
	attack_range_collision.shape.radius = attack_range
	
func set_healthbar():
	healthbar.initialize_healthbar(health)
	
func set_manabar():
	manabar.initialize_manabar(maximum_mana, starting_mana)
	


func _process(delta):
	if !preparation_time:
		return
	else:
		match state:
			INACTIVE:
				reset_figure()
				sprites.play("Idle")
				state = SEARCHING_NEXT_ENEMY_TO_ATTACK
			SEARCHING_NEXT_ENEMY_TO_ATTACK:
				determin_the_next_enemy_to_attack()
			ATTACKING:
				if already_attacking:
					return
				else:
					if _check_if_enemy_exists(focused_enemy_path):
						attack_enemy()
					else:
						reset_figure()
			MOVING:
				if _check_if_enemy_exists(focused_enemy_path):
					if attack_range > get_diff_to_enemy(focused_enemy.position) or units_in_attack_range.has(focused_enemy): 
						state = ATTACKING
						return
						
					else:
						sprites.play("Moving")
						var direction_vector = get_moving_vector()
						if direction_vector.x > 0:
							sprites.flip_h = false
						else:
							sprites.flip_h = true
#						position += 
						move_and_slide(direction_vector*movement_speed)
				else:
					reset_figure()
			DEAD:
				sprites.play("Death")
				collision_zone.set_deferred("disabled", true)
				$AttackcooldownTimer.stop()
				set_process(false)


func determin_the_next_enemy_to_attack():
	if !current_enemy_team.empty():
		var enemys_with_diffs:Array = get_differences_to_enemys()
		var closest_enemy = find_closest_enemy(enemys_with_diffs)
		focused_enemy = closest_enemy
		focused_enemy_path = focused_enemy.get_path()
		state = ATTACKING
	else:
		return


func get_differences_to_enemys():
	var all_diffs_from_enemys:Array
	for enemy in current_enemy_team:
		var diff = get_diff_to_enemy(enemy.position)
		var enemy_and_diff:Array = [enemy, diff]
		all_diffs_from_enemys.append(enemy_and_diff)
	return all_diffs_from_enemys


func get_diff_to_enemy(e_position):
	return position.distance_to(e_position)
	
	
func find_closest_enemy(enemys_with_diffs):
	var smallest = 100000
	var enemy
	for i in enemys_with_diffs:
		if i[1]<smallest:
			smallest = i[1]
			enemy = i[0]
	return enemy


func attack_enemy():
	if _check_if_enemy_exists(focused_enemy_path):
		if attack_range > get_diff_to_enemy(focused_enemy.position) or units_in_attack_range.has(focused_enemy):
			perform_attack()
			already_attacking = true
			$AttackcooldownTimer.start()
		else:
			state = MOVING
			return
	else:
		reset_figure()


func perform_attack():
	if _check_if_enemy_exists(focused_enemy_path):
		if ranged:
			focused_enemy.receive_damage(range_damage)
			get_mana(range_damage)
		else:
			focused_enemy.receive_damage(meele_damage)
			get_mana(meele_damage)
	else:
		reset_figure()
		
		
func get_mana(damage):
	var mana_value = damage/2
	emit_signal("update_manabar", mana_value)
	
	
func _on_mana_fully_charged():
	perform_special_ability()
	emit_signal("update_manabar", -100)
	

func perform_special_ability():
	print("special ability")
	
	
func _on_AttackcooldownTimer_timeout():
	perform_attack()


func _on_focused_enemy_died():
	state = INACTIVE


func receive_damage(damage):
	if health > 0:
		var resulted_damage = damage * (1-(armor * 0.06))  #15 Armor = 90% Schadenverringerung
		health -= resulted_damage
		emit_signal("update_healthbar", health)
		spawn_damagenumber(resulted_damage)
	if health <= 0:
		Signals.emit_signal("I_died", self)
		state = DEAD
		
		
func spawn_damagenumber(resulted_damage):
	var new_damagenumber = damagenumber.instance()
	new_damagenumber.global_position = position
	get_tree().current_scene.add_child(new_damagenumber)
	new_damagenumber.label.text = str(resulted_damage)
	

func get_moving_vector():
	var direction:Vector2 = focused_enemy.position - position 
	var dir = direction.normalized()
	return dir


func set_unit_to_tile(tileposition):
	set_process(false)
	preparation_time = true
	position = tileposition


func set_turn_info(turn):
	if turn == "PLAYER":
		team = "PLAYER"
	elif turn == "ENEMY":
		team = "ENEMY"
		
func start_battle_phase():
	set_process(true)
	if !preparation_time:
		preparation_time = true
		

func get_enemy_team(enemy_team):
	current_enemy_team = enemy_team
	if !current_enemy_team.has(focused_enemy):
		state = INACTIVE
	if current_enemy_team.size() == 0:
		deactivate_unit()


func deactivate_unit():
	set_process(false)
	reset_figure()


func _check_if_enemy_exists(enemy_path):
	if get_tree().get_root().has_node(enemy_path):
		return true
	else: 
		return false


func reset_figure():
	state = INACTIVE
	focused_enemy = null
	already_attacking = false
	$AttackcooldownTimer.stop()


func _on_CharacterAnimations_animation_finished():
	if sprites.animation == "Death":
		yield(get_tree().create_timer(1.5), "timeout")
		queue_free()
	else:
		return


func _on_CollisionArea_body_entered(body):
	units_in_attack_range.append(body)


func _on_CollisionArea_body_exited(body):
	units_in_attack_range.erase(body)



