extends Node

## GameManager — Máquina de estados de la partida.
##
## Estados: MENU -> PLAYING -> (WON | LOST)  y  PAUSED (en cualquier momento).
## Es un autoload: accesible desde cualquier nodo como `GameManager`.

enum State { MENU, PLAYING, WON, LOST, PAUSED }

signal state_changed(new_state: State)

var state: State = State.MENU:
	set(value):
		if state == value:
			return
		state = value
		state_changed.emit(state)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	state_changed.connect(_on_state_changed)

## Cambia de estado validando transiciones permitidas.
func change_state(new_state: State) -> bool:
	match state:
		State.MENU:
			if new_state != State.PLAYING:
				return false
		State.PLAYING:
			if new_state not in [State.PAUSED, State.WON, State.LOST]:
				return false
		State.PAUSED:
			if new_state not in [State.PLAYING, State.WON, State.LOST]:
				return false
		State.WON, State.LOST:
			# Desde fin de partida solo se reinicia toda la escena.
			return false
	state = new_state
	return true

func _toggle_pause() -> void:
	if state == State.PLAYING:
		change_state(State.PAUSED)
		# La pausa se maneja visualmente en Main (PauseScreen)
	elif state == State.PAUSED:
		change_state(State.PLAYING)
		# Reanudar se maneja en Main

func _on_state_changed(new_state: State) -> void:
	match new_state:
		State.PLAYING:
			get_tree().paused = false
		State.PAUSED:
			get_tree().paused = true
		State.WON, State.LOST:
			get_tree().paused = true
		_:
			pass

func _unhandled_input(event: InputEvent) -> void:
	# Con los botones del ratón nos ponemos en pausa sin clicar plantas.
	if event.is_action_pressed("pause"):
		_toggle_pause()