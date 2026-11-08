extends Node

## PlantLibrary — Registro central de semillas disponibles (Fase 3).
##
## Autoload que mapea cada `seed_id` (StringName) a su PlantData (.tres).
## Lo consume la SeedBar para construir las ranuras y la lógica de siembra
## para instanciar la escena correcta al plantar.
##
## Para añadir una planta al MVP basta con:
##   1. Crear su .tres en data/plant_data/  (mismo id que el .tres).
##   2. Crear su escena en scenes/plants/   (con PlantData asignado).
##   3. Registrarla aquí en `_register_plants()`.

signal library_ready

const PREFAB_BY_ID := {
	&"sunflower": "res://scenes/plants/sunflower.tscn",
	&"peashooter": "res://scenes/plants/peashooter.tscn",
	&"wallnut": "res://scenes/plants/wallnut.tscn",
	&"snowpea": "res://scenes/plants/snowpea.tscn",
	&"repeater": "res://scenes/plants/repeater.tscn",
	&"cherrybomb": "res://scenes/plants/cherrybomb.tscn",
}

## seed_id -> PlantData
var data_by_id: Dictionary = {}

func _ready() -> void:
	_register_plants()
	library_ready.emit()

## Devuelve el PlantData de una semilla, o null si no existe.
func get_data(seed_id: StringName) -> PlantData:
	return data_by_id.get(seed_id) as PlantData

## ¿Existe una semilla registrada con este id?
func has_seed(seed_id: StringName) -> bool:
	return data_by_id.has(seed_id)

## Escena listada para una semilla (PackedScene listo para instanciar).
func get_scene(seed_id: StringName) -> PackedScene:
	if not PREFAB_BY_ID.has(seed_id):
		push_error("PlantLibrary: no hay escena para la semilla '%s'" % seed_id)
		return null
	return load(PREFAB_BY_ID[seed_id])

func _register_plants() -> void:
	for seed_id: StringName in PREFAB_BY_ID:
		var path := "res://data/plant_data/%s.tres" % seed_id
		if not ResourceLoader.exists(path):
			push_error("PlantLibrary: falta el recurso %s" % path)
			continue
		var res: PlantData = load(path)
		if res == null or res.id != seed_id:
			push_error("PlantLibrary: %s no tiene PlantData válido (id=%s)" % [path, res.id if res else "<null>"])
			continue
		data_by_id[seed_id] = res