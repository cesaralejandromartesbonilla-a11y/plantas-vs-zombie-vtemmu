class_name Wallnut
extends Plant

## Wallnut — 🥜 Nuez (Fase 3: solo siembra y placeholder).
##
## En la Fase 4+ la nuez solo tiene HP alto (4000) y bloquea a los zombies;
## aquí ya queda lista para sembrarse con su placeholder visual.

func _draw() -> void:
	var shell_brown := Color(0.58, 0.36, 0.16)
	var shell_dark := Color(0.42, 0.25, 0.1)

	# Cuerpo (cáscara).
	draw_circle(Vector2.ZERO, 24.0, shell_brown)

	# Costura central de la cáscara.
	draw_rect(Rect2(-2.5, -20.0, 5.0, 40.0), shell_dark)

	# Ojos.
	draw_circle(Vector2(-9.0, -8.0), 5.0, Color.WHITE)
	draw_circle(Vector2(-8.5, -8.0), 2.4, Color.BLACK)
	draw_circle(Vector2(9.0, -8.0), 5.0, Color.WHITE)
	draw_circle(Vector2(9.5, -8.0), 2.4, Color.BLACK)

	# Boca.
	draw_rect(Rect2(-4.0, 4.0, 8.0, 3.0), shell_dark)