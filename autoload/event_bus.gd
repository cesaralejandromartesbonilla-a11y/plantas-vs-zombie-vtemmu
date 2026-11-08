extends Node

## EventBus — Señales globales del juego.
##
## Todos los sistemas se comunican a través de señales aquí definidas para
## mantenerse desacoplados entre sí (regla de diseño del proyecto, ver docs/hoja_de_ruta_mvp.md).

# ── Economía ────────────────────────────────────────────────────────────────
signal sun_changed(total: int)
signal sun_spent(amount: int)
signal sun_collected(amount: int)
signal sun_dropped(sun: Node2D)

# ── Tablero / Siembra ───────────────────────────────────────────────────────
signal cell_clicked(col: int, row: int)
signal seed_selected(seed_id: StringName)
signal plant_planted(plant: Node2D, col: int, row: int)

# ── Combate ─────────────────────────────────────────────────────────────────
signal zombie_spawned(zombie: Node2D, row: int)
signal zombie_died(zombie: Node2D)
signal zombie_reached_house(zombie: Node2D)
signal plant_damaged(plant: Node2D, amount: int)
signal plant_destroyed(plant: Node2D)
signal zombie_damaged(zombie: Node2D, amount: int)

# ── Partida ─────────────────────────────────────────────────────────────────
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal game_won()
signal game_lost()
signal game_paused(paused: bool)

## Reenvía cualquier señal con un prefijo, útil para debug:
##   EventBus.debug_forward("wave_started", wave_number)
func debug_forward(signal_name: String, args: Array = []) -> void:
	var call_args: Array = [signal_name]
	call_args.append_array(args)
	emit_signal.callv(call_args)
