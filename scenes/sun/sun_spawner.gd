extends Node2D

## SunSpawner — Lluvia de sol del cielo (Fase 2).
##
## Este script va en el nodo `SunLayer` (grupo "sun_layer") dentro de Main.
## Suelta un sol cada 7-13 s en una posición X aleatoria sobre el tablero;
## el sol cae 3 s hasta una profundidad aleatoria y queda recogible.

const SUN_SCENE := preload("res://scenes/sun/sun.tscn")

## Rango horizontal de caída (sobre el césped del board, 280..1000).
const SPAWN_X_MIN := 300.0
const SPAWN_X_MAX := 980.0
## Rango de profundidad a la que aterriza.
const LAND_Y_MIN := 150.0
const LAND_Y_MAX := 590.0

@onready var _timer: Timer = $SpawnTimer

func _ready() -> void:
	_timer.timeout.connect(_spawn_sky_sun)
	_timer.wait_time = randf_range(2.0, 4.0)  # primer sol pronto
	_timer.start()

func _spawn_sky_sun() -> void:
	var sun: Node2D = SUN_SCENE.instantiate()
	var spawn_x := randf_range(SPAWN_X_MIN, SPAWN_X_MAX)
	var start := Vector2(spawn_x, -40.0)
	var target := Vector2(spawn_x, randf_range(LAND_Y_MIN, LAND_Y_MAX))
	sun.global_position = start
	add_child(sun)
	sun.fall_from(start, target, 3.0)
	EventBus.sun_dropped.emit(sun)

	# Siguiente sol en 7-13 s.
	_timer.wait_time = randf_range(7.0, 13.0)