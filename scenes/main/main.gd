extends Node2D

## Main — Raíz de la partida.
##
## Fase 2: Board (grilla 9x5) + lluvia de sol (SunLayer) + HUD con contador.
## Fase 3: orquesta la siembra — al recibir `plant_planted` del Board paga
## el sol y arranca el cooldown de la ranura correspondiente.
## Fase 4/5: hotkeys de debug para probar combate:
##   - Z: spawnea un zombie de prueba en la fila 0
##   - G: spawnea un zombie por cada fila (0..4)
##   - T: te da 1000☀ (probar plantas caras rápido)
## Fase 6: orquesta oleadas (WaveManager), victoria/derrota, pantallas.

const ZOMBIE_SCENE := preload("res://scenes/zombies/zombie.tscn")

@onready var board: Node2D = $Board
@onready var entities: Node2D = $Entities
@onready var fps_label: Label = %FpsLabel
@onready var seed_bar: HBoxContainer = $UI/HUD/SeedBar
@onready var victory_screen: Control = $UI/VictoryScreen
@onready var defeat_screen: Control = $UI/DefeatScreen
@onready var pause_screen: Control = $UI/PauseScreen

func _ready() -> void:
	EventBus.plant_planted.connect(_on_plant_planted)
	EventBus.zombie_reached_house.connect(_on_zombie_reached_house)
	EventBus.game_won.connect(_on_game_won)
	EventBus.game_lost.connect(_on_game_lost)
	EventBus.wave_started.connect(_on_wave_started)
	victory_screen.retry_pressed.connect(_on_retry_pressed)
	defeat_screen.retry_pressed.connect(_on_retry_pressed)
	pause_screen.resume_pressed.connect(_on_pause_resume)
	pause_screen.quit_pressed.connect(_on_pause_quit)
	
	GameManager.state_changed.connect(_on_game_state_changed)
	
	seed_bar.clear_selection()
	# No auto-iniciar oleadas; WaveManager.start_waves() se llama al entrar en PLAYING

func _process(_delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_Z:
				_spawn_test_zombie(0)
			KEY_G:
				for r in 5:
					_spawn_test_zombie(r)
			KEY_T:
				SunBank.add(1000)
				print("[Main] +1000☀ (total: %d)" % SunBank.amount)

func _on_game_state_changed(new_state: int) -> void:
	if new_state == GameManager.State.PLAYING:
		WaveManager.start_waves()
		victory_screen.visible = false
		defeat_screen.visible = false

func _on_wave_started(wave_number: int) -> void:
	print("[Main] Oleada %d iniciada" % wave_number)

## Fase 3: al plantarse una planta (lo hace el Board), pagamos el sol y
## ponemos la ranura en cooldown.
func _on_plant_planted(plant: Node2D, _col: int, _row: int) -> void:
	if plant == null or plant.data == null:
		return
	var p_data = plant.data
	if p_data == null:
		return
	SunBank.spend(p_data.cost)
	print("[Main] Plantada %s — coste %d☀ (restante: %d☀)" % [p_data.display_name, p_data.cost, SunBank.amount])
	AudioManager.play("plant")
	# Reinicia la selección de la barra (si el jugador quiere re-sembrar,
	# vuelve a pulsar la ranura cuando el cooldown termine).
	seed_bar.clear_selection()
	seed_bar.start_cooldown(p_data.id)

## Fase 5: un zombie llegó a la casa → derrota.
func _on_zombie_reached_house(_zombie: Node2D) -> void:
	print("[Main] 💀 ¡DERROTA! Un zombie llegó a la casa")
	EventBus.game_lost.emit()
	GameManager.change_state(GameManager.State.LOST)

## Victoria: muestra pantalla y pausa.
func _on_game_won() -> void:
	victory_screen.show_screen()
	AudioManager.play("victory")
	GameManager.change_state(GameManager.State.WON)

## Derrota: muestra pantalla y pausa.
func _on_game_lost() -> void:
	defeat_screen.show_screen()
	AudioManager.play("defeat")
	GameManager.change_state(GameManager.State.LOST)

## Reintentar: recarga la escena Main.
func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

## Pausa: reanudar partida.
func _on_pause_resume() -> void:
	GameManager.change_state(GameManager.State.PLAYING)

## Pausa: salir al menú (reinicia la escena).
func _on_pause_quit() -> void:
	get_tree().reload_current_scene()

## Debug: spawnea un zombie en la fila `row` entrando por la derecha.
func _spawn_test_zombie(row: int) -> void:
	var zombie: Zombie = ZOMBIE_SCENE.instantiate()
	zombie.setup(row)
	zombie.global_position = Vector2(board.world_center(8, row).x + 40.0, board.world_center(0, row).y)
	entities.add_child(zombie)
	print("[Main] Zombie de prueba spawneado en fila %d" % row)