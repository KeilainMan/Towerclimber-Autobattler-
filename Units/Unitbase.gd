extends KinematicBody2D
class_name Unitbase
# Override following functions:

# signals
signal damage_enemy()
signal I_died()
signal update_healthbar()
signal mana_udpated()
signal ability_casted()
signal focused_enemy_set()

# status effects
onready var stun_effect: Script = preload("res://Units/StatusEffects/Stun.gd")

# statemachine
enum UnitState {
	INACTIVE,
	SEARCHING_NEXT_ENEMY_TO_ATTACK,
	MOVING,
	ATTACKING,
	CASTING_ABILITY,
	DEAD,
	CELEBRATING,
}

# gameorganization
enum GameOrganization {
	OUTSIDE_RUN,
	INSIDE_RUN,
}

# private stats
var health: int 
var damage: int 
var ranged: bool 
var attack_range: int 
var attack_speed: float 
var movement_speed: int 
var armor: int 
var starting_mana: int 
var maximum_mana: int
var traits: Array

var current_mana: int setget set_current_mana

#public
var state = UnitState.INACTIVE setget set_state
var is_already_inactive: bool = false
var is_already_searching: bool = false
var is_already_attacking: bool = false
var is_already_casting: bool = false
var is_already_dieing: bool = false
var is_already_celebrating: bool = false

var is_targetable: bool = false setget set_targetability, get_targetability

var ongoing_ability_running: bool = false

#maprelevant information
var current_enemy_team: Array = [] setget set_current_enemy_team
var focused_enemy: Unitbase setget set_focused_enemy
var focused_enemy_path: NodePath
var enemys_in_attack_range: Array = []

var spawn_environment = GameOrganization.OUTSIDE_RUN
var game_started: bool = false
var team: String = "PLAYER"

# onready 
onready var sprites: Node = get_node("CharacterAnimations")
onready var collision_zone: Node = get_node("Charactercollision")
onready var healthbar: Node = get_node("Healthbar")
onready var manabar: Node = get_node("Manabar")
onready var damagenumber: PackedScene = preload("res://Units/UI/Damageindikator.tscn")
onready var navagent: Node = get_node("NavigationAgent2D")
onready var navtimer: Node = get_node("NavTimer")
onready var attack_range_collision_shape: Node = get_node("AttackRangeArea/AttackRangeCollisionShape")
onready var line_2d = $Line2D

onready var is_placed: bool = false 




func _ready() -> void:
	match spawn_environment:
		GameOrganization.OUTSIDE_RUN:
			set_physics_process(false)
			_play_sprite_animation("Idle")
		GameOrganization.INSIDE_RUN:
			set_physics_process(true)
	
	#Vordefinierte Signale von Nodes
	$AttackRangeArea.connect("body_shape_entered", self, "_on_body_shape_entered")
	$AttackRangeArea.connect("body_shape_exited", self, "_on_body_shape_exited")
	connect("update_healthbar", healthbar, "_on_update_healthbar")
	connect("mana_udpated", manabar, "on_mana_udpated")
	connect("focused_enemy_set", self, "_on_focused_enemy_set")
	manabar.connect("mana_fully_charged", self, "_on_mana_fully_charged")
	connect("ability_casted", self, "_on_ability_casted")
	connect("ability_casted", manabar, "_on_ability_casted")
	Signals.connect("I_died", self, "_on_unit_died")

#beim instanzieren wird diese Funktion aufgerufen um der Figur zu sagen,
#ob sie in der Gilde oder im Feld ist 
func set_spawn_environment(environment) -> void:
	spawn_environment = environment
	
#wenn die Figur in der Gilde ist, dann wird beim hovern eine Animation abgespielt
func _on_Shopdetector_mouse_entered() -> void:
	if spawn_environment == GameOrganization.OUTSIDE_RUN:
		if !sprites.animation == "Attack_1":
			_play_sprite_animation("Attack_1")
			yield(sprites, "animation_finished")
			_play_sprite_animation("Idle")
	
#setzt die stats des characters
func set_character_stats(resource: Resource) -> void:
	health = resource.health
	damage = resource.damage
	ranged = resource.ranged
	attack_range = resource.attack_range
	attack_speed = resource.attack_speed
	movement_speed = resource.movement_speed
	armor = resource.armor
	starting_mana = resource.starting_mana
	maximum_mana = resource.maximum_mana
	traits = resource.traits


func prepare_unit() -> void:
	set_attackcooldowntimer(1/attack_speed)
	_set_attack_range_collision()
	_set_healthbar()
	_set_mana_and_manabar()
	set_targetability(true)


func set_attackcooldowntimer(time: float) -> void:
	$AttackcooldownTimer.set_wait_time(time)


func _set_attack_range_collision() -> void:
	attack_range_collision_shape.shape.radius = attack_range


func _set_healthbar() -> void:
	healthbar.initialize_healthbar(health)


func _set_mana_and_manabar() -> void:
	manabar.initialize_manabar(maximum_mana, starting_mana)
	set_current_mana(starting_mana)


func _physics_process(delta) -> void:
	line_2d.global_position = Vector2.ZERO
	if not is_placed:
		return
	else:
		match state:
			UnitState.INACTIVE:
				if is_already_inactive:
					return
				_perform_state_inactive()
				#reset_figure() #Warum?

			UnitState.SEARCHING_NEXT_ENEMY_TO_ATTACK:
				if is_already_searching:
					return
				_perform_state_searching()

			UnitState.ATTACKING:
				if is_already_attacking:
					return
				_perform_state_attacking()


			UnitState.MOVING:
				if ckeck_for_targetability(focused_enemy) && !_focused_enemy_is_in_attack_range():
					_perform_state_moving()
				elif !ckeck_for_targetability(focused_enemy):
					set_state(UnitState.SEARCHING_NEXT_ENEMY_TO_ATTACK)
				elif ckeck_for_targetability(focused_enemy) && _focused_enemy_is_in_attack_range():
					set_state(UnitState.ATTACKING)
				else:
					_reset_figure()

			UnitState.CASTING_ABILITY:
				if is_already_casting:
					return
				_perform_state_casting()

			UnitState.DEAD:
				if is_already_dieing:
					return
				_perform_state_dieing()
				
			UnitState.CELEBRATING:
				if is_already_celebrating:
					return
				_perform_state_celebrating()
				


func _perform_state_inactive():
	_set_all_already_states_false()
	is_already_inactive = true
	_play_sprite_animation("Idle")
	set_state(UnitState.SEARCHING_NEXT_ENEMY_TO_ATTACK)


func _perform_state_searching():
	_set_all_already_states_false()
	is_already_searching = true
	_determin_the_next_enemy_to_attack()


func _perform_state_attacking():
	_set_all_already_states_false()
	is_already_attacking = true
	_stop_navigationtimer()
	if ckeck_for_targetability(focused_enemy):
		_attack_enemy()
	else:
		_reset_figure()


func _perform_state_moving():
	_set_all_already_states_false()
	if navagent.is_navigation_finished():
		set_state(UnitState.ATTACKING)
	if navtimer.is_stopped():
		navtimer.start()
	_play_sprite_animation("Moving")
	var targetpos: Vector2 = navagent.get_next_location()
	var direction_vector: Vector2 = position.direction_to(targetpos)
	if direction_vector.x > 0:
		sprites.flip_h = false
	else:
		sprites.flip_h = true
	var velocity: Vector2 = direction_vector * navagent.max_speed * movement_speed
	navagent.set_velocity(velocity)


func _perform_state_casting():
	_set_all_already_states_false()
	is_already_casting = true


func _perform_state_dieing():
	_set_all_already_states_false()
	is_already_dieing = true
	set_targetability(false)
	set_physics_process(false)
	collision_zone.set_deferred("disabled", true)
	_play_sprite_animation("Death")
	$AttackcooldownTimer.stop()
	
	
func _perform_state_celebrating():
	stop_attack_state()
	_set_all_already_states_false()
	is_already_celebrating = true
	deactivate_unit()
	set_physics_process(false)
	_play_sprite_animation("Idle")
	
	

func _set_all_already_states_false() -> void:
	is_already_inactive = false
	is_already_searching = false
	is_already_attacking = false
	is_already_casting = false
	is_already_dieing = false
	is_already_celebrating = false


func _set_navigation_target(target: Node) -> void:
	navagent.set_target_location(target.global_position)


func _on_NavigationAgent2D_velocity_computed(safe_velocity) -> void:
	move_and_slide(safe_velocity)
	

func _on_NavTimer_timeout() -> void:
	if ckeck_for_targetability(focused_enemy):
		navagent.set_target_location(focused_enemy.global_position)
	if !navagent.is_target_reachable():
		set_state(UnitState.INACTIVE)


func _on_NavigationAgent2D_target_reached() -> void:
	_stop_navigationtimer()

	
func _on_NavigationAgent2D_path_changed():
	line_2d.points = navagent.get_nav_path()


func _stop_navigationtimer() -> void:
	if navtimer.is_stopped():
		return
	else:
		navtimer.stop()


func _on_body_shape_entered(body_RID: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	enemys_in_attack_range.append(body)


func _on_body_shape_exited(body_RID: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if enemys_in_attack_range.has(body):
		enemys_in_attack_range.erase(body)


func _determin_the_next_enemy_to_attack() -> void:
	if not current_enemy_team.empty():
		var enemys_with_diffs: Array = get_differences_to_enemys()
		var closest_enemy = find_closest_enemy(enemys_with_diffs)
		set_focused_enemy(closest_enemy)
		focused_enemy_path = focused_enemy.get_path()


func get_differences_to_enemys() -> Array:
	var all_diffs_from_enemys: Array = []
	if _check_if_enemy_team_exists():
		for enemy in current_enemy_team:
			var diff: float = get_diff_to_enemy(enemy.position)
			var enemy_and_diff: Array = [enemy, diff]
			all_diffs_from_enemys.append(enemy_and_diff)

	return all_diffs_from_enemys


func get_diff_to_enemy(e_position: Vector2) -> float:
	return position.distance_to(e_position)


func find_closest_enemy(enemys_with_diffs: Array) -> Unitbase:
	var smallest: int = 100_000
	var closest_enemy: Unitbase
	for enemy in enemys_with_diffs:
		if enemy[1] < smallest:
			smallest = enemy[1]
			closest_enemy = enemy[0]
	return closest_enemy


func _on_focused_enemy_set():
	_set_navigation_target(focused_enemy)
	set_state(UnitState.MOVING)


func _attack_enemy() -> void:
	if ckeck_for_targetability(focused_enemy) && _focused_enemy_is_in_attack_range():
		perform_attack()
		is_already_attacking = true
		$AttackcooldownTimer.start()
	elif ckeck_for_targetability(focused_enemy) && !_focused_enemy_is_in_attack_range():
		set_state(UnitState.MOVING)
	else:
		_reset_figure()


func _focused_enemy_is_in_attack_range() -> bool:
	if enemys_in_attack_range.has(focused_enemy):
		return true
	else:
		return false


func perform_attack() -> void:
	if ckeck_for_targetability(focused_enemy) && _focused_enemy_is_in_attack_range():
			focused_enemy.receive_damage(damage)
			get_mana()
	else:
		_reset_figure()


func get_mana() -> void:
	if !ongoing_ability_running:
		var new_mana_value = current_mana + 12
		set_current_mana(new_mana_value)
	else:
		return


func _on_mana_fully_charged() -> void:
	emit_signal("ability_casted")
	perform_special_ability()
	


func perform_special_ability() -> void:
	print(self, "special ability")


func _on_ability_casted() -> void:
	set_current_mana(0)


func _on_AttackcooldownTimer_timeout() -> void:
	perform_attack()


func reset_attackcooldowntimer() -> void:
	$AttackcooldownTimer.set_wait_time(1/attack_speed)


func stop_attack_state() -> void:
	is_already_attacking = false
	$AttackcooldownTimer.stop()
	reset_attackcooldowntimer()


func receive_damage(damage: int) -> void:
	if health > 0:
		var resulted_damage: int = damage * (1 -( armor * 0.06))  #15 Armor = 90% Schadenverringerung
		health -= resulted_damage
		emit_signal("update_healthbar", health)
		spawn_damagenumber(resulted_damage)
		if health <= 0: 
			set_state(UnitState.DEAD)
			Signals.emit_signal("I_died", self)
	elif health <= 0:
		set_state(UnitState.DEAD)
		Signals.emit_signal("I_died", self)


func spawn_damagenumber(resulted_damage: int) -> void:
	var new_damagenumber = damagenumber.instance()
	new_damagenumber.global_position = position
	get_tree().current_scene.add_child(new_damagenumber)
	new_damagenumber.label.text = str(resulted_damage)


func apply_stun_effect(stun_duration: float) -> void:
	for child in get_children():
		if child.has_method("get_status_effect"):
			if child.get_status_effect() == "Stun":
				child.queue_free()
	var new_stun_effect = stun_effect.new(stun_duration)
	add_child(new_stun_effect)


func set_unit_to_tile(tileposition: Vector2):
	set_physics_process(false)
	is_placed = true
	position = tileposition


func set_turn_info(turn: String) -> void:
	if turn == "PLAYER":
		team = "PLAYER"
	elif turn == "ENEMY":
		team = "ENEMY"


func start_battle_phase() -> void:
	set_physics_process(true)
	if not is_placed:
		is_placed = true


func _on_unit_died(unit: Unitbase) -> void:
	if current_enemy_team.has(unit):
		delete_unit_from_enemy_team(unit)
		if unit == focused_enemy:
			_reset_figure()
	else:
		pass
	if current_enemy_team.empty():
		set_state(UnitState.CELEBRATING)


func delete_unit_from_enemy_team(unit: Unitbase) -> void:
	current_enemy_team.erase(unit)


func _check_if_enemy_team_exists() -> bool:
	if current_enemy_team.empty():
		return false
	else:
		return true
	

func ckeck_for_targetability(target: Unitbase) -> bool:
	if is_instance_valid(target):
		return true
	else: return false


func _reset_figure() -> void:
	set_state(UnitState.INACTIVE)
	set_focused_enemy(null)
	is_already_attacking = false
	_stop_navigationtimer()
	$AttackcooldownTimer.stop()
	reset_attackcooldowntimer()


func deactivate_unit() -> void:
	_stop_navigationtimer()
	$AttackcooldownTimer.stop()
	set_physics_process(false)
	set_targetability(false)


func _on_CharacterAnimations_animation_finished() -> void:
	if sprites.animation == "Death":
		print(self, "Deathanimation finished")
		Signals.emit_signal("already_died_please_remove", self)


# Optische Sachen
func _play_sprite_animation(animation: String) -> void:
	if animation == sprites.animation:
		return
	else:
		sprites.play(animation)


func _on_Unitbase_tree_exiting() -> void:
	queue_free()


# Setter und Getter
func set_state(new_state)-> void:
	if new_state == state:
		return
	else:
		state = new_state


func set_targetability(value: bool) -> void:
	is_targetable = value


func get_targetability() -> bool:
	return is_targetable


func set_focused_enemy(value: Unitbase) -> void:
	focused_enemy = value
	if !value == null:
		emit_signal("focused_enemy_set")


func set_current_mana(new_current_mana: int) -> void:
	current_mana = new_current_mana
	emit_signal("mana_udpated", current_mana)


func set_current_enemy_team(enemy_team: Array) -> void:
	current_enemy_team = enemy_team

