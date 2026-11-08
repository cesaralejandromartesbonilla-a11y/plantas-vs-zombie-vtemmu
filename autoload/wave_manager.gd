extends Node

## WaveManager — Controla el spawneo de oleadas de zombies.
##
## Carga oleadas desde un WaveData resource y las ejecuta en secuencia.
## Emite señales via EventBus: wave_started, wave_cleared, game_won, game_lost.

const ZOMBIE_SCENE := preload("res://scenes/zombies/zombie.tscn")
var WAVE_DATA: Resource

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_cleared()

@onready var _timer: Timer = Timer.new()

var _current_wave_index: int = -1
var _waves_completed: int = 0
var _zombies_alive: int = 0
var _wave_in_progress: bool = false

func _ready() -> void:
	add_child(_timer)
	_timer.one_shot = true
	_timer.timeout.connect(_on_wave_timer_timeout)
	EventBus.zombie_died.connect(_on_zombie_died)
	EventBus.zombie_reached_house.connect(_on_zombie_reached_house)
	EventBus.game_lost.connect(_on_game_lost)
	# Cargar WaveData aquí (evita problemas de orden de carga de preload)
	WAVE_DATA = load("res://data/wave_data/waves_mvp.tres")
	# No auto-iniciar: Main lo llama tras entrar en PLAYING

## Inicia la primera oleada (llamado desde Main al entrar en PLAYING)
func start_waves() -> void:
	_current_wave_index = -1
	_waves_completed = 0
	_zombies_alive = 0
	_wave_in_progress = false
	_schedule_next_wave()

## Programa la siguiente oleada según el delay del WaveData
func _schedule_next_wave() -> void:
	var next_index := _current_wave_index + 1
	var wave: WaveData = WAVE_DATA.get_wave(next_index)
	if wave == null:
		# ¡Todas las oleadas completadas!
		EventBus.all_waves_cleared.emit()
		EventBus.game_won.emit()
		GameManager.change_state(GameManager.State.WON)
		return
	
	_current_wave_index = next_index
	_wave_in_progress = true
	_zombies_alive = 0
	
	EventBus.wave_started.emit(_current_wave_index)
	print("[WaveManager] Iniciando oleada %d: %d zombies" % [_current_wave_index, wave.zombie_count])
	
	_timer.wait_time = wave.delay
	_timer.start()

## Timer terminado → spawnea los zombies de la oleada
func _on_wave_timer_timeout() -> void:
	var wave: WaveData = WAVE_DATA.get_wave(_current_wave_index)
	if wave == null:
		return
	
	# Spawnea zombies en las filas indicadas (distribuidos o repetidos si hay más zombies que filas)
	var rows_pool: Array[int] = wave.rows.duplicate()
	rows_pool.shuffle()
	
	for i in range(wave.zombie_count):
		var row: int = rows_pool[i % rows_pool.size()]
		_spawn_zombie(row)
	
	# La oleada "termina" cuando todos los zombies mueren o llegan a casa
	# _on_zombie_died / _on_zombie_reached_house manejan el contador

func _spawn_zombie(row: int) -> void:
	var board := get_tree().get_first_node_in_group("board")
	var entities := get_tree().get_first_node_in_group("entities")
	if board == null or entities == null:
		# Fallback vía Main
		var main := get_tree().get_first_node_in_group("main")
		if main == null:
			main = get_parent()
		if main:
			if board == null:
				board = main.get_node_or_null("Board")
			if entities == null:
				entities = main.get_node_or_null("Entities")
	if board == null or entities == null:
		push_error("[WaveManager] No se encontró Board o Entities")
		return

	var zombie: Zombie = ZOMBIE_SCENE.instantiate()
	zombie.setup(row)
	# Spawnea justo fuera del tablero a la derecha (columna 8 + offset)
	var spawn_x: float = board.world_center(8, row).x + 40.0
	var spawn_y: float = board.world_center(0, row).y
	zombie.global_position = Vector2(spawn_x, spawn_y)
	entities.add_child(zombie)
	_zombies_alive += 1
	EventBus.zombie_spawned.emit(zombie, row)

func _on_zombie_died(_zombie: Node2D) -> void:
	_zombies_alive -= 1
	_check_wave_complete()

func _on_zombie_reached_house(_zombie: Node2D) -> void:
	_zombies_alive -= 1
	# El game_lost lo maneja Main/GameManager
	_check_wave_complete()

func _check_wave_complete() -> void:
	if _wave_in_progress and _zombies_alive <= 0:
		_wave_in_progress = false
		_waves_completed += 1
		EventBus.wave_cleared.emit(_current_wave_index)
		print("[WaveManager] Oleada %d completada" % _current_wave_index)
		# Pequeña pausa antes de la siguiente
		call_deferred("_schedule_next_wave")

func _on_game_lost() -> void:
	_timer.stop()
	_wave_in_progress = false