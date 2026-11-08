class_name CherryBomb
extends Plant

## CherryBomb — 💥 Cereza Bomba (Post-MVP).
##
## Explota instantáneamente al plantar (o tras breve delay), dañando
## todos los zombies en radio `explode_radius` celdas.

var _armed: bool = false

func _ready() -> void:
	super._ready()
	# Armado tras breve delay visual (0.5 s)
	var arm_timer = Timer.new()
	arm_timer.wait_time = 0.5
	arm_timer.one_shot = true
	arm_timer.timeout.connect(_arm)
	add_child(arm_timer)
	arm_timer.start()

func _arm() -> void:
	_armed = true
	_explode()

func _explode() -> void:
	if not _armed:
		return
	var radius = data.explode_radius if data else 3
	var damage = data.explode_damage if data else 1800
	
	# Explota en todas las filas, columnas dentro del radio
	for target_row in range(5):
		for target_col in range(9):
			# Distancia Chebyshev desde la cereza
			var dist = maxi(abs(target_row - row), abs(target_col - col))
			if dist <= radius:
				var board_node = get_tree().get_first_node_in_group("board")
				if board_node:
					var plant = board_node.call("plant_at", target_col, target_row)
					if plant and is_instance_valid(plant):
						plant.call("take_damage", damage)
				# También daña zombies en esa celda
				for zombie in get_tree().get_nodes_in_group("zombies"):
					if is_instance_valid(zombie) and zombie.row == target_row:
						var zombie_col = int((zombie.global_position.x - 640) / 80) + 4
						if abs(zombie_col - col) <= radius:
							zombie.call("take_damage", damage)
	
	# Emitir señal para que Board libere la celda
	EventBus.plant_destroyed.emit(self)
	
	# Efecto visual de explosión (partícula simple via tween de escala + color)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1.0, 0.3, 0.1, 1.0), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE * 2.5, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_delay(0.15)
	tween.finished.connect(queue_free)
	
	# AudioManager.play("explode")  # stub

func _draw() -> void:
	var red := Color(1.0, 0.2, 0.1)
	var dark_red := Color(0.7, 0.1, 0.05)
	
	# Cuerpo rojo redondo.
	draw_circle(Vector2.ZERO, 24.0, red)
	
	# "Mecha" arriba.
	draw_rect(Rect2(-2.0, -26.0, 4.0, 10.0), Color(0.3, 0.2, 0.1))
	draw_circle(Vector2(0.0, -28.0), 5.0, Color(1.0, 0.5, 0.1))
	
	# Brillo pulsante si armada.
	if _armed:
		var pulse = abs(sin(Time.get_ticks_msec() / 100.0))
		draw_circle(Vector2.ZERO, 20.0 + pulse * 4.0, Color(1.0, 0.4, 0.2, 0.5))