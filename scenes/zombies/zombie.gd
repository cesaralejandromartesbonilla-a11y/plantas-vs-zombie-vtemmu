class_name Zombie
extends CharacterBody2D

## Zombie — 🧟 Zombie básico (Fase 5).
##
## Camina por su carril de derecha a izquierda. Si encuentra una planta en
## su celda la muerde (100 daño / 0.5 s) hasta destruirla y luego sigue.
## Si llega al borde izquierdo (la casa), emite zombie_reached_house.
##
## Números configurados por export (balance inicial, sección 5 de la hoja).

const WALK_SPEED := 7.0           # píxeles/segundo (lento, "shambling")
const HOUSE_X := 68.0             # borde izquierdo = la casa
const BITE_DAMAGE := 100
const BITE_INTERVAL := 0.5        # segundos entre mordidas
const BITE_RANGE := 50.0          # píxeles a la izquierda donde muerde

var hp: int = 200
var row: int = 0

var _eating: bool = false
var _bite_timer: float = 0.0
var _target: Node = null  # Usar Node en vez de Plant para evitar error de clase
var _reached_house: bool = false

func _ready() -> void:
	add_to_group("zombies")
	EventBus.zombie_spawned.emit(self, row)

## Registra la fila en la que camina (la pone Main al instanciarlo).
func setup(p_row: int) -> void:
	row = p_row

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = maxi(0, hp - amount)
	EventBus.zombie_damaged.emit(self, amount)
	if hp == 0:
		_die()

## Aplica slow al zombie (factor y duración).
var _slow_timer: float = 0.0
var _original_speed: float = WALK_SPEED

func apply_slow(factor: float, duration: float) -> void:
	# Solo aplica si es más lento que el actual
	if factor >= 1.0:
		return
	var new_speed = WALK_SPEED * factor
	if new_speed >= _original_speed:
		return
	_original_speed = WALK_SPEED
	WALK_SPEED = new_speed
	_slow_timer = duration

func _die() -> void:
	EventBus.zombie_died.emit(self)
	# Animación de muerte: fade + scale down
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	if _reached_house or hp <= 0:
		return

	# Maneja timer de slow
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			WALK_SPEED = _original_speed

	# Busca comida solo si no está comiendo.
	if not _eating:
		_target = _find_plant_ahead()
		if _target != null:
			_eating = true
			_bite_timer = BITE_INTERVAL

	if _eating:
			# La planta puede haber muerto mientras comía.
			if _target == null or not is_instance_valid(_target):
				_eating = false
				_target = null
			elif _target.get("hp") == null or _target.get("hp") <= 0:
				_eating = false
				_target = null
			else:
				_position_beside_plant()
				_bite_timer -= delta
				if _bite_timer <= 0.0:
					_bite_timer = BITE_INTERVAL
					if _target.get("take_damage") != null:
						_target.call("take_damage", BITE_DAMAGE)
						_bite_shake()  # Animación de mordida
	else:
		# Camina hacia la casa.
		global_position.x -= WALK_SPEED
		if global_position.x <= HOUSE_X:
			_reached_house = true
			EventBus.zombie_reached_house.emit(self)
			queue_free()

## El zombie se pega a la planta que está comiendo (evita solaparse).
func _position_beside_plant() -> void:
	var offset := 30.0
	var target_node: Node = _target
	if target_node == null:
		return
	var desired: float = target_node.global_position.x + offset
	if global_position.x > desired:
		global_position.x = move_toward(global_position.x, desired, WALK_SPEED * 2.5)

func _bite_shake() -> void:
	_kill_active_tween()
	AudioManager.play("bite")
	_active_tween = create_tween()
	var orig_x := global_position.x
	_active_tween.set_parallel(true)
	_active_tween.tween_property(self, "global_position:x", orig_x - 5.0, 0.05)
	_active_tween.tween_property(self, "global_position:x", orig_x + 5.0, 0.05)
	_active_tween.tween_property(self, "global_position:x", orig_x, 0.05)

var _active_tween: Tween = null

func _kill_active_tween() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null

## Planta más cercana a la izquierda en este carril (dentro del alcance).
func _find_plant_ahead() -> Node:
	for node in get_tree().get_nodes_in_group("plants"):
		if not is_instance_valid(node):
			continue
		if node.global_position.y != global_position.y:
			continue
		var px: float = node.global_position.x
		if px >= global_position.x:  # la planta debe estar enfrente (izq.)
			continue
		if global_position.x - px > BITE_RANGE:
			continue
		return node
	return null

## Placeholder visual: zombie gris/verde mirando a la izquierda.
func _draw() -> void:
	var skin := Color(0.35, 0.5, 0.3)
	var dark := Color(0.22, 0.32, 0.2)

	# Cabeza.
	draw_circle(Vector2(0, -10), 14.0, skin)

	# Cuerpo.
	draw_rect(Rect2(-10, -2, 20, 30), skin)

	# Brazo estirado hacia la izquierda (zombie hambriento).
	draw_rect(Rect2(-26, 2, 18, 7), skin)

	# Ojos (mirando a la izquierda).
	draw_circle(Vector2(-5, -13), 3.2, Color(1, 0.7, 0.3))
	draw_circle(Vector2(4, -13), 3.2, Color(1, 0.7, 0.3))
	draw_circle(Vector2(-5, -13), 1.5, Color.BLACK)
	draw_circle(Vector2(4, -13), 1.5, Color.BLACK)

	# Sombrero pequeño de zombie.
	draw_rect(Rect2(-8, -26, 16, 5), dark)