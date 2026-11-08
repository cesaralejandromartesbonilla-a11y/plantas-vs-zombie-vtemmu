class_name Sun
extends Area2D

## Sun — ☀️ Sol del juego (Fase 2).
##
## Estados: FALLING (cae del cielo) -> GROUND (en el suelo, recogible) ->
## COLLECTED (vuela al contador del HUD y suma a SunBank).
## El girasol también lo usa: `pop_at()` lo hace aparecer ya en el suelo.

enum State { FALLING, GROUND, COLLECTED }

const VALUE := 25
const GROUND_LIFETIME := 8.0

const COLOR_CORE := Color(1.0, 0.95, 0.55)
const COLOR_BODY := Color(1.0, 0.88, 0.2)
const COLOR_RAY := Color(1.0, 0.8, 0.15)

var state: State = State.FALLING
var value: int = VALUE
var _active_tween: Tween = null

func _ready() -> void:
	input_event.connect(_on_input_event)

func _kill_active_tween() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null

## Cae desde `start_pos` hasta `target_pos` (lluvia del cielo).
func fall_from(start_pos: Vector2, target_pos: Vector2, fall_time: float = 3.0) -> void:
	state = State.FALLING
	global_position = start_pos
	modulate.a = 1.0
	scale = Vector2.ONE
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "global_position", target_pos, fall_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_callback(_land)

## Aparece ya en el suelo con un pequeño rebote (sol del girasol).
func pop_at(pos: Vector2) -> void:
	state = State.GROUND
	global_position = pos
	modulate.a = 1.0
	scale = Vector2.ZERO
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_start_ground_lifetime()

func _land() -> void:
	if state != State.FALLING:
		return
	state = State.GROUND
	_start_ground_lifetime()

## Si nadie lo recoge, se desvanece y desaparece.
func _start_ground_lifetime() -> void:
	await get_tree().create_timer(GROUND_LIFETIME).timeout
	if not is_instance_valid(self) or state != State.GROUND:
		return
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_active_tween.tween_callback(queue_free)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if state != State.GROUND:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_collect()

func _collect() -> void:
	if state == State.COLLECTED:
		return
	state = State.COLLECTED
	_kill_active_tween()
	AudioManager.play("sun")

	# Vuela hacia el ancla del contador de sol del HUD.
	var target := Vector2(118, 40)  # fallback si no hay ancla
	var anchor := get_tree().get_first_node_in_group("sun_anchor")
	if anchor:
		target = anchor.get_global_transform_with_canvas().origin

	_active_tween = create_tween()
	_active_tween.set_parallel(true)
	_active_tween.tween_property(self, "global_position", target, 0.3) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", Vector2(0.35, 0.35), 0.3)
	await _active_tween.finished
	SunBank.add(value)
	queue_free()

## Placeholder visual: núcleo + cuerpo + 8 rayos.
func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, COLOR_BODY)
	draw_circle(Vector2.ZERO, 10.0, COLOR_CORE)
	for i in 8:
		var dir := Vector2.from_angle(TAU * i / 8.0)
		draw_circle(dir * 24.0, 6.0, COLOR_RAY)
