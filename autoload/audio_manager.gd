extends Node

## AudioManager — SFX deshabilitado (stub silencioso) para evitar errores de AudioStreamGenerator.
## TODO: reactivar cuando se confirme API correcta en esta versión de Godot.

@onready var _player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(_player)
	process_mode = Node.PROCESS_MODE_ALWAYS

func play(name: String) -> void:
	# Silencioso - sin SFX por ahora
	pass