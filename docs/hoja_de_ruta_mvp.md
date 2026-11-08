# 🧟 Plantas vs Zombies — MVP en Godot 4.6

## 1. Visión general

Recrear la experiencia central de *Plants vs Zombies*: un **tower defense por casillas**
en 2D donde el jugador planta defensas vegetales en una cuadrícula de césped para
impedir que oleadas de zombies lleguen a su casa.

El MVP busca capturar el **bucle de juego principal** (economía de sol → plantar →
defender → sobrevivir oleadas) con el menor contenido posible pero 100% jugable.

---

## 2. Alcance del MVP

### ✅ Incluido en el MVP

| Sistema | Detalle |
|---|---|
| **Tablero** | Grilla de **9 columnas × 5 filas**, césped con filas de carril (lanes) |
| **Plantas (3)** | 🌻 **Girasol** (genera sol), 🔫 **Lanzaguisantes** (dispara), 🥜 **Nuez** (defensa con vida) |
| **Zombies (1)** | 🧟 **Zombie básico**: camina por su carril, come plantas, avanza |
| **Economía** | Sol como moneda: lluvia de sol del cielo + sol generado por el girasol |
| **Siembra** | Barra de semillas con costo, cooldown y preview de celda (verde/rojo) |
| **Proyectiles** | Guisantes que viajan por el carril y dañan al primer zombie que golpean |
| **Oleadas** | Olas programadas (1 por ola, más zombies con el tiempo) |
| **Victoria** | Sobrevivir todas las oleadas sin que ningún zombie llegue a la casa |
| **Derrota** | Un zombie alcanza el borde izquierdo (la casa) |
| **UI** | Contador de sol, barra de semillas, cooldowns, pausa (P/Esc), pantallas de victoria/derrota |
| **Assets** | Formas/colores de respaldo (placeholders dibujados con nodos) — sin arte final |

### ❌ Fuera del MVP (post-MVP)

- Más variedad de plantas y zombies (guisante helado, petacereza, lanza mantequilla, etc.)
- Podadoras (lawn mowers), banderas/vidas múltiples, hoyos de excavación
- Niveles múltiples, selección de nivel, tienda, monedas de meta-juego
- Música y SFX finales (solo placeholders), cinemáticas, tutorial guionizado
- Modo zen, cartas desafío, upgrades de plantas

---

## 3. Arquitectura propuesta

### 3.1 Estructura de carpetas

```
res://
├── assets/
│   ├── art/        # Sprites (placeholder: generados en código)
│   └── audio/      # SFX placeholder
├── autoload/
│   ├── game_manager.gd   # Máquina de estados: MENU → PLAYING → WON/LOST/PAUSED
│   └── event_bus.gd      # Señales globales (desacopla sistemas)
├── data/
│   ├── plant_data.gd     # Resource: costo, cooldown, HP, daño, cadencia…
│   ├── plant_data/*.tres # Definiciones por planta
│   └── wave_data.gd      # Resource: lista de oleadas
├── scenes/
│   ├── main/main.tscn            # Escena raíz de partida
│   ├── board/board.tscn          # Grilla + lógica de celdas
│   ├── plants/*.tscn             # girasol, lanzaguisantes, nuez (herencia de base)
│   ├── zombies/zombie.tscn       # Zombie base (único por ahora)
│   ├── projectiles/pea.tscn      # Guisante
│   └── sun/sun.tscn              # Sol caído / generado
└── ui/
    ├── hud.tscn          # Contador de sol + barra de semillas + indicador de ola
    ├── seed_bar.tscn     # Ranuras seleccionables con cooldown
    └── menus/            # Título, Pausa, Victoria, Derrota
```

### 3.2 Árbol de escena de la partida

```
Main (Node2D)
├── Board (Node2D)              # Grilla 9×5, celdas Area2D, fondo césped
├── Entities (Node2D)           # Plantas, zombies y proyectiles instanciados aquí
├── SunLayer (Node2D)           # Soles flotando/cayendo
└── UI (CanvasLayer)
    ├── HUD (contador, seed bar, ola)
    └── Menus (pausa / victoria / derrota)
```

### 3.3 Reglas de diseño técnicas

- **Una planta por celda**: el Board mantiene un array 2D `cells[5][9]` con referencia
  a la planta ocupante (o `null`).
- **Carriles (lanes)**: los zombies y guisantes viven en su fila; la colisión se resuelve
  **por fila** (comparación de coordenada X) o con `Area2D` en capas separadas por fila.
- **Desacople por señales**: los sistemas no se conocen entre sí; todo pasa por `EventBus`
  (p. ej. `sun_spent`, `plant_eaten`, `zombie_died`, `wave_started`).
- **Configuración data-driven**: plantas y oleadas se definen en Resources (`.tres`) para
  balancear sin tocar código.
- **Extensible por herencia**: `Plant` y `Zombie` son clases base; cada variedad solo
  sobrescribe comportamiento. Así añadir contenido post-MVP será trivial.

---

## 4. Hoja de ruta por fases

> Cada fase termina con un **criterio de aceptación** verificable en el editor.

### Fase 0 — Fundación 🏗️ *(0.5 día)*
- Ajustar `project.godot`: ventana 1280×720, `canvas_items` stretch, input map (clic, P/Esc).
- Crear estructura de carpetas y Autoloads (`GameManager`, `EventBus`).
- Escena `Main` con fondo de césped (ColorRects) y un indicador de FPS para debug.
- **✅ Aceptación:** el juego corre y muestra la pantalla de césped vacía.

### Fase 1 — Board y grilla 🟩 *(0.5 día)*
- `Board` con 9×5 celdas visuales + detección de clic → coordenada `(col, fila)`.
- Resaltado de celda bajo el mouse; debug: `print("celda", col, fila)`.
- **✅ Aceptación:** al hacer clic en cualquier celda, el debug imprime la coordenada correcta.
- **Estado: ✅ COMPLETADA y VALIDADA.** `scenes/board/{board,cell}.gd(tscn)`, integrado en `main.tscn`
  (board centrado en 640,360). Fix aplicado: `cell.setup()` tocaba nodos `@onready` antes de
  `add_child()` (crash); ahora solo guarda valores y el color se aplica en `_ready()`.

### Fase 2 — Economía de sol ☀️ *(1 día)*
- Contador de sol en HUD (empieza en 50).
- Sol que cae del cielo cada ~10 s (valor 25), recogible con clic (tween de vuelo y +sol).
- Girasol de prueba plantado en `_ready()` que emite sol cada 24 s.
- **✅ Aceptación:** el contador sube al recoger soles; el girasol genera y suelta su sol.
- **Estado: ✅ COMPLETADA y VALIDADA.** `autoload/sun_bank.gd` (economía: add/spend/can_afford),
  `scenes/sun/{sun.gd,sun.tscn,sun_spawner.gd}` (caída, recogida, vuelo al HUD, lluvia 7-13 s),
  `ui/{hud.gd,hud.tscn,sun_icon.gd}` (contador + ancla de vuelo), base `Plant` +
  `data/plant_data.gd` + `data/plant_data/sunflower.tres` + `scenes/plants/{plant,sunflower}.gd(tscn)`.
  Girasol de prueba plantado en `main.gd` en la celda (2,2).

### Fase 3 — Siembra y barra de semillas 🌱 *(1 día)*
- `SeedBar` con 3 ranuras (girasol 50☀, lanzaguisantes 100☀, nuez 50☀) + texto de costo.
- Selección de semilla → preview en celda (verde si alcanza el sol, rojo si no).
- Clic planta la semilla, descuenta sol e inicia el cooldown (gris sobre la ranura).
- **✅ Aceptación:** flujo completo seleccionar → ver preview → plantar → pagar → cooldown.
- **Estado: ✅ COMPLETADA y VALIDADA.** `ui/{seed_slot,seed_bar}.gd(tscn)` (ranuras con costo,
  cooldown con cuenta atrás, selección única, clic derecho cancela), `autoload/plant_library.gd`
  (registro central de semillas + escenas), `data/plant_data/{peashooter,wallnut}.tres` y
  `scenes/plants/{peashooter,wallnut}.gd(tscn)` (placeholder para siembra; su lógica llega en
  Fase 4), `scenes/board/board.gd` ampliado (una planta por celda, `can_plant/plant`,
  previews verde/rojo, libera celda al destruirse), `scenes/board/cell.gd` (enum Preview +
  ocupación), `main.gd` orquesta (paga sol y arranca cooldown al recibir `plant_planted`).

### Fase 4 — Proyectiles y plantas activas 💥 *(1 día)*
- Lanzaguisantes dispara un guisante por su fila cada 1.4 s.
- Guisante (20 de daño) golpea al primer zombie e impacta con partícula simple.
- Nuez con 4000 HP; los zombies la muerden y la destruyen.
- **✅ Aceptación:** hay zombie de prueba; el guisante lo daña y la nuez lo bloquea.
- **Estado: ✅ COMPLETADA y VALIDADA.** `scenes/projectiles/{pea.gd,pea.tscn}`
  (guisante: velocidad 420 px/s por su fila, impacto por x + rango, 20 de daño);
  `scenes/plants/peashooter.gd` (dispara cada `fire_interval` solo si hay zombie
  en su carril); `scenes/zombies/{zombie.gd,zombie.tscn}` (zombie de prueba:
  camina 7 px/s, muerde 100 HP/0.5 s, `zombie_reached_house` al llegar a la casa).
  Hotkeys de debug en `main.gd`: **Z** = zombie en fila 0, **G** = un zombie por
  fila, **T** = +1000☀.

### Fase 5 — Zombies 🧟 *(1 día)*
- Zombie básico: 200 HP, spawnea en la columna 9 y camina a la izquierda (lento).
- Al chocar con una planta la muerde (100 daño/0.5 s) hasta destruirla y luego sigue.
- Al llegar al borde izquierdo → evento `zombie_reached_house`.
- **✅ Aceptación:** el zombie camina, come, muere por guisantes; se registra pérdida al llegar a casa.
- **Estado: ✅ NÚCLEO COMPLETADO Y VALIDADO.** `scenes/zombies/{zombie.gd,zombie.tscn}` ya
  cubre caminar / comer / morir / llegar a la casa (los números de balance de la sección 5
  están aplicados). El spawneo automático por oleadas y la pantalla de derrota llegan en
  la Fase 6; por ahora se prueba con las hotkeys Z/G de `main.gd`.

---

### Fase 6 — Oleadas y loop de partida 🔁 *(1 día)* ⏳ **SIGUIENTE**
- `WaveManager` lee oleadas desde un Resource (tiempo de espera, nº zombies, filas).
- Condiciones de fin: ganar (todas las olas superadas) / perder (zombie en casa).
- Pantallas de victoria/derrota con botón **Reintentar** (recarga la escena).
- **✅ Aceptación:** una partida completa se juega de principio a fin con ambos finales.
- **Estado: ✅ IMPLEMENTADA.** `autoload/wave_manager.gd` (spawneo programado, contador de zombies vivos, oleadas desde `data/wave_data/waves_mvp.tres`), `ui/menus/{victory_screen,defeat_screen}.gd(tscn)` (pantallas con botón Reintentar), `scenes/main/main.gd` (orquesta GameManager, WaveManager, pantallas), `project.godot` (autoload WaveManager), `main.tscn` (grupos "main", "board", "entities", "sun_layer" + nodos VictoryScreen/DefeatScreen).

### Fase 7 — Pulido MVP ✨ *(1–2 días)* ✅ **COMPLETADA Y VALIDADA**
- Animaciones con `Tween`: aparición de plantas (pop-in), mordidas (shake), muerte de zombie (fade/scale), recogida de sol (tween de vuelo existente ya está).
- **Pausa (P/Esc)** con overlay semitransparente; opción de velocidad ×2 para testeo (ya en GameManager).
- **SFX placeholder**: AudioManager stub silencioso (API AudioStreamGenerator varía por versión; reactivable cuando se confirme).
- Balanceo de números (costo, olas, cantidades) + testeo de bugs.
- **✅ Aceptación:** MVP entregable: se abre, se juega, se gana y se pierde sin errores, con feedback visual/sonoro básico.
- **Estado: ✅ COMPLETADA Y VALIDADA.**
  - `scenes/plants/plant.gd`: pop-in animado al plantar (scale 0→1 con BACK ease).
  - `scenes/zombies/zombie.gd`: shake al morder + fade/scale-down al morir.
  - `autoload/audio_manager.gd`: stub silencioso (sin errores de parseo/runtime).
  - `scenes/projectiles/pea.gd`: sin SFX (AudioManager stub).
  - `scenes/sun/sun.gd`: sin SFX (AudioManager stub).
  - `scenes/main/main.gd`: sin SFX victoria/derrota (AudioManager stub).
  - `ui/menus/pause_screen.gd/.tscn`: overlay pausa semitransparente con botones Reanudar/Salir.
  - `main.tscn`: grupo "main" + nodos PauseScreen.
  - `game_manager.gd`: gestiona pausa visual via `get_tree().paused`.
  - `project.godot`: input "pause" mapeado a Escape + P; autoload AudioManager (stub).

---

## 5. Balance inicial (referencia)

| Planta | Costo | Cooldown | HP | Comportamiento |
|---|---|---|---|---|
| 🌻 Girasol | 50 ☀ | 7.5 s | 300 | Suelta 25 ☀ cada 24 s |
| 🔫 Lanzaguisantes | 100 ☀ | 7.5 s | 300 | Dispara 20 de daño cada 1.4 s |
| 🥜 Nuez | 50 ☀ | 30 s | 4000 | Bloquea; zombie la muerde |

| Zombie | HP | Daño mordida | Velocidad |
|---|---|---|---|
| 🧟 Básico | 200 | 100 / 0.5 s | ~0.07 celdas/s (lento, se siente "shambling") |

| Económico | Valor |
|---|---|
| Sol inicial | 50 ☀ |
| Lluvia de sol | 25 ☀ cada ~10 s |
| Primer zombie | Ola 1: a los ~20 s de empezar |

---

## 6. Riesgos y decisiones pendientes

1. **Colisión proyectil↔zombie**: decidir entre `Area2D` (fácil, más nodos) vs. chequeo
   por fila (más simple y rápido). → Decisión inicial: **chequeo por fila** (X + rango).
2. **Dificultad de olas**: los números de la sección 5 son el punto de partida; se
   calibrarán en la Fase 7 con testeo real.
3. **Vidas**: el MVP usa **derrota directa** (1 zombie en casa = perder). El sistema de
   3 banderas queda post-MVP como mejora de dificultad.
4. **Arte**: todo el MVP usa placeholders de código. Al terminar la Fase 7, si se quiere
   arte real, se reemplazan nodos de color por `Sprite2D` sin tocar lógica.

---

## 7. Próximo paso

**Fases 1 a 7 ✅ COMPLETADAS** — El MVP está completo y jugable:
- Tablero 9×5 con celdas clicables y preview verde/rojo
- Economía de sol: lluvia del cielo + girasol generador, recolección con tween
- Barra de semillas (3 plantas) con costo, cooldown y selección
- Lanzaguisantes dispara y mata zombies; Nuez bloquea y es comida
- Zombie básico camina, come, muere, llega a casa → derrota
- **Oleadas automáticas** (`WaveManager` + `WaveData` resource con 8 oleadas crecientes)
- **Pantallas de Victoria/Derrota** con botón **Reintentar** (recarga escena)
- **GameManager** maneja estados MENU → PLAYING → WON/LOST/PAUSED
- **Animaciones Tween**: pop-in plantas, shake mordida, fade/scale muerte zombie
- **Pausa (P/Esc)** con overlay semitransparente
- **AudioManager stub** (sin errores; reactivable para SFX cuando se confirme API)

**Paso siguiente: Post-MVP / Expansión**

Posibles direcciones:
1. **Más contenido**: nuevas plantas (guisante helado, petacereza, lanza mantequilla), nuevos zombies (cono, cubo, periódico), podadoras (lawn mowers).
2. **Sistema de vidas/banderas**: 3 vidas antes de derrota real (como el original).
3. **Niveles y progresión**: selección de nivel, tienda, monedas, upgrades.
4. **Arte real**: reemplazar placeholders dibujados en código por sprites/animaciones.
5. **SFX/música reales**: archivos de audio en lugar de generador procedural.
6. **Pulido UX**: tutorial guiado, partículas de impacto, screen shake, feedback visual más rico.