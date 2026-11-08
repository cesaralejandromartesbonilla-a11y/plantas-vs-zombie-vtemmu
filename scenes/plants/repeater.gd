class_name Repeater
extends Plant

## Repeater — 🌱 Repetidor (Post-MVP).
##
## Dispara 2 guisantes por ataque (en rápida sucesión).

const PEA_SCENE := preload("res://scenes/projectiles/pea.tscn")

var _timer: Timer
var _shots_fired: int = 0
var _shots_per_attack: int = 2

func _ready() -> void:
	super._ready()
	_timer = Timer.new()
	_timer.wait_time = data.fire_interval if data and data.fire_interval > 0.0 else 1.4
	_timer.timeout.connect(_try_fire)
	add_child(_timer)
	_timer.start()
	_shots_per_attack = data.shots_per_attack if data and data.shots_per_attack > 0 else 2

func _try_fire() -> void:
	if hp <= 0:
		return
	if _has_zombie_in_row():
		_shots_fired = 0
		_fire_burst()

func _has_zombie_in_row() -> bool:
	for node in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(node) and node is Zombie:
			var zombie: Zombie = node as Zombie
			if zombie.row == row:
				return true
	return false

func _fire_burst() -> void:
	if _shots_fired >= _shots_per_attack:
		return
	_fire()
	_shots_fired += 1
	# Pequeño delay entre disparos del burst (0.15 s)
	var burst_timer = Timer.new()
	burst_timer.wait_time = 0.15
	burst_timer.one_shot = true
	burst_timer.timeout.connect(_fire_burst)
	add_child(burst_timer)
	burst_timer.start()

func _fire() -> void:
	var pea = PEA_SCENE.instantiate()
	var damage = data.pea_damage if data else 20
	pea.setup(row, damage)
	pea.global_position = global_position + Vector2(30, 0)
	# AudioManager.play("shoot")  # stub
	var entities = get_tree().get_first_node_in_group("entities")
	if entities == null:
		var main = get_tree().get_first_node_in_group("main")
		if main == null:
			main = get_parent().get_parent()
		if main:
			entities = main.get_node_or_null("Entities")
	if entities == null:
		push_error("[Repeater] No se encontró nodo 'entities'")
		return
	entities.add_child(pea)

func _draw() -> void:
	var body_green := Color(0.2, 0.8, 0.3)
	var tube_green := Color(0.15, 0.6, 0.2)
	
	# Cuerpo.
	draw_circle(Vector2.ZERO, 22.0, body_green)
	
	# Dos tubos (indicador de doble disparo).
	draw_rect(Rect2(10.0, -10.0, 22.0, 8.0), tube_green)
	draw_rect(Rect2(10.0, 2.0, 22.0, 8.0), tube_green)
	
	# Ojo.
	draw_circle(Vector2(-8.0, -7.0), 5.5, Color.WHITE)
	draw_circle(Vector2(-6.0, -7.0), 2.6, Color.BLACK)
	
	# Número "2" decorativo.
	draw_string(get_theme_default_font(), Vector2(20.0, -4.0), "2", HORIZONTAL_ALIGNMENT_CENTER, -1, 12)