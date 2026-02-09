# Versos de Héroe — Documentación Técnica MVP

## Índice

1. [Descripción General](#descripción-general)
2. [Requisitos Técnicos](#requisitos-técnicos)
3. [Estructura del Proyecto](#estructura-del-proyecto)
4. [Configuración del Proyecto](#configuración-del-proyecto)
5. [Autoloads (Singletons)](#autoloads-singletons)
6. [Sistema del Jugador](#sistema-del-jugador)
7. [Sistema de Diálogos](#sistema-de-diálogos)
8. [Sistema de Enemigos](#sistema-de-enemigos)
9. [Sistema de Combate Undertale](#sistema-de-combate-undertale)
10. [Sistema de Flashes (Persona 5)](#sistema-de-flashes-persona-5)
11. [Sistema de Coleccionables](#sistema-de-coleccionables)
12. [Minijuegos — Magic Man](#minijuegos--magic-man)
13. [Sistema de Poemas](#sistema-de-poemas)
14. [Sistema del Diario](#sistema-del-diario)
15. [Interfaz de Usuario (UI)](#interfaz-de-usuario-ui)
16. [Escenas del Capítulo 1](#escenas-del-capítulo-1)
17. [Datos JSON](#datos-json)
18. [Flujo Completo del Juego](#flujo-completo-del-juego)
19. [Convenciones de Código](#convenciones-de-código)
20. [Capas de Colisión](#capas-de-colisión)
21. [Capas de CanvasLayer](#capas-de-canvaslayer)

---

## Descripción General

**Versos de Héroe** es un RPG narrativo 2D sobre bullying escolar desarrollado en Godot 4.3 con GDScript. El MVP cubre el Capítulo 1 (~55-65 minutos de gameplay).

El juego combina:
- **Exploración top-down** tipo Zelda
- **Enemigos mentales** que representan miedos (se esquivan, nunca se lucha)
- **Combate tipo Undertale** donde el protagonista esquiva proyectiles de bullies
- **Flashes tipo Persona 5** que interrumpen el gameplay con pensamientos intrusivos
- **Nivel retro Magic Man** con Pong Evolved + Boss The Wall
- **Composición interactiva de poemas** donde el jugador elige versos
- **Escena del diario** con lista de esperanzas y tachados emocionales

El protagonista, Cristian, **NUNCA lucha**. Solo esquiva. El juego trata sobre sobrevivir, no sobre ganar.

---

## Requisitos Técnicos

| Parámetro | Valor |
|---|---|
| Motor | Godot 4.3 |
| Lenguaje | GDScript |
| Renderer | GL Compatibility |
| Viewport nativo | 320x180 px |
| Ventana | 1280x720 px (x4 stretch) |
| Stretch mode | viewport |
| Filtro de texturas | Nearest Neighbor (pixel art) |
| Tiles | 16x16 px |
| Assets visuales | Pixel art 16x16 (71 sprites PNG) |

---

## Estructura del Proyecto

```
vdh-godot/
├── project.godot              # Configuración del proyecto Godot
├── icon.svg                   # Icono del proyecto
├── .gitignore                 # Exclusiones de Git
├── DOCUMENTACION.md           # Este archivo
│
├── assets/                    # Assets visuales (pixel art 16x16)
│   └── sprites/
│       ├── player/            # 12 sprites — Cristian (idle + walk x4 dirs)
│       │   ├── idle_down.png, idle_up.png, idle_left.png, idle_right.png
│       │   ├── walk_down_1.png, walk_down_2.png
│       │   ├── walk_up_1.png, walk_up_2.png
│       │   ├── walk_left_1.png, walk_left_2.png
│       │   └── walk_right_1.png, walk_right_2.png
│       ├── enemies/           # 3 sprites — Entidades emocionales abstractas
│       │   ├── enemy_fear.png      # Figura fantasmal púrpura
│       │   ├── enemy_sadness.png   # Lágrima azul
│       │   └── enemy_loneliness.png # Sombra gris
│       ├── npcs/              # 8 sprites — Personajes del juego
│       │   ├── lewis.png, joan.png, robert.png, mike.png  # Bullies
│       │   ├── lucy.png           # Compañera amigable
│       │   ├── teacher.png        # Don Peter
│       │   ├── grandma.png        # Abuela
│       │   └── student_generic.png # Estudiante genérico
│       ├── tiles/             # 22 sprites — Suelos, paredes, muebles
│       │   ├── floor_wood.png, floor_tile_kitchen.png, floor_grass.png
│       │   ├── floor_concrete.png, floor_asphalt.png, floor_dirt.png
│       │   ├── floor_classroom.png
│       │   ├── wall_house.png, wall_brick.png, wall_school.png, wall_dark.png
│       │   ├── bed.png, desk.png, door_open.png, door_closed.png
│       │   ├── tree.png, fountain.png, locker.png, blackboard.png
│       │   └── table_student.png, fridge.png, counter.png
│       ├── collectibles/      # 4 sprites — Objetos coleccionables
│       │   ├── comic_page.png      # Página de cómic
│       │   ├── grandma_memory.png  # Orbe dorado de recuerdo
│       │   ├── graffiti.png        # Tag de graffiti con corazón
│       │   └── safe_spot.png       # Rincón seguro con brillo cálido
│       ├── ui/                # 16 sprites — Interfaz y combate
│       │   ├── heart_full.png (8x8), heart_half.png, heart_empty.png
│       │   ├── soul_heart.png (16x16)   # Corazón alma Undertale
│       │   ├── arrow_continue.png (8x8) # Flecha continuar
│       │   ├── interact_icon.png        # Icono tecla "E"
│       │   ├── diary_icon.png           # Icono diario
│       │   ├── guitar_icon.png          # Icono guitarra
│       │   ├── proj_insult.png (16x8)   # Proyectil insulto
│       │   ├── proj_slap.png (12x12)    # Proyectil bofetada
│       │   ├── proj_laugh.png (16x8)    # Proyectil risa "JA"
│       │   ├── proj_paperball.png (8x8) # Bola de papel
│       │   └── silhouette_bully1-4.png (24x32) # Siluetas bullies
│       └── minigames/         # 6 sprites — Nivel Magic Man
│           ├── magic_man.png        # Superhéroe Magic Man
│           ├── paddle.png (8x32)    # Paddle de Pong
│           ├── ball.png (8x8)       # Bola de Pong
│           ├── brick.png (16x8)     # Ladrillo The Wall
│           ├── brick_damaged.png    # Ladrillo dañado
│           └── comic_frame.png (64x48) # Marco viñeta cómic
│
├── data/                      # Datos JSON
│   ├── dialogues/
│   │   └── chapter1.json      # 17 diálogos, 64 líneas del Capítulo 1
│   ├── diary/
│   │   └── diary_chapter1.json # Datos del diario del Capítulo 1
│   └── poems/
│       └── poem_chapter1.json  # Poema interactivo del Capítulo 1
│
├── scenes/                    # Escenas .tscn
│   ├── main_menu.tscn         # Menú principal
│   ├── player/
│   │   └── player.tscn        # Escena del jugador
│   ├── enemies/
│   │   ├── enemy_fear.tscn    # Enemigo Miedo
│   │   ├── enemy_sadness.tscn # Enemigo Tristeza
│   │   └── enemy_loneliness.tscn # Enemigo Soledad
│   ├── collectibles/
│   │   └── secret_item.tscn   # Objeto coleccionable
│   ├── ui/
│   │   ├── hud.tscn           # Heads-Up Display
│   │   ├── dialogue_box.tscn  # Caja de diálogo
│   │   ├── persona_flash.tscn # Flash de pensamiento intrusivo
│   │   ├── grandma_flash.tscn # Flash de recuerdo de abuela
│   │   └── pause_menu.tscn    # Menú de pausa
│   ├── undertale/
│   │   └── undertale_battle.tscn # Escena de combate Undertale
│   ├── minigames/
│   │   └── pong/
│   │       └── ch1_magic_man_pong.tscn # Nivel Magic Man Cap 1
│   └── chapters/
│       └── chapter1/
│           ├── ch1_bedroom_morning.tscn  # Habitación mañana
│           ├── ch1_kitchen.tscn          # Cocina
│           ├── ch1_street.tscn           # Mapa del barrio
│           ├── ch1_classroom.tscn        # Aula del instituto
│           ├── ch1_bedroom_evening.tscn  # Habitación tarde
│           ├── ch1_bedroom_night.tscn    # Habitación noche
│           └── ch1_end.tscn              # Pantalla fin de capítulo
│
└── scripts/                   # Scripts GDScript
    ├── interactable.gd        # Base para objetos interactuables
    ├── cinematic_trigger.gd   # Trigger de secuencias cinemáticas
    ├── managers/
    │   ├── game_manager.gd    # Estado global y progresión
    │   ├── dialogue_manager.gd # Gestión de diálogos
    │   ├── audio_manager.gd   # Música y efectos de sonido
    │   └── transition_manager.gd # Transiciones entre escenas
    ├── player/
    │   ├── player.gd          # Controlador del jugador
    │   └── health_system.gd   # Sistema de vida/corazones
    ├── enemies/
    │   ├── enemy_base.gd      # Base de enemigos
    │   ├── enemy_fear.gd      # Enemigo Miedo
    │   ├── enemy_sadness.gd   # Enemigo Tristeza
    │   └── enemy_loneliness.gd # Enemigo Soledad
    ├── collectibles/
    │   └── secret_item.gd     # Coleccionable secreto
    ├── undertale/
    │   ├── undertale_battle.gd # Sistema de combate
    │   ├── soul_heart.gd      # Corazón del alma (jugador en combate)
    │   └── projectile_base.gd # Base de proyectiles
    ├── minigames/
    │   ├── magic_man_level.gd # Framework de niveles Magic Man
    │   ├── comic_intro.gd     # Viñetas de cómic pre-nivel
    │   ├── pong_evolved.gd    # Juego Pong con 5 fases
    │   ├── boss_base.gd       # Base de jefes
    │   └── boss_the_wall.gd   # Jefe The Wall (Arkanoid invertido)
    ├── ui/
    │   ├── main_menu.gd       # Lógica del menú principal
    │   ├── hud.gd             # Lógica del HUD
    │   ├── dialogue_box.gd    # Lógica de la caja de diálogo
    │   ├── persona_flash.gd   # Flash tipo Persona 5
    │   ├── grandma_flash.gd   # Flash de recuerdo de abuela
    │   ├── flash_trigger.gd   # Trigger de área para flashes
    │   ├── pause_menu.gd      # Menú de pausa
    │   ├── poem_composer.gd   # Compositor de poemas interactivo
    │   └── diary_scene.gd     # Escena del diario
    └── chapters/
        ├── ch1_bedroom_morning.gd  # Lógica habitación mañana
        ├── ch1_kitchen.gd          # Lógica cocina
        ├── ch1_street.gd           # Lógica mapa del barrio
        ├── ch1_classroom.gd        # Lógica aula (secuencia scriptada)
        ├── ch1_bedroom_evening.gd  # Lógica habitación tarde
        ├── ch1_bedroom_night.gd    # Lógica habitación noche
        ├── ch1_end.gd              # Lógica pantalla fin capítulo
        └── ch1_magic_man_pong.gd   # Nivel completo Magic Man Cap 1
```

**Total: 135 archivos** (38 .gd + 20 .tscn + 3 .json + 71 .png + project.godot + icon.svg + .gitignore)

---

## Configuración del Proyecto

### `project.godot`

Archivo de configuración principal de Godot 4.3.

| Sección | Configuración | Valor |
|---|---|---|
| application | Nombre | "Versos de Héroe" |
| application | Escena principal | `res://scenes/main_menu.tscn` |
| application | Features | `4.3, GL Compatibility` |
| display | Viewport | 320x180 |
| display | Ventana | 1280x720 |
| display | Stretch mode | viewport |
| display | Stretch aspect | keep |
| gui | Font size por defecto | 8 |
| rendering | Filtro texturas | Nearest (0) |
| rendering | Renderer | gl_compatibility |

### Input Maps

| Acción | Teclas |
|---|---|
| `move_up` | W, Flecha arriba |
| `move_down` | S, Flecha abajo |
| `move_left` | A, Flecha izquierda |
| `move_right` | D, Flecha derecha |
| `interact` | E, Espacio |
| `confirm` | Enter, Espacio |
| `cancel` | Escape |
| `pause` | Escape |

---

## Assets Visuales (Pixel Art)

Todos los sprites son pixel art generado programáticamente con Python/Pillow. Se usan como texturas PNG cargadas en tiempo de ejecución mediante `load()` o `preload()`.

### Jugador — `assets/sprites/player/` (12 archivos)

Cristian, el protagonista. Chico de 12 años con pelo marrón, sudadera azul, pantalones oscuros.

| Animación | Archivos | FPS |
|---|---|---|
| `idle_down/up/left/right` | 1 frame cada una | 8 |
| `walk_down/up/left/right` | 2 frames cada una (`_1.png`, `_2.png`) | 8 |

Los sprites `right` son mirror horizontal de los `left`.

### Enemigos — `assets/sprites/enemies/` (3 archivos)

Entidades abstractas/fantasmales que representan emociones negativas:

| Archivo | Enemigo | Descripción visual |
|---|---|---|
| `enemy_fear.png` | Miedo | Figura fantasmal púrpura con ojos blancos brillantes |
| `enemy_sadness.png` | Tristeza | Entidad azul en forma de lágrima, un ojo tenue |
| `enemy_loneliness.png` | Soledad | Silueta gris apenas visible, cuencas huecas, fade en bordes |

### NPCs — `assets/sprites/npcs/` (8 archivos)

| Archivo | Personaje | Rasgos visuales |
|---|---|---|
| `lewis.png` | Líder bully | Camiseta roja, pelo puntiagudo, cejas enfadadas |
| `joan.png` | Bully | Camiseta verde, gorra, sonrisa burlona |
| `robert.png` | Bully | Camiseta naranja, corpulento |
| `mike.png` | Bully | Camiseta amarilla, alto y delgado |
| `lucy.png` | Compañera amigable | Top rosa, pelo largo marrón, ojos amables |
| `teacher.png` | Don Peter | Camisa blanca, gafas azules, corbata, pelo gris |
| `grandma.png` | Abuela | Pelo blanco con moño, chal marrón cálido |
| `student_generic.png` | Estudiante genérico | Camisa blanca, pelo marrón, expresión neutral |

### Tiles — `assets/sprites/tiles/` (22 archivos)

Todos 16x16 px, diseñados para tiling (repetición) con `TextureRect.STRETCH_TILE`.

**Suelos (7):** `floor_wood` (madera), `floor_tile_kitchen` (azulejo cocina), `floor_grass` (hierba), `floor_concrete` (hormigón), `floor_asphalt` (asfalto), `floor_dirt` (tierra), `floor_classroom` (linóleo)

**Paredes (4):** `wall_house` (interior crema), `wall_brick` (ladrillo rojo), `wall_school` (institucional gris-azul), `wall_dark` (callejón oscuro)

**Muebles/Objetos (11):** `bed`, `desk`, `door_open`, `door_closed`, `tree`, `fountain`, `locker`, `blackboard`, `table_student`, `fridge`, `counter`

### Coleccionables — `assets/sprites/collectibles/` (4 archivos)

| Archivo | Tipo | Visual |
|---|---|---|
| `comic_page.png` | Página cómic | Papel blanco con paneles de colores y esquina doblada |
| `grandma_memory.png` | Recuerdo abuela | Orbe dorado brillante con glow sepia |
| `graffiti.png` | Graffiti | Pared gris con corazón magenta spray-painted |
| `safe_spot.png` | Rincón seguro | Brillo amarillo cálido con banco marrón |

### UI y Combate — `assets/sprites/ui/` (16 archivos)

| Archivo | Tamaño | Uso |
|---|---|---|
| `heart_full/half/empty.png` | 8x8 | Corazones del HUD |
| `soul_heart.png` | 16x16 | Corazón alma en combate Undertale |
| `arrow_continue.png` | 8x8 | Flecha "continuar" en diálogos |
| `interact_icon.png` | 16x16 | Icono tecla "E" |
| `diary_icon.png` | 16x16 | Icono del diario |
| `guitar_icon.png` | 16x16 | Icono de guitarra |
| `proj_insult.png` | 16x8 | Proyectil insulto (rojo con texto) |
| `proj_slap.png` | 12x12 | Proyectil bofetada (puño) |
| `proj_laugh.png` | 16x8 | Proyectil risa ("JA" amarillo) |
| `proj_paperball.png` | 8x8 | Bola de papel arrugada |
| `silhouette_bully1-4.png` | 24x32 | Siluetas de bullies en combate |

### Minijuegos — `assets/sprites/minigames/` (6 archivos)

| Archivo | Tamaño | Uso |
|---|---|---|
| `magic_man.png` | 16x16 | Superhéroe Magic Man (traje azul, estrella amarilla) |
| `paddle.png` | 8x32 | Paddle de Pong (blanco con tinte azul) |
| `ball.png` | 8x8 | Bola de Pong (círculo blanco) |
| `brick.png` | 16x8 | Ladrillo de The Wall (rojo-marrón) |
| `brick_damaged.png` | 16x8 | Ladrillo dañado (con grietas) |
| `comic_frame.png` | 64x48 | Marco de viñeta de cómic (borde negro irregular) |

---

## Autoloads (Singletons)

Los autoloads son nodos globales accesibles desde cualquier script. Se cargan automáticamente al iniciar el juego.

### `GameManager` — `scripts/managers/game_manager.gd`

Controla el estado global del juego, la progresión entre capítulos y los coleccionables.

**Variables de estado:**
- `current_chapter: int` — Capítulo actual (empieza en 1)
- `current_exploration_scene: String` — Ruta de la escena de exploración actual (para volver tras combates)
- `game_started: bool` — Si se ha iniciado una partida
- `max_hearts_by_chapter: Dictionary` — Corazones máximos por capítulo: `{1: 9, 2: 8, 3: 7, ..., 8: 1}`
- `collected_items: Dictionary` — Items recogidos (`{item_id: true}`)
- `comic_pages_count: int` — Páginas de cómic recogidas
- `grandma_memories_count: int` — Recuerdos de abuela recogidos
- `chapter_flags: Dictionary` — Flags de progresión del capítulo
- `player_ref: CharacterBody2D` — Referencia al nodo del jugador

**Señales:**
- `item_collected(item_id, item_type)` — Emitida al recoger un item
- `chapter_started(chapter)` — Emitida al comenzar un capítulo
- `chapter_ended(chapter)` — Emitida al terminar un capítulo

**Funciones principales:**
- `start_new_game()` — Reinicia todo el estado y emite `chapter_started`
- `get_max_hearts() -> int` — Devuelve los corazones máximos del capítulo actual
- `is_collected(item_id) -> bool` — Comprueba si un item ya fue recogido
- `collect_item(item_id, item_type)` — Registra un item recogido. Cada 5 páginas de cómic otorga +0.5 corazón bonus
- `set_flag(flag_name, value)` / `get_flag(flag_name) -> bool` — Flags de progresión
- `set_exploration_scene(scene_path)` — Establece la escena a la que volver tras combates
- `screen_shake(intensity, duration)` — Efecto de temblor de cámara

---

### `DialogueManager` — `scripts/managers/dialogue_manager.gd`

Gestiona la carga de diálogos desde JSON y controla el flujo de conversaciones.

**Variables:**
- `dialogues: Dictionary` — Todos los diálogos cargados
- `current_dialogue: Array` — Líneas del diálogo activo
- `current_line: int` — Índice de la línea actual
- `is_active: bool` — Si hay un diálogo en curso

**Señales:**
- `dialogue_started` — Emitida al iniciar un diálogo
- `dialogue_ended` — Emitida al terminar un diálogo
- `line_displayed(speaker, text, emotion, portrait)` — Emitida al mostrar cada línea

**Funciones:**
- `load_dialogues(path)` — Carga diálogos desde un JSON. Hace merge si se llama varias veces
- `start_dialogue(id)` — Inicia un diálogo por su ID
- `advance()` — Avanza a la siguiente línea
- `end_dialogue()` — Termina el diálogo actual

**Nota:** El manejo de input (skip typewriter / avanzar) está en `dialogue_box.gd`, no aquí.

---

### `AudioManager` — `scripts/managers/audio_manager.gd`

Gestiona la reproducción de música y efectos de sonido. Tiene fallback graceful cuando los archivos de audio no existen.

**Funciones:**
- `play_music(track_name, fade_in)` — Reproduce música desde `res://assets/audio/music/`. Si no existe el archivo, simplemente no reproduce
- `stop_music(fade_out)` — Para la música con fade out
- `play_sfx(sfx_name)` — Reproduce un efecto desde `res://assets/audio/sfx/`
- `crossfade_music(new_track, duration)` — Crossfade entre pistas

**Nota:** No hay archivos de audio en el MVP. El AudioManager funciona silenciosamente sin errores.

---

### `TransitionManager` — `scripts/managers/transition_manager.gd`

Gestiona las transiciones de escena con efectos de fade.

**Tipo:** `CanvasLayer` (layer 100 — la capa más alta)

**Variables:**
- `is_transitioning: bool` — Si hay una transición en curso

**Señales:**
- `transition_finished` — Emitida cuando la transición termina

**Funciones:**
- `change_scene(scene_path)` — Fade to black → cambia escena → fade from black
- `return_from_battle()` — Vuelve a `GameManager.current_exploration_scene`
- `fade_to_black_only(duration)` — Solo el fade a negro (sin cambio de escena)
- `fade_from_black_only(duration)` — Solo el fade desde negro

---

### `PauseMenu` — `scenes/ui/pause_menu.tscn` + `scripts/ui/pause_menu.gd`

Menú de pausa accesible con ESC en cualquier momento.

**Tipo:** `CanvasLayer` (layer 95)

**Comportamiento:**
- ESC alterna entre pausar/resumir
- No interrumpe diálogos activos (`DialogueManager.is_active`)
- No interrumpe transiciones (`TransitionManager.is_transitioning`)
- Pausa el árbol completo (`get_tree().paused = true`)
- `process_mode = ALWAYS` para funcionar durante la pausa

**Botones:**
- "Continuar" — Resume el juego
- "Menu Principal" — Vuelve al menú principal

---

## Sistema del Jugador

### `scripts/player/player.gd`

**Extiende:** `CharacterBody2D`

El controlador principal del jugador. Gestiona movimiento, animaciones, interacción y daño.

**Propiedades exportadas:**
- `speed: float = 120.0` — Velocidad de movimiento en px/s

**Variables de estado:**
- `direction: Vector2` — Dirección actual de movimiento
- `can_move: bool = true` — Si el jugador puede moverse (desactivado durante diálogos/cinemáticas)
- `facing: String = "down"` — Dirección a la que mira (up/down/left/right)
- `is_invincible: bool` — Si tiene i-frames activos
- `invincibility_timer: float` — Temporizador de invencibilidad (1.5s)

**Nodos hijo (definidos en `player.tscn`):**
- `AnimatedSprite2D` — Sprite animado (placeholder: rectángulos de colores por dirección)
- `CollisionShape2D` — Forma de colisión (8x14 px)
- `InteractionArea` (Area2D) — Zona de interacción (16x16 px, desplazada hacia delante, `collision_mask = 2`)
- `HealthSystem` (Node) — Sistema de vida

**Funcionalidad:**
- **Movimiento:** 4 direcciones con WASD/flechas, velocidad 120px/s, `move_and_slide()`
- **Interacción:** Al pulsar E/Espacio, detecta el Area2D más cercano con método `interact()` y lo ejecuta
- **Daño:** Flash rojo, knockback, screen shake, 1.5s de invencibilidad con parpadeo
- **Curación:** Delega al HealthSystem
- **Indicador "E":** Label flotante que aparece cuando hay un interactuable cerca

**Animaciones:**
8 animaciones cargadas desde sprites PNG en `assets/sprites/player/`:
- 4 idle (1 frame) + 4 walk (2 frames) a 8 FPS
- Pixel art con filtro `TEXTURE_FILTER_NEAREST`

---

### `scripts/player/health_system.gd`

**Extiende:** `Node`

Sistema de vida con corazones. Nodo hijo del jugador.

**Señales:**
- `health_changed(current, max_health)` — Emitida al cambiar la vida
- `player_died` — Emitida cuando la vida llega a 0

**Variables:**
- `max_hearts: int = 9` — Corazones máximos (se inicializa desde GameManager)
- `current_health: float` — Vida actual
- `bonus_hearts: float = 0.0` — Corazones bonus (por páginas de cómic)

**Funciones:**
- `take_damage(amount)` — Reduce vida, emite señales
- `heal(amount)` — Recupera vida hasta el máximo
- `add_bonus_heart(amount)` — Añade corazones bonus
- `get_effective_max() -> float` — Devuelve `max_hearts + bonus_hearts`
- `reset()` — Restaura vida al máximo

---

### `scenes/player/player.tscn`

Escena del jugador con la siguiente jerarquía:
```
Player (CharacterBody2D) → player.gd
  ├── AnimatedSprite2D
  ├── CollisionShape2D (RectangleShape2D 8x14)
  ├── InteractionArea (Area2D, collision_mask=2)
  │   └── CollisionShape2D (RectangleShape2D 16x16, offset y+10)
  └── HealthSystem (Node) → health_system.gd
```

---

## Sistema de Diálogos

### `scripts/ui/dialogue_box.gd`

**Extiende:** `Control`

Controla la UI de la caja de diálogo con efecto typewriter.

**Funcionalidad:**
- Se conecta a las señales del `DialogueManager`
- Efecto typewriter: muestra caracteres uno a uno (0.03s por carácter)
- Al pulsar E/Espacio durante el typewriter: salta al texto completo
- Al pulsar E/Espacio con texto completo: avanza al siguiente diálogo
- Animación de entrada (slide up) y salida (slide down)
- Flecha "▼" parpadeante cuando el texto está completo
- Colores de retrato según emoción:
  - neutral=gris, scared=azul, mocking=naranja, threatening=rojo
  - sad=púrpura, happy=amarillo, hopeful=verde

### `scenes/ui/dialogue_box.tscn`

**Tipo:** `CanvasLayer` (layer 10)

Caja de diálogo anclada en la parte inferior de la pantalla (44px de alto). Contiene:
- Panel semi-transparente oscuro con borde azulado
- Retrato de 24x24 px (placeholder)
- Nombre del hablante (amarillo, 7px)
- Texto del diálogo (blanco, 7px, RichTextLabel)
- Flecha de continuar "▼" (esquina inferior derecha)

---

## Sistema de Enemigos

### `scripts/enemies/enemy_base.gd`

**Extiende:** `CharacterBody2D`

Clase base para todos los enemigos mentales. Los enemigos representan emociones negativas y dañan al jugador al contacto.

**Estados:** `IDLE`, `PATROL`, `CHASE`

**Propiedades exportadas:**
- `move_speed: float` — Velocidad de movimiento
- `detection_range: float` — Rango de detección del jugador
- `damage: float` — Daño al contacto
- `patrol_points: Array[Vector2]` — Puntos de patrulla

**Comportamiento:**
- **IDLE:** Quieto, busca al jugador en rango de detección
- **PATROL:** Camina entre puntos de patrulla
- **CHASE:** Persigue al jugador hasta que sale de rango

Visual: `Sprite2D` con textura PNG específica por tipo, cargada desde `assets/sprites/enemies/`.

---

### `scripts/enemies/enemy_fear.gd` — Enemigo Miedo

**Extiende:** `enemy_base.gd`

| Parámetro | Valor |
|---|---|
| Velocidad | 60 px/s |
| Daño | 0.5 corazones |
| Rango detección | 150 px |
| Color | Púrpura oscuro `(0.4, 0.1, 0.5)` |
| Comportamiento | Persigue lentamente al jugador |

---

### `scripts/enemies/enemy_sadness.gd` — Enemigo Tristeza

**Extiende:** `enemy_base.gd`

| Parámetro | Valor |
|---|---|
| Velocidad | 40 px/s |
| Daño | 0.5 corazones |
| Color | Azul oscuro `(0.15, 0.15, 0.5)` |
| Comportamiento | Patrulla circular alrededor de su posición central |

---

### `scripts/enemies/enemy_loneliness.gd` — Enemigo Soledad

**Extiende:** `enemy_base.gd`

| Parámetro | Valor |
|---|---|
| Velocidad | 80 px/s |
| Daño | 1.0 corazón |
| Color | Gris oscuro `(0.3, 0.3, 0.35)` |
| Comportamiento | Invisible al principio. Aparece con fade-in si el jugador está quieto 3 segundos. Luego hace dash hacia el jugador |

---

### Escenas de enemigos

Cada enemigo tiene su `.tscn` en `scenes/enemies/`:
```
Enemy (CharacterBody2D) → enemy_[tipo].gd
  ├── CollisionShape2D (RectangleShape2D)
  └── Hitbox (Area2D, collision_layer=4)
      └── CollisionShape2D
```

---

## Sistema de Combate Undertale

### `scripts/undertale/undertale_battle.gd`

**Extiende:** `Control`

Sistema de combate donde el jugador (corazón rojo) esquiva proyectiles de los bullies dentro de un recuadro.

**Señales:**
- `battle_finished` — Emitida al terminar todas las oleadas

**Configuración de oleadas (Cap 1):**
| Oleada | Duración | Intervalo | Tipos | Velocidad |
|---|---|---|---|---|
| 1 | 10s | 0.8s | insult | 100 px/s |
| 2 | 12s | 0.6s | insult, slap | 120 px/s |
| 3 | 12s | 0.5s | insult, slap, laugh, paperball | 100 px/s |

**Tipos de proyectiles:**
- `insult` — Palabras ofensivas ("pringao", "freaky", "rarito", "bicho"), texto rojo
- `slap` — Emoji de puño, cuadrado pequeño
- `laugh` — "JAJA" amarillo, movimiento sinusoidal
- `paperball` — Punto marrón, ligera oscilación

**UI de combate (construida en código):**
- Fondo negro
- Siluetas de bullies arriba (Lewis, Joan, Robert, Mike)
- BattleBox: recuadro blanco de 240x90 px donde el corazón se mueve
- HP display abajo izquierda
- Indicador de oleada abajo derecha

**Flujo:**
1. `start_battle()` → pausa el juego, muestra UI
2. Spawna proyectiles desde los 4 lados del BattleBox
3. Tras cada oleada, pausa 1.5s y comienza la siguiente
4. Tras la última oleada → despausa, limpia UI, emite `battle_finished`

---

### `scripts/undertale/soul_heart.gd`

**Extiende:** `CharacterBody2D`

El corazón rojo que el jugador controla durante el combate Undertale.

- Velocidad: 200 px/s
- Movimiento con flechas, clampeado al BattleBox
- I-frames con parpadeo al recibir daño
- `setup(battle_box_rect)` — Configura los límites de movimiento
- `take_damage(amount)` — Delega al HealthSystem del jugador

---

### `scripts/undertale/projectile_base.gd`

**Extiende:** `Area2D`

Base para proyectiles del combate. Movimiento direccional, auto-destrucción fuera de pantalla.

---

## Sistema de Flashes (Persona 5)

### `scripts/ui/persona_flash.gd`

**Extiende:** `CanvasLayer` (layer 90)

Flash de pensamiento intrusivo que interrumpe el gameplay momentáneamente.

**Grupo:** `"persona_flash"` (para que los FlashTrigger lo encuentren)

**Frases del Capítulo 1:** 6 frases de bullying en español

**Efecto:**
1. Pausa el juego
2. Overlay rojo oscuro `(0.3, 0, 0, 0.9)`
3. Texto grande blanco, ligeramente rotado (-8° a +8°)
4. Animación: scale 1.5→1.0, fade in (0.15s), hold (0.6s), fade out (0.2s)
5. Despausa el juego

---

### `scripts/ui/grandma_flash.gd`

**Extiende:** `CanvasLayer` (layer 90)

Variante cálida del flash para recuerdos de la abuela.

**Grupo:** `"grandma_flash"`

**Diferencias con PersonaFlash:**
- Overlay sepia `(0.6, 0.5, 0.3, 0.85)` en vez de rojo
- Texto color crema `(1.0, 0.97, 0.88)` en vez de blanco
- Rotación más suave (-5° a +5°)
- Hold más largo (1.0s en vez de 0.6s)

---

### `scripts/ui/flash_trigger.gd`

**Extiende:** `Area2D`

Trigger de área que activa un flash cuando el jugador entra.

**Propiedades exportadas:**
- `flash_phrase: String` — Frase específica (vacío = aleatoria)
- `one_shot: bool` — Si solo se activa una vez

**Comportamiento:**
- Detecta al jugador por grupo `"player"`
- Busca el nodo PersonaFlash via `get_tree().get_first_node_in_group("persona_flash")`
- Llama a `trigger_flash(flash_phrase)`

---

## Sistema de Coleccionables

### `scripts/collectibles/secret_item.gd`

**Extiende:** `Area2D`

Objeto coleccionable con 4 tipos diferentes.

**Propiedades exportadas:**
- `item_id: String` — ID único del item
- `item_type: String` — Tipo: `comic_page`, `grandma_memory`, `graffiti`, `safe_spot`
- `display_text: String` — Texto a mostrar al recoger

**Comportamiento por tipo:**

| Tipo | Efecto al recoger |
|---|---|
| `comic_page` | Notificación. Cada 5 páginas = +0.5 corazón bonus |
| `grandma_memory` | Trigger de GrandmaFlash con frase del recuerdo |
| `graffiti` | Inicia diálogo asociado al `display_text` |
| `safe_spot` | Cura al jugador + pausa breve de seguridad |

**Visual:** `Sprite2D` con textura PNG del tipo correspondiente (`assets/sprites/collectibles/`). Efecto de pulso (glow) animado con tween sobre `modulate:a`.

---

## Minijuegos — Magic Man

### `scripts/minigames/magic_man_level.gd`

**Extiende:** `Node2D`

Framework genérico para niveles de Magic Man con fases: `INTRO → GAMEPLAY → BOSS → VICTORY`.

- 3 vidas de Magic Man
- Gestiona el flujo entre las diferentes fases

---

### `scripts/minigames/comic_intro.gd`

**Extiende:** `Control`

Viñetas de cómic que se muestran antes del nivel de Magic Man.

**Señales:**
- `intro_finished` — Emitida al completar todas las viñetas

**Funcionalidad:**
- Muestra paneles de texto en secuencia con fade-in
- El jugador avanza con E/Espacio
- Contador de panel actual (ej: "2/4")
- Fondo azul oscuro con borde simulado

---

### `scripts/minigames/pong_evolved.gd`

**Extiende:** `Node2D`

Juego de Pong con 5 fases progresivas.

**Señales:**
- `gameplay_finished` — Emitida al completar el Pong

**Fases:**
| Fase | Característica |
|---|---|
| 1 | 1 bola normal |
| 2 | 2 bolas simultáneas |
| 3 | Bola con trail + obstáculos |
| 4 | Enemigo con segundo paddle |
| 5 | Bola invisible (solo visible al rebotar) |

**Mecánica:**
- IA deliberadamente imperfecta (factor velocidad 0.55 + margen de error)
- Victoria al alcanzar 10 puntos
- Paddle controlado con flechas arriba/abajo

---

### `scripts/minigames/boss_the_wall.gd`

**Extiende:** `Node2D`

Boss tipo Arkanoid invertido: un muro de ladrillos avanza hacia el paddle del jugador.

**Señales:**
- `boss_defeated` — Emitida al destruir todos los ladrillos

**Estructura:**
- Muro de 5x8 ladrillos que avanza gradualmente
- Bola que el jugador debe rebotar contra el muro
- 3 fases de dificultad:
  1. Normal
  2. Muro avanza más rápido
  3. El muro lanza proyectiles
- Ángulo de rebote controlado por posición de impacto en el paddle

---

### `scripts/minigames/boss_base.gd`

**Extiende:** `Node2D`

Clase base para jefes con HP, fases y efectos de daño (flash blanco).

---

### `scripts/chapters/ch1_magic_man_pong.gd`

**Extiende:** `Node2D`

Nivel completo de Magic Man para el Capítulo 1.

**Fases:** `INTRO → PONG → BOSS → VICTORY`

**Flujo:**
1. **Comic intro** (4 paneles): Historia de Magic Man patrullando Loud City
2. **Pong Evolved**: 5 fases progresivas
3. **Transición**: "¡Magic Man se enfrenta a THE WALL!"
4. **Boss The Wall**: Arkanoid invertido
5. **Victoria**: "¡MAGIC MAN VENCE!" + texto de victoria
6. Esperar input → volver a `ch1_bedroom_night.tscn`

---

## Sistema de Poemas

### `scripts/ui/poem_composer.gd`

**Extiende:** `Control`

Compositor interactivo de poemas donde el jugador elige versos.

**Señales:**
- `poem_finished(score, verses)` — Emitida al completar el poema

**Mecánica:**
- Fondo de panel de papel
- Texto de contexto con typewriter
- Hueco parpadeante para el verso a elegir
- 3 botones de opción (mezclados aleatoriamente)
- Cada opción tiene puntuación: +1 (esperanzada), 0 (neutral), -1 (oscura)
- `resonance_score` acumulado

**Reacciones finales:**
- Score alto: Reacción esperanzada
- Score medio: Reacción neutral
- Score bajo: Reacción oscura

---

## Sistema del Diario

### `scripts/ui/diary_scene.gd`

**Extiende:** `Control`

Escena del diario con múltiples fases interactivas.

**Señales:**
- `diary_finished` — Emitida al completar toda la secuencia

**Fases:** `TEXT → HOPE_LIST → POEM → TITLE`

| Fase | Descripción |
|---|---|
| TEXT | Texto del diario con efecto typewriter sobre fondo de papel |
| HOPE_LIST | Lista de esperanzas. Algunas se tachan con animación (color rojo, texto "[TACHADO]"). Algunas tiemblan |
| POEM | Se carga el PoemComposer como hijo. El jugador compone un poema interactivo |
| TITLE | Título del poema + autor con fade in. Ej: "Todo Cambiará" por Cristian |

**Datos:** Cargados desde `data/diary/diary_chapter1.json`

---

## Interfaz de Usuario (UI)

### `scripts/ui/main_menu.gd` + `scenes/main_menu.tscn`

Menú principal del juego.

**Elementos:**
- Fondo oscuro `(0.1, 0.1, 0.15)`
- Título "VERSOS DE HÉROE" (14px, blanco)
- Botón "Nueva Partida" → `GameManager.start_new_game()` + transición a habitación mañana
- Botón "Salir" → `get_tree().quit()`
- Subtítulo "Apañeros Producciones" (6px, gris)

**Navegación:** Teclado con flechas arriba/abajo, highlight amarillo en focus.

---

### `scripts/ui/hud.gd` + `scenes/ui/hud.tscn`

HUD (Heads-Up Display) visible durante el gameplay.

**Tipo:** `CanvasLayer` (layer 5)

**Elementos:**
- **Corazones** (esquina superior izquierda): TextureRect 8x8 con sprites PNG (`heart_full/half/empty.png`)
- **Capítulo** (centro superior): "Cap.1" (6px)
- **Páginas** (esquina superior derecha): "0/5" (6px)
- **Hint de interacción** (esquina inferior derecha): "[E]" (oculto por defecto)

**Conexión:** Se conecta automáticamente al `HealthSystem` del jugador vía grupo `"player"`.

---

### `scripts/interactable.gd`

**Extiende:** `Area2D`

Script genérico para objetos interactuables en el mundo.

**Propiedades exportadas:**
- `interaction_type: String` — `"dialogue"`, `"transition"`, o `"item"`
- `dialogue_id: String` — ID del diálogo a iniciar
- `target_scene: String` — Ruta de la escena destino

**Señales:**
- `interacted` — Emitida para tipo `"item"`

**Método `interact()`:**
- `"dialogue"` → `DialogueManager.start_dialogue(dialogue_id)`
- `"transition"` → `TransitionManager.change_scene(target_scene)`
- `"item"` → emite señal `interacted`

---

### `scripts/cinematic_trigger.gd`

**Extiende:** `Area2D`

Trigger para secuencias cinemáticas (diálogos + transiciones en secuencia).

**Propiedades exportadas:**
- `trigger_dialogue: String` — Diálogo a reproducir
- `trigger_scene: String` — Escena a transicionar después
- `one_shot: bool` — Si solo se activa una vez
- `auto_disable_player: bool` — Si desactiva el movimiento del jugador

**Señales:**
- `cinematic_started` / `cinematic_ended`

---

## Escenas del Capítulo 1

Todas las escenas de capítulo usan `.tscn` mínimos (solo nodo raíz + referencia al script) y construyen toda la geometría en `_ready()` mediante código. Los suelos y paredes usan `TextureRect` con tiles PNG en modo `STRETCH_TILE`. Los muebles y NPCs usan `Sprite2D` con texturas PNG.

### `ch1_bedroom_morning.gd` — Habitación Mañana

**Primera escena del juego.** Habitación de Cristian.

| Parámetro | Valor |
|---|---|
| Tamaño sala | 160x128 px (10x8 tiles) |
| Offset viewport | (80, 26) — centrado en 320x180 |
| Suelo | Marrón madera |
| Paredes | Marrón oscuro, con hueco para puerta |

**Objetos interactuables:**
| Objeto | Tipo | Acción |
|---|---|---|
| Puerta (abajo) | transition | → `ch1_kitchen.tscn` |
| Guitarra | dialogue | "interact_guitar" |
| Cómic | dialogue | "interact_comic" |
| Póster | dialogue | "interact_poster" |
| Figura Magic Man | dialogue | "interact_figure" |

**Muebles con colisión:** Cama (azul oscuro), Escritorio (gris)

**Flujo:**
1. Carga diálogos de `chapter1.json`
2. Spawna jugador en el centro, `can_move = false`
3. Reproduce diálogo "bedroom_morning" automáticamente
4. Al terminar → habilita movimiento

---

### `ch1_kitchen.gd` — Cocina

| Parámetro | Valor |
|---|---|
| Tamaño sala | 192x128 px (12x8 tiles) |
| Offset viewport | (64, 26) |
| Suelo | Beige azulejo |

**Objetos interactuables:**
| Objeto | Tipo | Acción |
|---|---|---|
| Puerta (arriba) | transition | → `ch1_street.tscn` |
| Nevera | dialogue | "kitchen_postit" |

**Flujo:**
1. Spawna jugador, `can_move = false`
2. Reproduce diálogo "kitchen_postit" automáticamente (el post-it de mamá)
3. Al terminar → habilita movimiento
4. El jugador puede salir por la puerta hacia la calle

---

### `ch1_street.gd` — Mapa del Barrio

**Escena de exploración principal.** Mapa grande con 4 zonas.

| Parámetro | Valor |
|---|---|
| Tamaño mapa | 1280x960 px |
| Cámara | Límites al mapa, smoothing |
| Spawn | (100, 120) — Entrada del edificio de Cristian |

**Zona 1 — Calle Residencial** (0,0 — ~400x320):
- Aceras, carretera, edificios con colisión
- Entrada del edificio de Cristian
- 1x Enemigo Miedo (patrulla rectangular)
- 1x Página de cómic (en callejón)

**Zona 2 — Parque** (200,280 — ~480x400):
- Hierba, caminos, fuente, río
- 13 árboles con colisión
- 2x Enemigo Miedo + 1x Enemigo Tristeza
- FlashTrigger en la fuente: "No quiero ir" (one_shot)
- Coleccionables: safe_spot, grandma_memory, graffiti

**Zona 3 — Calle del Instituto** (680,0 — ~400x240):
- Tiendas cerradas, callejón oscuro
- 2x Enemigo Miedo + 1x Enemigo Soledad
- Coleccionables: comic_page, graffiti

**Zona 4 — Exterior del Instituto** (720,560 — ~560x400):
- Patio de hormigón, muros del instituto
- Puerta principal (visual, Cristian la evita)
- Puerta lateral interactuable → `ch1_classroom.tscn`
- 1x Página de cómic (en taquilla rota)

**UI instanciada:** HUD, DialogueBox, PersonaFlash, GrandmaFlash

**Diálogo inicial:** "street_exit" al entrar por primera vez (usa GameManager flag)

---

### `ch1_classroom.gd` — Aula del Instituto

**Secuencia completamente scriptada** — sin exploración libre.

| Parámetro | Valor |
|---|---|
| Tamaño aula | 560x400 px |
| Spawn | (280, 380) — puerta del pasillo |

**Layout:**
- Pasillo con taquillas (franja inferior)
- Pared divisoria con hueco de puerta
- Pizarra verde con "3-A"
- Mesa del profesor
- 20 mesas de estudiantes (4 filas x 5 columnas)
- NPCs: Lewis, Joan, Robert, Mike (bullies), Lucy, 8 estudiantes genéricos
- Profesor Don Peter (oculto inicialmente)

**Fases (máquina de estados):**
| Fase | Acción |
|---|---|
| ENTERING | Auto-walk del jugador desde la puerta hasta su asiento |
| DIALOGUE_PRE | Diálogo "classroom_pre_attack" (bullies insultan a Cristian) |
| BATTLE | Combate Undertale con 3 oleadas |
| DIALOGUE_POST | Diálogo "classroom_post_attack" (Lewis amenaza) |
| FADE_OUT | Fade a negro → transición a `ch1_bedroom_evening.tscn` |

---

### `ch1_bedroom_evening.gd` — Habitación Tarde

Habitación de Cristian con tinte cálido de atardecer.

| Parámetro | Valor |
|---|---|
| Modulate | `Color(1.0, 0.85, 0.65)` — tinte cálido |
| Paredes | Cerradas (sin puerta — Cristian está en casa) |

**Objetos interactuables:**
| Objeto | Tipo | Efecto especial |
|---|---|---|
| Guitarra | dialogue | "interact_guitar_evening" → cura 0.5 corazón |
| Consola | dialogue | "interact_console" |
| Cómic | dialogue | "interact_comic_evening" → transición a Magic Man |
| Póster | dialogue | Diálogo estándar |
| Figura MM | dialogue | Diálogo estándar |

**UI instanciada:** HUD, DialogueBox, PersonaFlash, GrandmaFlash

**Flujo:**
1. Diálogo "bedroom_evening_intro" automático
2. Exploración libre
3. Al interactuar con el cómic → diálogo → transición a `ch1_magic_man_pong.tscn`

---

### `ch1_bedroom_night.gd` — Habitación Noche

Habitación de Cristian con tinte nocturno oscuro.

| Parámetro | Valor |
|---|---|
| Modulate | `Color(0.75, 0.55, 0.35)` — tinte cálido nocturno |

**Elementos especiales:**
- **Diario** (dorado 10x8): `interaction_type="item"`. Al interactuar:
  1. Desactiva movimiento
  2. Diálogo "bedroom_evening_diary"
  3. Crea DiaryScene en CanvasLayer 50
  4. `start_diary(1)` → todo el flujo del diario
  5. Al terminar → transición a `ch1_end.tscn`

- **PersonaFlash automático** a los 3 segundos: "Casi me desnudan..."

---

### `ch1_end.gd` — Pantalla Fin de Capítulo

Pantalla negra con texto que aparece en secuencia con fade-in.

**Secuencia:**
1. "Capitulo 1" (14px, blanco) — fade in 1.5s
2. "Todo Cambiara" (10px, beige cálido) — fade in 1.5s
3. "Continuara..." (7px, gris) — fade in 1.0s
4. Espera input o 5 segundos
5. Emite `GameManager.chapter_ended(1)` → vuelve a `main_menu.tscn`

---

## Datos JSON

### `data/dialogues/chapter1.json`

17 diálogos con 64 líneas totales. Cada diálogo tiene un ID y un array de líneas.

**Formato de cada línea:**
```json
{
  "speaker": "Cristian",
  "text": "Texto del diálogo...",
  "emotion": "neutral"
}
```

**Emociones usadas:** `neutral`, `scared`, `mocking`, `threatening`, `sad`, `hopeful`

**IDs de diálogo:**
| ID | Escena | Líneas | Descripción |
|---|---|---|---|
| bedroom_morning | Habitación | 3 | Despertar del lunes |
| interact_comic | Habitación | 3 | Cómic de Magic Man |
| interact_guitar | Habitación | 2 | Tocar la guitarra |
| interact_poster | Habitación | 2 | Póster de Magic Man |
| interact_figure | Habitación | 3 | Figura de Magic Man |
| kitchen_postit | Cocina | 4 | Post-it de mamá, comer solo |
| street_exit | Calle | 3 | Salir de casa con cuidado |
| classroom_pre_attack | Aula | 7 | Bullies insultan a Cristian |
| classroom_post_attack | Aula | 5 | Lewis amenaza |
| bedroom_evening_intro | Hab. tarde | 4 | Llegar a casa agotado |
| interact_console | Hab. tarde | 3 | Jugar sin resultado |
| interact_guitar_evening | Hab. tarde | 5 | Guitarra sana |
| interact_comic_evening | Hab. tarde | 6 | Leer Magic Man |
| bedroom_evening_diary | Hab. noche | 7 | Descubrir el diario |
| graffiti_1 | Calle | 3 | "No estás solo" |
| graffiti_2 | Calle | 3 | "El arte salva" |
| grandma_memory_1 | Parque | 6 | Recuerdo de la abuela |

---

### `data/diary/diary_chapter1.json`

Datos del diario del Capítulo 1.

**Contenido:**
- `diary_text` — Texto largo del diario de Cristian
- `hope_lines` — Array de líneas de esperanza con propiedades:
  - `text` — Texto de la línea
  - `crossed` — Si está tachada (`false` en Cap 1 — todas intactas)
  - `shake` — Si tiembla al mostrarse
- `lines_to_cross` — Índices de líneas a tachar
- `poem_path` — Ruta al JSON del poema
- `poem_title` — "Todo Cambiará"
- `poem_author` — "Cristian"

---

### `data/poems/poem_chapter1.json`

Poema interactivo del Capítulo 1.

**Estructura:**
- `context` — Texto introductorio
- `verses` — Array de versos con opciones:
  - `fixed_text` — Texto fijo antes del hueco
  - `options` — 3 opciones para elegir:
    - `text` — Texto de la opción
    - `score` — Puntuación (+1, 0, -1)
- `reactions` — 3 reacciones según puntuación total

---

## Flujo Completo del Juego

```
Main Menu
  │
  ├── "Nueva Partida"
  │
  ▼
Habitación Mañana (ch1_bedroom_morning)
  │ Diálogo automático → exploración → interactuar con objetos
  │ Puerta →
  ▼
Cocina (ch1_kitchen)
  │ Diálogo automático (post-it) → puerta →
  ▼
Calle / Barrio (ch1_street)
  │ Exploración libre:
  │   - 6 enemigos mentales (esquivar)
  │   - 7 coleccionables secretos
  │   - Flash trigger en la fuente
  │   - Puerta lateral del instituto →
  ▼
Aula del Instituto (ch1_classroom)
  │ Secuencia scriptada:
  │   1. Auto-walk a asiento
  │   2. Diálogo pre-ataque
  │   3. Combate Undertale (3 oleadas)
  │   4. Diálogo post-ataque
  │   5. Fade →
  ▼
Habitación Tarde (ch1_bedroom_evening)
  │ Diálogo automático → exploración:
  │   - Guitarra cura 0.5 corazón
  │   - Consola (diálogo)
  │   - Cómic →
  ▼
Magic Man (ch1_magic_man_pong)
  │ 1. Comic intro (4 viñetas)
  │ 2. Pong Evolved (5 fases)
  │ 3. Boss The Wall (Arkanoid invertido)
  │ 4. Pantalla victoria →
  ▼
Habitación Noche (ch1_bedroom_night)
  │ Flash automático → exploración:
  │   - Diario →
  ▼
Diario + Poema (diary_scene + poem_composer)
  │ 1. Texto diario (typewriter)
  │ 2. Lista de esperanzas
  │ 3. Composición de poema interactivo
  │ 4. Título del poema →
  ▼
Fin de Capítulo (ch1_end)
  │ "Capitulo 1" → "Todo Cambiará" → "Continuará..."
  │ →
  ▼
Main Menu
```

---

## Convenciones de Código

- **Idioma:** Comentarios en español, nombres de variables/funciones en inglés
- **Indentación:** Tabs (estándar GDScript)
- **Escenas mínimas:** Los `.tscn` solo contienen el nodo raíz y la referencia al script. Toda la geometría se construye en `_ready()` por código
- **Señales para comunicación:** Los sistemas se comunican mediante señales, no referencias directas
- **Fallback graceful:** Los managers (Audio, Dialogue) no crashean si faltan archivos
- **Grupos para descubrimiento:** `"player"`, `"persona_flash"`, `"grandma_flash"`, `"soul"`, `"projectiles"`
- **Prefijo `_`:** Para funciones privadas/internas
- **`@export`:** Para propiedades configurables desde el editor
- **`@onready`:** Para referencias a nodos hijo
- **Sprites:** Todos los visuales usan `Sprite2D` o `TextureRect` con texturas PNG de `assets/sprites/`. Siempre con `texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST` para pixel art
- **Tiling:** Áreas grandes (suelos, paredes) usan `TextureRect` con `stretch_mode = STRETCH_TILE`
- **Assets generados:** Los sprites fueron generados con Python/Pillow (scripts `.py` en cada carpeta de assets)

---

## Capas de Colisión

| Capa | Bit | Uso |
|---|---|---|
| Player | 1 | Cuerpo del jugador (`CharacterBody2D`) |
| Walls/Interactables | 2 | Paredes (`StaticBody2D`), objetos interactuables (`Area2D`) |
| Enemies | 4 | Hitbox de enemigos (`Area2D`) |
| Collectibles | 8 | Coleccionables (`Area2D`) |

**Masks del jugador:**
- Body: `collision_layer = 1`, `collision_mask = 2` (colisiona con paredes)
- InteractionArea: `collision_layer = 0`, `collision_mask = 2` (detecta interactuables)

---

## Capas de CanvasLayer

| Capa | Elemento | Descripción |
|---|---|---|
| 0 | Mundo del juego | Nodos 2D normales |
| 5 | HUD | Corazones, capítulo, páginas |
| 10 | DialogueBox | Caja de diálogo |
| 50 | DiaryOverlay | Escena del diario |
| 90 | PersonaFlash / GrandmaFlash | Flashes de pensamiento |
| 95 | PauseMenu | Menú de pausa |
| 100 | TransitionManager | Fade to/from black |

Las capas más altas se renderizan encima de las más bajas.
