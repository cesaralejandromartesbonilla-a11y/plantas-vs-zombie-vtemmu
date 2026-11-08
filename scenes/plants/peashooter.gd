class_name Peashooter
extends Plant

## Peashooter — 🔫 Lanzaguisantes (Fase 4).
##
## Dispara un guisante por su fila cada `data.fire_interval` segundos,
## pero SOLO si hay un zombie en su carril (evita disparar al vacío).
## Si no hay objetivo deja de disparar hasta que aparezca uno.

const PEA_SCENE := preload("res://scenes/projectiles/pea.tscn")

var _timer: Timer

func _ready() -> void:
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
	var pea: Pea = PEA_SCENE.instantiate()
	pea.setup(row, data.pea_damage if data else 20)
	# Sale por la boca del tubo (a la derecha de la planta).
	pea.global_position = global_position + Vector2(30, 0)
	AudioManager.play("shoot")
	# Misma capa que el resto de entidades del tablero.
	var entities = get_tree().get_first_node_in_group("entities")
	if entities == null:
		# Fallback: buscar vía padre (Main -> Entities)
		var main = get_tree().get_first_node_in_group("main")
		if main == null:
			main = get_parent().get_parent()
		if main:
			entities = main.get_node_or_null("Entities")
	if entities == null:
		push_error("[Peashooter] No se encontró nodo 'entities'")
		return
	entities.add_child(pea)

## Placeholder visual: cuerpo + tubo hacia la derecha + ojo.
func _draw() -> void:
	var body_green := Color(0.28, 0.72, 0.3)
	var tube_green := Color(0.18, 0.55, 0.22)

	# Cuerpo.
	draw_circle(Vector2.ZERO, 22.0, body_green)

	# Tubo/boca hacia la derecha (dirección de disparo).
	draw_rect(Rect2(10.0, -6.0, 22.0, 12.0), tube_green)

	# Ojo (mira hacia la derecha).
	draw_circle(Vector2(-8.0, -7.0), 5.5, Color.WHITE)
	draw_circle(Vector2(-6.0, -7.0), 2.6, Color.BLACK)
