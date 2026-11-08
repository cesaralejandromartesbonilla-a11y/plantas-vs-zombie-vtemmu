extends Control

## SunIcon — Mini sol decorativo para el contador del HUD (Fase 2).

const COLOR_CORE := Color(1.0, 0.95, 0.55)
const COLOR_BODY := Color(1.0, 0.88, 0.2)
const COLOR_RAY := Color(1.0, 0.8, 0.15)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _draw() -> void:
	var center := size / 2.0
	var r := minf(size.x, size.y) / 2.0
	draw_circle(center, r * 0.72, COLOR_BODY)
	draw_circle(center, r * 0.4, COLOR_CORE)
	for i in 8:
		var dir := Vector2.from_angle(TAU * i / 8.0)
		draw_circle(center + dir * r, r * 0.24, COLOR_RAY)