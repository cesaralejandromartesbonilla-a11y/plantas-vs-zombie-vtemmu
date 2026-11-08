class_name SnowPeaProjectile
extends Area2D

## SnowPeaProjectile — ❄️ Guisante de hielo (Post-MVP).
##
## Igual que Pea pero aplica slow al zombie impactado.

const SPEED := 420.0  # px/s (igual que guisante normal)
const HIT_RANGE := 20.0  # px de tolerancia en X

var _damage: int = 20
var _slow_factor: float = 0.5
var _slow_duration: float = 3.0
var _row: int = 0
var _hit: bool = false

func setup(p_row: int, p_damage: int, p_slow_factor: float, p_slow_duration: float) -> void:
	_row = p_row
	_damage = p_damage
	_slow_factor = p_slow_factor
	_slow_duration = p_slow_duration

func _process(delta: float) -> void:
	if _hit:
		return
	global_position.x += SPEED * delta
	# Chequeo de impacto por fila (chequeo simple por X).
	for zombie in get_tree().get_nodes_in_group("zombies"):
		if is_instance_valid(zombie) and zombie.row == _row:
			if abs(global_position.x - zombie.global_position.x) < HIT_RANGE:
				_impact(zombie)
				return
	# Fuera de pantalla (borde derecho).
	if global_position.x > 1400:
		queue_free()

func _impact(zombie) -> void:
	_hit = true
	zombie.call("take_damage", _damage)
	# Aplicar slow
	zombie.call("apply_slow", _slow_factor, _slow_duration)
	# AudioManager.play("impact")  # stub
	queue_free()

func _draw() -> void:
	# Guisante azul con cristal de hielo
	draw_circle(Vector2.ZERO, 6.0, Color(0.4, 0.7, 1.0))
	draw_circle(Vector2.ZERO, 3.0, Color(0.7, 0.85, 1.0))