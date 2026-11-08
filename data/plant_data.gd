class_name PlantData
extends Resource

## PlantData — Definición data-driven de una planta (Fase 2+).
##
## Cada variedad es un .tres con sus números, así se balancea sin tocar
## código (ver hoja de ruta, sección 3.3). Los campos no usados se dejan
## en 0 para que cada planta solo rellene lo que necesita.

@export var id: StringName = &""
@export var display_name: String = ""
@export var cost: int = 50
@export var cooldown: float = 7.5
@export var max_hp: int = 300

## Girasol: cada cuántos segundos produce sol (0 = no produce).
@export var sun_interval: float = 0.0
## Cuánto sol produce cada vez.
@export var sun_amount: int = 25

## Lanzaguisantes: daño por guisante y cadencia (0 = no dispara).
@export var pea_damage: int = 0
@export var fire_interval: float = 0.0

## Snow Pea: ralentiza zombies (factor 0.5 = mitad de velocidad).
@export var slow_factor: float = 0.0
## Duración del slow en segundos.
@export var slow_duration: float = 0.0

## Cherry Bomb: explosión instantánea, radio en celdas, daño.
@export var explode_radius: int = 0
@export var explode_damage: int = 0

## Repeater: dispara 2 guisantes por ataque.
@export var shots_per_attack: int = 1