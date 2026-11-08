class_name SnowPea
extends Plant

## SnowPea — 🌨️ Lanzaguisantes de Hielo (Post-MVP).
##
## Dispara guisantes que ralentizan zombies (factor 0.5 por 3 s).
## Hereda la lógica de disparo de Peashooter y añade el efecto slow.

const PEA_SCENE := preload("res://scenes/projectiles/snowpea_projectile.tscn")

func _ready() -> void:
	super._ready()
	# Timer propio para disparar (reutiliza la lógica base)
	_timer = Timer.new()
	_timer.wait_time = data.fire_interval if data and data.fire_interval > 0.0 else 1.4
	_timer.timeout.connect(_try_fire)
	add_child(_timer)
	_timer.start()

func _try_fire() -> void:
	if hp <= 0:
		return
	if _has_zombie_in_row():
		_fire()

func _has_zombie_in_row() -> bool:
	for node in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(node) and node is Zombie:
			var zombie: Zombie = node as Zombie
			if zombie.row == row:
				return true
	return false

func _fire() -> void:
	var pea = PEA_SCENE.instantiate()
	var damage = data.pea_damage if data else 20
	var slow = data.slow_factor if data else 0.5
	var duration = data.slow_duration if data else 3.0
	pea.setup(row, damage, slow, duration)
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
		push_error("[SnowPea] No se encontró nodo 'entities'")
		return
	entities.add_child(pea)

func _draw() -> void:
	var body_blue := Color(0.3, 0.6, 0.9)
	var tube_blue := Color(0.2, 0.45, 0.7)
	
	# Cuerpo.
	draw_circle(Vector2.ZERO, 22.0, body_blue)
	
	# Tubo/boca hacia la derecha.
	draw_rect(Rect2(10.0, -6.0, 22.0, 12.0), tube_blue)
	
	# Ojo (mira hacia la derecha).
	draw_circle(Vector2(-8.0, -7.0), 5.5, Color.WHITE)
	draw_circle(Vector2(-6.0, -7.0), 2.6, Color.BLACK)
	
	# Copo de nieve decorativo.
	draw_circle(Vector2(18.0, -12.0), 6.0, Color(0.8, 0.9, 1.0))
	draw_circle(Vector2(18.0, -12.0), 3.0, body_blue)