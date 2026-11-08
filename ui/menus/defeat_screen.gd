extends Control

## DefeatScreen — Pantalla de derrota con botón Reintentar.

signal retry_pressed

@onready var _retry_btn: Button = $VBoxContainer/RetryBtn
@onready var _title: Label = $VBoxContainer/Title
@onready var _subtitle: Label = $VBoxContainer/Subtitle

func _ready() -> void:
	_retry_btn.pressed.connect(_on_retry_pressed)
	visible = false
	process_mode = Control.PROCESS_MODE_ALWAYS

func show_screen() -> void:
	visible = true
	_title.text = "¡DERROTA! 💀"
	_subtitle.text = "Un zombie llegó a tu casa"
	grab_focus()

func _on_retry_pressed() -> void:
	retry_pressed.emit()
	visible = false