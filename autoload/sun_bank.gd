extends Node

## SunBank — Banco de sol (economía) (Fase 2).
##
## Autoload centralizado para el recurso "sol".
## Mantiene el total y emite cambios por EventBus:
##   - sun_changed(total)   -> HUD actualiza el contador
##   - sun_collected(n)     -> se recogió sol
##   - sun_spent(n)         -> se gastó sol (siembra, Fase 3)
##
## La Fase 3 usará can_afford()/spend() desde la lógica de siembra.

const STARTING_SUN := 50

var amount: int = 0

func _ready() -> void:
	amount = STARTING_SUN
	EventBus.sun_changed.emit(amount)

## Añade sol (p. ej. al recoger un sol del cielo). Emite señales.
func add(amount_added: int) -> void:
	if amount_added <= 0:
		return
	amount += amount_added
	EventBus.sun_collected.emit(amount_added)
	EventBus.sun_changed.emit(amount)

## ¿Hay sol suficiente para pagar `cost`?
func can_afford(cost: int) -> bool:
	return amount >= cost

## Intenta gastar `cost` sol. Devuelve false si no alcanza (no descuenta).
func spend(cost: int) -> bool:
	if cost <= 0:
		return true
	if not can_afford(cost):
		return false
	amount -= cost
	EventBus.sun_spent.emit(cost)
	EventBus.sun_changed.emit(amount)
	return true