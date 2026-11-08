class_name Plant
extends Node2D

## Plant — Clase base de todas las plantas (Fase 2+).
##
## Cada variedad hereda y sobrescribe:_draw() para su placeholder visual y
## su comportamiento (disparar, producir sol, tanquear). Extensible por
## herencia: Fase 4 (lanzaguisantes) y Fase 5 (nuez) solo añaden lógica.

@export var data: PlantData

var hp: int = 0
var col: int = -1
var row: int = -1

## Registra la posición de grilla y aplica el HP del resource.
## (Usar tras instantiate; `data` ya viene asignado desde el .tscn.)
func setup(p_col: int, p_row: int) -> void:
	col = p_col
	row = p_row
	hp = data.max_hp if data else 0

func take_damage(amount: int) -> void:
	if hp <= 0:
		return
	hp = maxi(0, hp - amount)
	EventBus.plant_damaged.emit(self, amount)
	if hp == 0:
		_die()

func _die() -> void:
	EventBus.plant_destroyed.emit(self)
	queue_free()

## Placeholder visual genérico (círculo verde). Cada planta lo sobrescribe.
func _draw() -> void:
	draw_circle(Vector2.ZERO, 22.0, Color(0.2, 0.8, 0.3))

func _ready() -> void:
	add_to_group("plants")
	# Animación de aparición (pop-in)
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)