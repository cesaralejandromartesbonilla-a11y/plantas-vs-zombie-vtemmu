# 🗺️ Hoja de Ruta (Roadmap) — Plantas vs Zombies Godot 4.6

Este documento define la trayectoria técnica para la expansión del tower defense de Plantas vs Zombies en Godot 4.

---

## 📌 Fase 1: Mecánicas Fundamentales (Completado ✅)
- [x] Bus de eventos (`EventBus.gd`) y gestores (`SunBank`, `WaveManager`, `PlantLibrary`).
- [x] Grid de casillas con detección de colisión y ocupación.
- [x] Lanzaguisantes con detección de carril y zombis básicos con mordisco.
- [x] Barra de selección de semillas con cooldown y costo de sol.
- [x] Limpieza de caché `.godot` y archivos de respaldo `.bak`.

---

## 📌 Fase 2: Variedad de Plantas y Tipos de Zombi (En Progreso 🔄)
- [ ] **Nuevas Plantas de Combate**:
  - *Repetidora*: Doble disparo de guisante por ráfaga.
  - *Hielaguisantes (Snow Pea)*: Efecto de ralentización de velocidad de paso del zombi.
  - *Petaseta / Cerezas Explosivas*: Daño de área masivo $3 \times 3$ con temporizador de detonación.
- [ ] **Variaciones de Zombis**:
  - *Zombi con Cono*: Salud duplicada con pérdida visual del cono al recibir daño.
  - *Zombi con Cubo*: Blindaje metálico de alta resistencia.
  - *Zombi con Pértiga*: Salto sobre la primera planta defensiva encontrada.

---

## 📌 Fase 3: Progresión y Nuevos Escenarios 🚀
- [ ] **Podadoras de Césped (Lawnmowers)**:
  - Última línea de defensa por carril que barre a todos los zombis al ser activada.
- [ ] **Niveles Nocturnos y Niebla**:
  - Sin soles celestes que caen del cielo; dependencia de setas solares nocturnas.
- [ ] **Audio Reactivo y Efectos de Jugo (Game Juice)**:
  - Animaciones de sacudida (*screen shake*), parpadeo en blanco al recibir impacto y SFX de masticar.
