class_name Pea
extends Area2D

## Pea — 🟢 Guisante (Fase 4).
##
## Viaja por su fila (misma `row` en la que se disparó) hacia la derecha.
## Golpea al primer zombie de su carril que encuentre (detección por fila
## + rango en X, según la decisión de la sección 6 de la hoja de ruta).
##
## Si atraviesa todo el tablero sin impactar, se elimina (se marca para
## evitar doble impacto).

const SPEED := 420.0        # píxeles/segundo hacia la derecha
const KILL_X := 1350.0      # fuera del tablero (1280+)

var row: int = 0
var damage: int = 20
var _dead: bool = false

func setup(p_row: int, p_damage: int) -> void:
	row = p_row
	damage = p_damage

func _process(delta: float) -> void:
	if _dead:
		return
	global_position.x += SPEED * delta
	_try_hit()
	if not _dead and global_position.x > KILL_X:
		queue_free()

## Busca al zombie más cercano (menor X) en este carril y lo golpea.
func _try_hit() -> void:
	var best: Zombie = null
	var best_x := INF
	for node in get_tree().get_nodes_in_group("zombies"):
		if not is_instance_valid(node) or not node is Zombie:
			continue
		var zombie: Zombie = node as Zombie
		if zombie.row != row:
			continue
		var zx: float = zombie.global_position.x
		if zx <= global_position.x:
			continue
		# El guisante impacta cuando su centro alcanza el cuerpo del zombie.
		if zx - global_position.x > 26.0:
			continue
		if zx < best_x:
			best_x = zx
			best = zombie
	if best != null:
			_dead = true
			best.take_damage(damage)
			AudioManager.play("impact")
			queue_free()

## Placeholder visual: guisante verde.
func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(0.35, 0.8, 0.3))
	draw_circle(Vector2(2.0, -2.0), 2.4, Color(0.6, 0.95, 0.5))
