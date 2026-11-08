extends Control

## PauseScreen — Overlay de pausa semitransparente con botones Reanudar / Salir.

signal resume_pressed
signal quit_pressed

@onready var _resume_btn: Button = $Panel/VBoxContainer/ResumeBtn
@onready var _quit_btn: Button = $Panel/VBoxContainer/QuitBtn

func _ready() -> void:
	_resume_btn.pressed.connect(_on_resume_pressed)
	_quit_btn.pressed.connect(_on_quit_pressed)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_screen() -> void:
	visible = true
	get_tree().paused = true
	_resume_btn.grab_focus()

func hide_screen() -> void:
	visible = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	resume_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()