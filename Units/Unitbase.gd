extends KinematicBody2D
class_name Unitbase
# Override following functions:

# signals
signal damage_enemy()
signal I_died()
signal update_healthbar()
signal update_manabar()
signal focused_enemy_set()

# statemachine
enum UnitState {
	INACTIVE,
	SEARCHING_NEXT_ENEMY_TO_ATTACK,
	MOVING,
	ATTACKING,
	CASTING_ABILITY,
	DEAD,
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

#public
var state = UnitState.INACTIVE setget set_state
var is_already_inactive: bool = false
var is_already_searching: bool = false
var is_already_attacking: bool = false
var is_already_casting: bool = false
var is_already_dieing: bool = false

var is_targetable: bool = false setget set_targetability, get_targetability

#maprelevant information
var current_enemy_team: Array = []
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
onready var damagenumber: Resource = preload("res://Units/UI/Damageindikator.tscn")
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
	connect("update_manabar", manabar, "on_update_manabar")
	connect("focused_enemy_set", self, "_on_focused_enemy_set")
	manabar.connect("mana_fully_charged", self, "_on_mana_fully_charged")
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
	$AttackcooldownTimer.set_wait_time(1/attack_speed)
	_set_attack_range_collision()
	_set_healthbar()
	_set_manabar()
	set_targetability(true)


func _set_attack_range_collision() -> void:
	attack_range_collision_shape.shape.radius = attack_range


func _set_healthbar() -> void:
	healthbar.initialize_healthbar(health)


func _set_manabar() -> void:
	manabar.initialize_manabar(maximum_mana, starting_mana)


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
				if focused_enemy.get_targetability() && !_focused_enemy_is_in_attack_range():
					_perform_state_moving()
				elif !focused_enemy.get_targetability():
					set_state(UnitState.SEARCHING_NEXT_ENEMY_TO_ATTACK)
				elif focused_enemy.get_targetability() && _focused_enemy_is_in_attack_range():
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
	if focused_enemy.get_targetability():
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
	stop_attack_state()


func _perform_state_dieing():
	_set_all_already_states_false()
	is_already_dieing = true
	set_targetability(false)
	set_physics_process(false)
	collision_zone.set_deferred("disabled", true)
	_play_sprite_animation("Death")
	$AttackcooldownTimer.stop()
	

func _set_all_already_states_false() -> void:
	is_already_inactive = false
	is_already_searching = false
	is_already_attacking = false
	is_already_casting = false
	is_already_dieing = false


func _set_navigation_target(target: Node) -> void:
	navagent.set_target_location(target.global_position)


func _on_NavigationAgent2D_velocity_computed(safe_velocity) -> void:
	move_and_slide(safe_velocity)
	

func _on_NavTimer_timeout() -> void:
	if focused_enemy.get_targetability():
		navagent.set_target_location(focused_enemy.global_position)
	if !navagent.is_target_reachable():
		set_state(UnitState.INACTIVE)


func _on_NavigationAgent2D_target_reached() -> void:
	navtimer.stop()

	
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
	if focused_enemy.get_targetability() && _focused_enemy_is_in_attack_range():
		perform_attack()
		is_already_attacking = true
		$AttackcooldownTimer.start()
	elif focused_enemy.get_targetability() && !_focused_enemy_is_in_attack_range():
		set_state(UnitState.MOVING)
	else:
		_reset_figure()


func _focused_enemy_is_in_attack_range() -> bool:
	if enemys_in_attack_range.has(focused_enemy):
		return true
	else:
		return false


func perform_attack() -> void:
	if focused_enemy.get_targetability() && _focused_enemy_is_in_attack_range():
			focused_enemy.receive_damage(damage)
			get_mana(damage)
	else:
		_reset_figure()
		
		
func get_mana(damage: int) -> void:
	var mana_value = damage / 2
	emit_signal("update_manabar", mana_value)


func _on_mana_fully_charged() -> void:
	perform_special_ability()
	emit_signal("update_manabar", -100)
	

func perform_special_ability() -> void:
	print(self, "special ability")
	
	
func stop_attack_state() -> void:
	is_already_attacking = false
	$AttackcooldownTimer.stop()
	reset_attackcooldowntimer()
	
	
func _on_AttackcooldownTimer_timeout() -> void:
	perform_attack()
	

func reset_attackcooldowntimer() -> void:
	$AttackcooldownTimer.set_wait_time(1/attack_speed)
	

func _on_focused_enemy_died() -> void:
	set_state(UnitState.INACTIVE)



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
	

func get_moving_vector() -> Vector2:
	var direction: Vector2 = self.focused_enemy.position - position 
	return direction.normalized()


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
		return


func delete_unit_from_enemy_team(unit: Unitbase) -> void:
	current_enemy_team.erase(unit)
	
	
func gather_enemy_team(enemy_team: Array) -> void:
	current_enemy_team = enemy_team


func clear_enemy_team() -> void:
	current_enemy_team.clear()
	

func deactivate_unit() -> void:
	navtimer.stop()
	set_physics_process(false)
	_reset_figure()


func _check_if_enemy_exists(enemy_path: NodePath) -> bool:
	return get_tree().get_root().has_node(enemy_path)


func _check_if_enemy_team_exists() -> bool:
	if current_enemy_team.empty():
		return false
	else: return true
	

func _reset_figure() -> void:
	set_state(UnitState.INACTIVE)
	set_focused_enemy(null)
	is_already_attacking = false
	$AttackcooldownTimer.stop()
	reset_attackcooldowntimer()


func _on_CharacterAnimations_animation_finished() -> void:
	if sprites.animation == "Death":
		yield(get_tree().create_timer(1.5), "timeout")
		queue_free()


# Optische Sachen
func _play_sprite_animation(animation: String) -> void:
	if animation == sprites.animation:
		return
	else:
		sprites.play(animation)


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
