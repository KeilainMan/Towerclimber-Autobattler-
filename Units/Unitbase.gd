extends KinematicBody2D
class_name Unitbase
# Override following functions:

# signals
signal damage_enemy
signal I_died
signal update_healthbar
signal update_manabar

# statemachine
enum UnitState {
	INACTIVE,
	ATTACKING,
	MOVING,
	SEARCHING_NEXT_ENEMY_TO_ATTACK,
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
var state = UnitState.INACTIVE
var already_attacking:bool = false

#maprelevant information
var current_enemy_team: Array
var focused_enemy: Unitbase
var focused_enemy_path: NodePath
var units_in_attack_range: Array = []

var spawn_environment = GameOrganization.OUTSIDE_RUN
var game_started: bool = false
var team: String = "PLAYER"

# onready 
onready var sprites: Node = get_node("CharacterAnimations")
onready var collision_zone: Node = get_node("Charactercollision")
onready var attack_range_collision: Node = get_node("CollisionArea/CollisionShape2D")
onready var healthbar: Node = get_node("Healthbar")
onready var manabar: Node = get_node("Manabar")
onready var damagenumber: Resource = preload("res://Units/UI/Damageindikator.tscn")
onready var navagent: Node = get_node("NavigationAgent2D")
onready var navtimer: Node = get_node("NavTimer")
onready var line_2d = $Line2D

onready var is_placed: bool = false 


func _ready() -> void:
	match spawn_environment:
		GameOrganization.OUTSIDE_RUN:
			set_physics_process(false)
			sprites.play("Idle")
		GameOrganization.INSIDE_RUN:
			set_physics_process(true)

	connect("update_healthbar", healthbar, "_on_update_healthbar")
	connect("update_manabar", manabar, "on_update_manabar")
	manabar.connect("mana_fully_charged", self, "_on_mana_fully_charged")

#beim instanzieren wird diese Funktion aufgerufen um der Figur zu sagen,
#ob sie in der Gilde oder im Feld ist 
func set_spawn_environment(environment) -> void:
	spawn_environment = environment
	
#wenn die Figur in der Gilde ist, dann wird beim hovern eine Animation abgespielt
func _on_Shopdetector_mouse_entered() -> void:
	if spawn_environment == GameOrganization.OUTSIDE_RUN:
		if !sprites.animation == "Attack_1":
			sprites.play("Attack_1")
			yield(sprites, "animation_finished")
			sprites.play("Idle")
	
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
	set_attack_range(attack_range)
	set_healthbar()
	set_manabar()
	
func set_attack_range(attack_range: float) -> void:
	attack_range_collision.shape.radius = attack_range
	
func set_healthbar() -> void:
	healthbar.initialize_healthbar(health)
	
func set_manabar() -> void:
	manabar.initialize_manabar(maximum_mana, starting_mana)
	
func _physics_process(delta) -> void:
	line_2d.global_position = Vector2.ZERO
	if not is_placed:
		return
	else:
		match state:
			UnitState.INACTIVE:
				reset_figure() #Warum?
				sprites.play("Idle")
				state = UnitState.SEARCHING_NEXT_ENEMY_TO_ATTACK

			UnitState.SEARCHING_NEXT_ENEMY_TO_ATTACK:
				determin_the_next_enemy_to_attack()
				state = UnitState.ATTACKING

			UnitState.ATTACKING:
				navtimer.stop()
				if already_attacking:
					return
				else:
					if _check_if_enemy_exists(focused_enemy_path):
						attack_enemy()
					else:
						reset_figure()

			UnitState.MOVING:
				if _check_if_enemy_exists(focused_enemy_path):
					if attack_range > get_diff_to_enemy(focused_enemy.position) or units_in_attack_range.has(focused_enemy): 
						state = UnitState.ATTACKING
						return
					else:
						if navagent.is_navigation_finished():
							return
						if navtimer.is_stopped():
							navtimer.start()
						sprites.play("Moving")
						var targetpos: Vector2 = navagent.get_next_location()
						var direction_vector: Vector2 = position.direction_to(targetpos)
						if direction_vector.x > 0:
							sprites.flip_h = false
						else:
							sprites.flip_h = true
						var velocity: Vector2 = direction_vector * navagent.max_speed * movement_speed
						navagent.set_velocity(velocity)
						
				else:
					reset_figure()
			UnitState.CASTING_ABILITY:
				stop_attack_state()

			UnitState.DEAD:
#				clear_enemy_team()
				sprites.play("Death")
				collision_zone.set_deferred("disabled", true)
				$AttackcooldownTimer.stop()
				set_physics_process(false)
				
				

func _on_NavigationAgent2D_velocity_computed(safe_velocity) -> void:
	move_and_slide(safe_velocity)
	

func _on_NavTimer_timeout() -> void:
	if !_check_if_enemy_exists(focused_enemy_path):
		state = UnitState.INACTIVE
	else:
		navagent.set_target_location(focused_enemy.position)
	
	
	
func _on_NavigationAgent2D_target_reached() -> void:
	navtimer.stop()

	
func _on_NavigationAgent2D_path_changed():
	line_2d.points = navagent.get_nav_path()





func determin_the_next_enemy_to_attack() -> void:
	if not current_enemy_team.empty():
		var enemys_with_diffs: Array = get_differences_to_enemys()
		var closest_enemy = find_closest_enemy(enemys_with_diffs)
		focused_enemy = closest_enemy
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


func attack_enemy() -> void:
	if _check_if_enemy_exists(focused_enemy_path):
		if attack_range > get_diff_to_enemy(focused_enemy.position) or units_in_attack_range.has(focused_enemy):
			perform_attack()
			already_attacking = true
			$AttackcooldownTimer.start()
		else:
			state = UnitState.MOVING
	else:
		reset_figure()


func perform_attack() -> void:
	if _check_if_enemy_exists(focused_enemy_path):
			focused_enemy.receive_damage(damage)
			get_mana(damage)
	else:
		reset_figure()
		
		
func get_mana(damage: int) -> void:
	var mana_value = damage / 2
	emit_signal("update_manabar", mana_value)
	
	
func _on_mana_fully_charged() -> void:
	perform_special_ability()
	emit_signal("update_manabar", -100)
	

func perform_special_ability() -> void:
	print("special ability")
	
	
func stop_attack_state() -> void:
	self.already_attacking = false
	$AttackcooldownTimer.stop()
	reset_attackcooldowntimer()
	
	
func _on_AttackcooldownTimer_timeout() -> void:
	perform_attack()
	

func reset_attackcooldowntimer() -> void:
	$AttackcooldownTimer.set_wait_time(1/attack_speed)
	

func _on_focused_enemy_died() -> void:
	state = UnitState.INACTIVE



func receive_damage(damage: int) -> void:
	if health > 0:
		var resulted_damage: int = damage * (1 -( armor * 0.06))  #15 Armor = 90% Schadenverringerung
		health -= resulted_damage
		emit_signal("update_healthbar", health)
		spawn_damagenumber(resulted_damage)
		if health <= 0: 
			state = UnitState.DEAD
			Signals.emit_signal("I_died", self)
	elif health <= 0:
		state = UnitState.DEAD
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
		

func get_enemy_team(enemy_team: Array) -> void:
	self.current_enemy_team = enemy_team
	if not self.current_enemy_team.has(focused_enemy):
		state = UnitState.INACTIVE
	if self.current_enemy_team.size() == 0:
		deactivate_unit()

func clear_enemy_team() -> void:
	current_enemy_team.clear()
	

func deactivate_unit() -> void:
	navtimer.stop()
	set_physics_process(false)
	reset_figure()


func _check_if_enemy_exists(enemy_path: NodePath) -> bool:
	return get_tree().get_root().has_node(enemy_path)


func _check_if_enemy_team_exists() -> bool:
	if current_enemy_team.empty():
		return false
	else: return true
	

func reset_figure() -> void:
	self.state = UnitState.INACTIVE
	self.focused_enemy = null
	self.already_attacking = false
	$AttackcooldownTimer.stop()
	reset_attackcooldowntimer()


func _on_CharacterAnimations_animation_finished() -> void:
	if sprites.animation == "Death":
		yield(get_tree().create_timer(1.5), "timeout")
		queue_free()


func _on_CollisionArea_body_entered(body) -> void:
	units_in_attack_range.append(body)


func _on_CollisionArea_body_exited(body) -> void:
	units_in_attack_range.erase(body)











