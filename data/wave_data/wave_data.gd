extends Resource
class_name WaveData

## Una oleada individual
@export var delay: float = 10.0          # Segundos desde inicio de oleada anterior (o inicio partida)
@export var zombie_count: int = 3         # Cuántos zombies spawnear en esta oleada
@export var rows: Array[int] = [0, 1, 2, 3, 4]  # Filas donde aparecen (0..4)
@export var zombie_type: String = "basic"   # Tipo de zombie (para futuras variantes)

## Lista completa de oleadas del nivel
@export var waves: Array[WaveData] = []

## Helper: devuelve la oleada N (0-indexed) o null si se acabó
func get_wave(index: int) -> WaveData:
	if index >= 0 and index < waves.size():
		return waves[index]
	return null

## Helper: número total de oleadas
func total_waves() -> int:
	return waves.size()