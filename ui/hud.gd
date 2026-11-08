extends Control

## HUD — Interfaz superior de la partida (Fase 2).
##
## Por ahora solo el contador de sol (empezando en 50). En la Fase 3 se
## añadirá aquí la barra de semillas.

@onready var sun_label: Label = %SunLabel

func _ready() -> void:
	EventBus.sun_changed.connect(_on_sun_changed)
	_on_sun_changed(SunBank.amount)

func _on_sun_changed(total: int) -> void:
	sun_label.text = str(total)