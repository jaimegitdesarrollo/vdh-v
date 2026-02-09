extends Node2D
## Ch1Street — Mapa completo del barrio (4 zonas exteriores continuas).
## Z1 Residencial → Z2 Parque → Z3 Comercial → Z4 Instituto Exterior.
## Z5 (Interior Instituto) es escena separada (ch1_classroom.tscn).
## Basado en: Mapa_Base_Barrio_Instituto.md + Mapa_Grande_VersosDeHeroe.html

const MAP_W: int = 880   # 55 tiles
const MAP_H: int = 1488  # 93 tiles
const T: int = 16         # tile size

# Zone Y offsets (stacked N→S)
const Z1_Y: int = 0      # Residencial: 25 rows = 400px
const Z2_Y: int = 400    # Parque: 30 rows = 480px
const Z3_Y: int = 880    # Comercial: 22 rows = 352px
const Z4_Y: int = 1232   # Instituto Ext: 16 rows = 256px

# --- Tile textures (16x16) ---
var tex_grass: Texture2D = preload("res://assets/sprites/tiles/floor_grass.png")
var tex_concrete: Texture2D = preload("res://assets/sprites/tiles/floor_concrete.png")
var tex_asphalt: Texture2D = preload("res://assets/sprites/tiles/floor_asphalt.png")
var tex_dirt: Texture2D = preload("res://assets/sprites/tiles/floor_dirt.png")
var tex_brick: Texture2D = preload("res://assets/sprites/tiles/wall_brick.png")
var tex_dark: Texture2D = preload("res://assets/sprites/tiles/wall_dark.png")
var tex_tree: Texture2D = preload("res://assets/sprites/tiles/tree.png")
var tex_fountain: Texture2D = preload("res://assets/sprites/tiles/fountain.png")
var tex_door_open: Texture2D = preload("res://assets/sprites/tiles/door_open.png")
var tex_door_closed: Texture2D = preload("res://assets/sprites/tiles/door_closed.png")
var tex_sidewalk_edge: Texture2D = preload("res://assets/sprites/tiles/sidewalk_edge.png")
var tex_road_line: Texture2D = preload("res://assets/sprites/tiles/road_line.png")
var tex_crosswalk: Texture2D = preload("res://assets/sprites/tiles/crosswalk.png")
var tex_grass_dark: Texture2D = preload("res://assets/sprites/tiles/grass_dark.png")
var tex_water: Texture2D = preload("res://assets/sprites/tiles/water.png")
var tex_water_deep: Texture2D = preload("res://assets/sprites/tiles/water_deep.png")
var tex_roof: Texture2D = preload("res://assets/sprites/tiles/roof.png")
var tex_stone: Texture2D = preload("res://assets/sprites/tiles/building_stone.png")
var tex_grey: Texture2D = preload("res://assets/sprites/tiles/building_grey.png")
var tex_white: Texture2D = preload("res://assets/sprites/tiles/building_white.png")
var tex_fence: Texture2D = preload("res://assets/sprites/tiles/fence_metal.png")
var tex_bush: Texture2D = preload("res://assets/sprites/tiles/bush.png")
var tex_car_red: Texture2D = preload("res://assets/sprites/tiles/car_red.png")
var tex_car_blue: Texture2D = preload("res://assets/sprites/tiles/car_blue.png")
var tex_car_white: Texture2D = preload("res://assets/sprites/tiles/car_white.png")
var tex_car_black: Texture2D = preload("res://assets/sprites/tiles/car_black.png")
var tex_van: Texture2D = preload("res://assets/sprites/tiles/van.png")
var car_script: GDScript = preload("res://scripts/vehicles/car.gd")

# Spritesheet paths for animated cars
const CAR_SHEETS: Dictionary = {
	"red": "res://assets/sprites/vehicles/car_red_spritesheet.png",
	"blue": "res://assets/sprites/vehicles/car_blue_spritesheet.png",
	"white": "res://assets/sprites/vehicles/car_white_spritesheet.png",
	"black": "res://assets/sprites/vehicles/car_black_spritesheet.png",
}
var tex_bench: Texture2D = preload("res://assets/sprites/tiles/bench.png")
var tex_trashcan: Texture2D = preload("res://assets/sprites/tiles/trashcan.png")
var tex_mailbox: Texture2D = preload("res://assets/sprites/tiles/mailbox.png")
var tex_traffic_light: Texture2D = preload("res://assets/sprites/tiles/traffic_light.png")
var tex_streetlight: Texture2D = preload("res://assets/sprites/tiles/streetlight.png")
var tex_dumpster: Texture2D = preload("res://assets/sprites/tiles/dumpster.png")
var tex_flowerpot: Texture2D = preload("res://assets/sprites/tiles/flowerpot.png")
var tex_hydrant: Texture2D = preload("res://assets/sprites/tiles/hydrant.png")
var tex_sign: Texture2D = preload("res://assets/sprites/tiles/sign.png")
var tex_shop_front: Texture2D = preload("res://assets/sprites/tiles/shop_front.png")
var tex_shop_closed: Texture2D = preload("res://assets/sprites/tiles/shop_closed.png")
var tex_shop_door: Texture2D = preload("res://assets/sprites/tiles/shop_door.png")
var tex_shop_window: Texture2D = preload("res://assets/sprites/tiles/shop_window.png")
var tex_shop_awning: Texture2D = preload("res://assets/sprites/tiles/shop_awning.png")

# --- Vegetation tiles (trees/bushes from strip, grass from v2 atlas) ---
var veg_tree_crown: Texture2D    # strip ID 0
var veg_tree_base: Texture2D     # strip ID 1
var veg_urban_tree: Texture2D    # strip ID 2
var veg_pine: Texture2D          # strip ID 3
var veg_bush_dense: Texture2D    # strip ID 4
var veg_bush_flowers: Texture2D  # strip ID 12
# Grass v2 atlas (3x3, 16x16 each)
var veg_grass: Texture2D         # Césped A  (0,0)
var veg_grass_b: Texture2D       # Césped B  (1,0)
var veg_grass_c: Texture2D       # Césped C brillante (2,0)
var veg_grass_flowers: Texture2D # Césped con Flores (0,1)
var veg_tall_grass: Texture2D    # Hierba Alta (1,1)
var veg_grass_stones: Texture2D  # Piedras en Césped (2,1)
var veg_path_v: Texture2D        # Sendero Vertical (0,2)
var veg_path_h: Texture2D        # Sendero Horizontal (1,2)
var veg_transition: Texture2D    # Transición Césped→Tierra (2,2)

# Packed scenes
var PlayerScene: PackedScene = preload("res://scenes/player/player.tscn")
var HUDScene: PackedScene = preload("res://scenes/ui/hud.tscn")
var DialogueBoxScene: PackedScene = preload("res://scenes/ui/dialogue_box.tscn")
var PersonaFlashScene: PackedScene = preload("res://scenes/ui/persona_flash.tscn")
var GrandmaFlashScene: PackedScene = preload("res://scenes/ui/grandma_flash.tscn")
var EnemyFearScene: PackedScene = preload("res://scenes/enemies/enemy_fear.tscn")
var EnemySadnessScene: PackedScene = preload("res://scenes/enemies/enemy_sadness.tscn")
var EnemyLonelinessScene: PackedScene = preload("res://scenes/enemies/enemy_loneliness.tscn")
var SecretItemScene: PackedScene = preload("res://scenes/collectibles/secret_item.tscn")

var player: CharacterBody2D
var camera: Camera2D

# --- Intrusive thoughts system ---
var _thoughts_layer: CanvasLayer
var _thought_timer: float = 0.0
var _thought_interval: float = 15.0  # first one after 15s
const INTRUSIVE_THOUGHTS: Array[String] = [
	"Tengo miedo",
	"No tengo amigos",
	"Me da miedo vivir",
	"Estoy solo",
	"Nadie me quiere",
	"Ojalá fuera invisible",
	"No sirvo para nada",
	"Todo es culpa mía",
	"¿Por qué a mí?",
	"No encajo en ningún sitio",
]


func _ready():
	DialogueManager.load_dialogues("res://data/dialogues/chapter1.json")
	GameManager.set_exploration_scene("res://scenes/chapters/chapter1/ch1_street.tscn")
	_load_vegetation_tiles()

	_build_map_base()
	_build_zone1_residential()
	_build_zone2_park()
	_build_zone3_commercial()
	_build_zone4_institute_exterior()
	_build_map_boundaries()

	# Street music (same as menu, continues playing)
	AudioManager.play_music("ch1_soledad_piano")
	# Traffic ambient for street zones
	AudioManager.play_ambient("sfx_traffic_ambient")

	# Player spawns at Cristian's portal (Z1 row 5, col 17)
	_spawn_player(Vector2(17 * T + 8, Z1_Y + 5 * T + 8))

	# UI layers
	add_child(HUDScene.instantiate())
	add_child(DialogueBoxScene.instantiate())
	add_child(PersonaFlashScene.instantiate())
	add_child(GrandmaFlashScene.instantiate())

	# Intrusive thoughts floating on screen
	_setup_intrusive_thoughts()

	if not GameManager.get_flag("ch1_street_entered"):
		GameManager.set_flag("ch1_street_entered")
		await get_tree().create_timer(0.5).timeout
		DialogueManager.start_dialogue("street_exit")


# =============================================================================
# INTRUSIVE THOUGHTS — semi-transparent messages crossing the screen
# =============================================================================

func _setup_intrusive_thoughts():
	_thoughts_layer = CanvasLayer.new()
	_thoughts_layer.name = "IntrusiveThoughts"
	_thoughts_layer.layer = 4  # below HUD (5)
	add_child(_thoughts_layer)
	_thought_interval = randf_range(10.0, 20.0)


func _process(delta: float):
	_thought_timer += delta
	if _thought_timer >= _thought_interval:
		_thought_timer = 0.0
		_thought_interval = randf_range(10.0, 30.0)
		_spawn_intrusive_thought()


func _spawn_intrusive_thought():
	var text: String = INTRUSIVE_THOUGHTS[randi() % INTRUSIVE_THOUGHTS.size()]
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 0.18))
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.08))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	_thoughts_layer.add_child(lbl)

	# Random direction: 0=left→right, 1=right→left, 2=bottom→top, 3=top→bottom, 4-7=diagonals
	var dir_type := randi() % 8
	var start_pos := Vector2.ZERO
	var end_pos := Vector2.ZERO
	var ry := randf_range(20, 160)  # random Y for horizontal
	var rx := randf_range(20, 280)  # random X for vertical

	match dir_type:
		0:  # left → right
			start_pos = Vector2(-100, ry)
			end_pos = Vector2(420, ry)
		1:  # right → left
			start_pos = Vector2(420, ry)
			end_pos = Vector2(-100, ry)
		2:  # bottom → top
			start_pos = Vector2(rx, 200)
			end_pos = Vector2(rx, -30)
		3:  # top → bottom
			start_pos = Vector2(rx, -30)
			end_pos = Vector2(rx, 200)
		4:  # diagonal ↘
			start_pos = Vector2(-100, -30)
			end_pos = Vector2(420, 200)
		5:  # diagonal ↙
			start_pos = Vector2(420, -30)
			end_pos = Vector2(-100, 200)
		6:  # diagonal ↗
			start_pos = Vector2(-100, 200)
			end_pos = Vector2(420, -30)
		7:  # diagonal ↖
			start_pos = Vector2(420, 200)
			end_pos = Vector2(-100, -30)

	lbl.position = start_pos
	# Random rotation for extra unease (-15° to 15°)
	lbl.rotation = randf_range(deg_to_rad(-15), deg_to_rad(15))

	var duration := randf_range(6.0, 12.0)
	var tw := create_tween()
	tw.tween_property(lbl, "position", end_pos, duration)
	tw.tween_callback(lbl.queue_free)


# =============================================================================
# PLAYER
# =============================================================================
func _spawn_player(pos: Vector2):
	player = PlayerScene.instantiate()
	player.position = pos
	add_child(player)
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_W
	camera.limit_bottom = MAP_H
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	player.add_child(camera)


# =============================================================================
# MAP BASE — Ground fills per zone
# =============================================================================
func _build_map_base():
	_fill("Base_Z1", 0, Z1_Y, MAP_W, 400, tex_concrete)
	_fill("Base_Z2", 0, Z2_Y, MAP_W, 480, veg_grass)
	# Scatter grass B & C variants for visual variety in the park
	_scatter_grass_variants(Z2_Y, 480)
	_fill("Base_Z3", 0, Z3_Y, MAP_W, 352, tex_concrete)
	_fill("Base_Z4", 0, Z4_Y, MAP_W, 256, tex_concrete)


# =============================================================================
# ZONE 1 — CALLE RESIDENCIAL (y=0..400, 25 rows)
# =============================================================================
func _build_zone1_residential():
	var zy := Z1_Y

	# --- EDIFICIOS (rows 0-4) ---
	_fill("Z1_Roofs", 0, zy, MAP_W, T, tex_roof)
	# Building facades (rows 1-3) — different textures per section
	_wall("Z1_BK1", 0, zy + T, 96, 48, tex_brick)
	_wall("Z1_BS1", 96, zy + T, 64, 48, tex_stone)
	_wall("Z1_BK2", 160, zy + T, 80, 48, tex_brick)
	_wall("Z1_Cristian", 240, zy + T, 160, 48, tex_grey)
	_wall("Z1_BK3", 400, zy + T, 80, 48, tex_brick)
	_wall("Z1_BW", 480, zy + T, 80, 48, tex_white)
	_wall("Z1_BK4", 560, zy + T, 32, 48, tex_brick)
	_wall("Z1_BS2", 592, zy + T, 64, 48, tex_stone)
	_wall("Z1_BK5", 656, zy + T, 224, 48, tex_brick)
	# Portal strip (row 4) — wall with gap for Cristian's door
	_wall("Z1_Portal_L", 0, zy + 64, 272, T, tex_dark)
	_wall("Z1_Portal_R", 288, zy + 64, MAP_W - 288, T, tex_dark)
	# Cristian's portal → kitchen
	_door("Z1_HomeDoor", 272, zy + 64, T, T, tex_door_open,
		"res://scenes/chapters/chapter1/ch1_kitchen.tscn")

	# --- ACERA NORTE (rows 5-7) ---
	for c in [0, 1, 6, 7, 25, 26, 33, 34]:
		_deco("Z1_MC%d" % c, c * T, zy + 80, tex_flowerpot)
	_deco_col("Z1_Mailbox", 8 * T, zy + 96, tex_mailbox)
	for c in [11, 29, 44]:
		_deco("Z1_FA%d" % c, c * T, zy + 96, tex_streetlight)
	# NPC señora con bolsa
	_npc("Z1_Senora", 20 * T, zy + 112, Color(0.7, 0.4, 0.4))
	# Árbol urbano en acera norte
	_veg_bush("Z1_UrbanTree", 10 * T, zy + 4 * T, veg_urban_tree)

	# --- CARRETERA (rows 8-12) ---
	_fill("Z1_CurbN", 0, zy + 128, MAP_W, T, tex_sidewalk_edge)
	_fill("Z1_Road", 0, zy + 144, MAP_W, 64, tex_asphalt)
	_fill("Z1_RLine", 15 * T, zy + 160, 2 * T, T, tex_road_line)
	_fill("Z1_Cross", 15 * T, zy + 192, 2 * T, T, tex_crosswalk)
	# Moving cars — upper lane drives RIGHT, lower lane drives LEFT
	_moving_car("Z1_CR", 5 * T, zy + 148, "red", tex_car_red, 55.0, 1)
	_moving_car("Z1_CB", 26 * T, zy + 148, "blue", tex_car_blue, 70.0, 1)
	_moving_car("Z1_CW", 37 * T, zy + 188, "white", tex_car_white, 50.0, -1)
	_moving_car("Z1_CK", 44 * T, zy + 188, "black", tex_car_black, 65.0, -1)
	_car("Z1_VN", 31 * T, zy + 176, tex_van)  # Van stays parked
	_fill("Z1_CurbS", 0, zy + 208, MAP_W, T, tex_sidewalk_edge)

	# --- ACERA SUR (rows 14-15) ---
	for c in [9, 31, 44]:
		_deco("Z1_FAS%d" % c, c * T, zy + 224, tex_streetlight)
	_deco_col("Z1_Sema", 18 * T, zy + 224, tex_traffic_light)
	_deco_col("Z1_PP1", 6 * T, zy + 240, tex_trashcan)
	_deco_col("Z1_PP2", 35 * T, zy + 240, tex_trashcan)
	_deco_col("Z1_HY", 44 * T, zy + 240, tex_hydrant)

	# --- CALLEJÓN 1 (rows 16-19, right side, open bottom) ---
	_wall("Z1_AllT", 39 * T, zy + 256, 6 * T, T, tex_dark)
	_wall("Z1_AllL", 39 * T, zy + 272, T, 32, tex_dark)
	_wall("Z1_AllR", 44 * T, zy + 272, T, 32, tex_dark)

	# Enemy: 1x Miedo acera sur
	_enemy_fear("Z1_Fear", 14 * T, zy + 256, [
		Vector2(14 * T, zy + 230), Vector2(30 * T, zy + 230),
		Vector2(30 * T, zy + 260), Vector2(14 * T, zy + 260)])
	# Secret: Página cómic 1 en callejón
	_secret("ch1_page_1", "comic_page", 42 * T, zy + 288, "")

	# --- TRANSICIÓN AL PARQUE (rows 20-24) ---
	_fill("Z1_GrassT", 0, zy + 320, MAP_W, 80, veg_grass)
	_scatter_grass_variants(zy + 320, 80)
	_deco("Z1_Sign", 5 * T, zy + 336, tex_sign)
	# Árboles borde del parque (wider gaps at cols 15-22 and 34-40 for clear passage)
	for c in [6, 10, 14, 24, 28, 32, 42, 48]:
		_tree("Z1_Tr%d" % c, c * T, zy + 336)

	# Navigation
	_arrow("Z1_Arr_S", 18 * T, zy + 368, "Parque  vvv")
	_arrow("Z1_Arr_H", 16 * T, zy + 72, "[E] Casa")


# =============================================================================
# ZONE 2 — PARQUE (y=400..880, 30 rows)
# =============================================================================
func _build_zone2_park():
	var zy := Z2_Y

	# --- SUELO BASE: Césped con variedad ---
	# Césped con flores en entrada del parque (rows 1-3, cols 10-20)
	for r in range(1, 4):
		_ground_row("Z2_GF_E", range(10, 21), zy + r * T, veg_grass_flowers)
	# Césped con flores alrededor de la fuente (rows 3-7, cols 22-30)
	for r in range(3, 8):
		_ground_row("Z2_GF_F%d" % r, range(22, 31), zy + r * T, veg_grass_flowers)
	# Césped con flores zona niños (rows 14-16, cols 20-26)
	for r in range(14, 17):
		_ground_row("Z2_GF_K%d" % r, range(20, 27), zy + r * T, veg_grass_flowers)
	# Hierba alta en bordes izquierdo (rows 13-17, cols 0-3)
	for r in range(13, 18):
		_ground_row("Z2_TG_L%d" % r, range(0, 4), zy + r * T, veg_tall_grass)
	# Hierba alta en bordes derecho (rows 13-17, cols 42-54)
	for r in range(13, 18):
		_ground_row("Z2_TG_R%d" % r, range(42, 55), zy + r * T, veg_tall_grass)
	# Piedras en césped cerca del rincón seguro (rows 11-12, cols 4-5)
	for r in [11, 12]:
		_ground_row("Z2_GS%d" % r, [4, 5], zy + r * T, veg_grass_stones)

	# --- SENDEROS ---
	# Sendero vertical principal (cols 18-20, rows 1-21)
	_fill("Z2_PathV", 18 * T, zy + T, 3 * T, 21 * T, veg_path_v)
	# Transición bordes del sendero vertical (cols 17 y 21)
	for r in range(1, 22):
		_ground_tile("Z2_TrL%d" % r, 17 * T, zy + r * T, veg_transition)
		_ground_tile("Z2_TrR%d" % r, 21 * T, zy + r * T, veg_transition)
	# Sendero horizontal bifurcación hacia puente (cols 20-27, rows 17-18)
	_fill("Z2_PathH", 20 * T, zy + 17 * T, 8 * T, 2 * T, veg_path_h)
	# Transición bordes del sendero horizontal
	for c in range(20, 28):
		_ground_tile("Z2_ThT%d" % c, c * T, zy + 16 * T, veg_transition)
		_ground_tile("Z2_ThB%d" % c, c * T, zy + 19 * T, veg_transition)

	# --- GRUPO NOROESTE (denso, esconde rincón seguro) ---
	for p in [[0,4],[1,4],[0,5],[1,5]]:
		_park_tree("Z2_NW_%d%d" % [p[0], p[1]], p[0] * T, zy + p[1] * T)
	_pine("Z2_NW_P6", 0, zy + 6 * T)
	for p in [[0,9],[1,9],[3,9]]:
		_park_tree("Z2_NW_%d%d" % [p[0], p[1]], p[0] * T, zy + p[1] * T)
	_pine("Z2_NW_P9", 2 * T, zy + 9 * T)
	for c in range(4):
		_park_tree("Z2_NW_10_%d" % c, c * T, zy + 10 * T)
	_park_tree("Z2_NW_11_0", 0, zy + 11 * T)
	_park_tree("Z2_NW_11_1", T, zy + 11 * T)
	# Dense bushes hiding safe spot (passage at col 2)
	_veg_bush("Z2_BushD1", 3 * T, zy + 11 * T, veg_bush_dense)
	_pine("Z2_NW_P12", 0, zy + 12 * T)
	for c in range(3):
		_park_tree("Z2_NW_13_%d" % c, c * T, zy + 13 * T)
	_veg_bush("Z2_BushD2", 3 * T, zy + 13 * T, veg_bush_dense)

	# --- GRUPO NORESTE (junto a fuente) ---
	_park_tree("Z2_NE_28_4", 28 * T, zy + 4 * T)
	_pine("Z2_NE_P29", 29 * T, zy + 4 * T)
	_park_tree("Z2_NE_30_4", 30 * T, zy + 4 * T)
	for c in [28, 29, 30]:
		_park_tree("Z2_NE_%d_5" % c, c * T, zy + 5 * T)
	for c in [30, 31]:
		_park_tree("Z2_NE_%d_6" % c, c * T, zy + 6 * T)
	_pine("Z2_NE_P32", 32 * T, zy + 7 * T)

	# --- GRUPO CENTRO (zona densa, enemigos patrullan) ---
	# Row 10: mixed trees and pines
	for c in [24, 25, 27, 28]:
		_park_tree("Z2_C_%d_10" % c, c * T, zy + 10 * T)
	for c in [26, 29]:
		_pine("Z2_C_P%d_10" % c, c * T, zy + 10 * T)
	# Row 11
	for c in [24, 26, 27, 29]:
		_park_tree("Z2_C_%d_11" % c, c * T, zy + 11 * T)
	for c in [25, 28]:
		_pine("Z2_C_P%d_11" % c, c * T, zy + 11 * T)
	# Row 12: dense
	for c in range(24, 30):
		_park_tree("Z2_C_%d_12" % c, c * T, zy + 12 * T)
	# Rows 13-15: more trees extending south
	for c in [24, 25, 28, 29]:
		_park_tree("Z2_C_%d_13" % c, c * T, zy + 13 * T)
	for c in [26, 27]:
		_pine("Z2_C_P%d_13" % c, c * T, zy + 13 * T)

	# --- ÁRBOLES SUELTOS (scattered) ---
	# Upper-right area
	for p in [[36,4],[37,4],[38,5],[37,6],[38,7]]:
		_park_tree("Z2_S_%d_%d" % [p[0], p[1]], p[0] * T, zy + p[1] * T)
	# Upper row decorative
	_park_tree("Z2_S_33_1", 33 * T, zy + T)
	_pine("Z2_S_P34_1", 34 * T, zy + T)
	_park_tree("Z2_S_35_2", 35 * T, zy + 2 * T)
	# Extra left area trees
	_park_tree("Z2_S_3_1", 3 * T, zy + T)
	_park_tree("Z2_S_4_2", 4 * T, zy + 2 * T)

	# --- ARBUSTOS DECORATIVOS ---
	_veg_bush("Z2_BF1", 24 * T, zy + 2 * T, veg_bush_flowers)
	_veg_bush("Z2_BF2", 8 * T, zy + 2 * T, veg_bush_flowers)
	_veg_bush("Z2_BD3", 25 * T, zy + 14 * T, veg_bush_dense)
	_veg_bush("Z2_BF4", 10 * T, zy + 15 * T, veg_bush_flowers)

	# --- SAFE SPOT (accessible between bushes) ---
	_secret("ch1_safe_spot", "safe_spot", 4 * T, zy + 12 * T, "")

	# --- FUENTE ---
	_deco_big("Z2_Fountain", 26 * T + 8, zy + 5 * T, tex_fountain, 4.0)
	_flash("Z2_Flash", 24 * T, zy + 3 * T, Vector2(5 * T, 5 * T), "No quiero ir", true)

	# --- BANCO + NPCs ---
	_deco_col("Z2_Bench", 37 * T, zy + 7 * T, tex_bench)
	_npc("Z2_NPC_Per", 38 * T, zy + 8 * T, Color(0.4, 0.4, 0.6))
	_npc("Z2_Nino1", 30 * T, zy + 17 * T, Color(0.3, 0.5, 0.3))
	_npc("Z2_Nino2", 32 * T, zy + 17 * T, Color(0.5, 0.3, 0.3))

	# --- FAROLAS ---
	_deco("Z2_FA1", 14 * T, zy + 3 * T, tex_streetlight)
	_deco("Z2_FA2", 12 * T, zy + 19 * T, tex_streetlight)

	# --- ENEMIGOS ---
	_enemy_fear("Z2_Fear1", 8 * T, zy + 6 * T, [
		Vector2(5 * T, zy + 5 * T), Vector2(15 * T, zy + 8 * T),
		Vector2(5 * T, zy + 10 * T)])
	_enemy_fear("Z2_Fear2", 35 * T, zy + 5 * T, [
		Vector2(35 * T, zy + 4 * T), Vector2(40 * T, zy + 7 * T),
		Vector2(35 * T, zy + 10 * T)])
	_enemy_sad("Z2_Sad", 34 * T, zy + 11 * T, [
		Vector2(34 * T, zy + 10 * T), Vector2(36 * T, zy + 12 * T),
		Vector2(34 * T, zy + 14 * T), Vector2(32 * T, zy + 12 * T)])

	# --- RÍO (rows 22-24) ---
	_fill("Z2_Riv1", 0, zy + 22 * T, MAP_W, T, tex_water)
	_fill("Z2_Riv2", 0, zy + 23 * T, MAP_W, T, tex_water_deep)
	_fill("Z2_Riv3", 0, zy + 24 * T, MAP_W, T, tex_water)
	_invis("Z2_RivWL", 0, zy + 22 * T, 22 * T, 3 * T)
	_invis("Z2_RivWR", 24 * T, zy + 22 * T, MAP_W - 24 * T, 3 * T)
	_fill("Z2_Bridge", 22 * T, zy + 22 * T, 2 * T, 3 * T, veg_path_v)

	# Secrets south of river
	_secret("ch1_grandma_1", "grandma_memory", 16 * T, zy + 26 * T,
		"Todo tiene solución menos la muerte, cariño")
	_secret("ch1_graffiti_1", "graffiti", T, zy + 27 * T, "No estás solo")

	# Exit path toward Z3
	_fill("Z2_ExitP", 19 * T, zy + 28 * T, 2 * T, 2 * T, veg_path_v)

	# Navigation
	_arrow("Z2_ArrN", 18 * T, zy + T, "^^^ Casa")
	_arrow("Z2_ArrS", 19 * T, zy + 28 * T, "Tiendas  vvv")


# =============================================================================
# ZONE 3 — CALLE COMERCIAL (y=880..1232, 22 rows)
# =============================================================================
func _build_zone3_commercial():
	var zy := Z3_Y

	# --- TIENDAS NORTE (rows 1-4) — gap at cols 18-20 for park entrance ---
	# Roof (visual, no collision)
	_fill("Z3_RoofL", 0, zy + T, 18 * T, T, tex_roof)
	_fill("Z3_RoofR", 21 * T, zy + T, MAP_W - 21 * T, T, tex_roof)
	# Awning (visual, no collision)
	_fill("Z3_AwningL", 0, zy + 2 * T, 18 * T, T, tex_shop_awning)
	_fill("Z3_AwningR", 21 * T, zy + 2 * T, MAP_W - 21 * T, T, tex_shop_awning)
	# Escaparates — LEFT (cols 0-17)
	_wall("Z3_SW1", 0, zy + 3 * T, 4 * T, T, tex_shop_window)
	_wall("Z3_SD1", 4 * T, zy + 3 * T, T, T, tex_shop_door)
	_wall("Z3_SW2", 5 * T, zy + 3 * T, 7 * T, T, tex_shop_window)
	_wall("Z3_SD2", 12 * T, zy + 3 * T, T, T, tex_shop_door)
	_wall("Z3_SW3", 13 * T, zy + 3 * T, 5 * T, T, tex_shop_window)
	# Gap cols 18-20 — entrance from park
	# Escaparates — RIGHT (cols 21-54)
	_wall("Z3_SW4", 21 * T, zy + 3 * T, 5 * T, T, tex_shop_window)
	_wall("Z3_SD4", 26 * T, zy + 3 * T, T, T, tex_shop_door)
	_wall("Z3_SW5", 27 * T, zy + 3 * T, 7 * T, T, tex_shop_window)
	_wall("Z3_SD5", 34 * T, zy + 3 * T, T, T, tex_shop_door)
	_wall("Z3_SW6", 35 * T, zy + 3 * T, 3 * T, T, tex_shop_window)
	_wall("Z3_SC", 38 * T, zy + 3 * T, 6 * T, T, tex_shop_closed)
	_wall("Z3_SW7", 44 * T, zy + 3 * T, 11 * T, T, tex_shop_window)
	# Fachadas (row 4) — with gap
	_wall("Z3_FacL", 0, zy + 4 * T, 18 * T, T, tex_shop_front)
	_wall("Z3_FacM", 21 * T, zy + 4 * T, 17 * T, T, tex_shop_front)
	_wall("Z3_FacC", 38 * T, zy + 4 * T, 6 * T, T, tex_shop_closed)
	_wall("Z3_FacR", 44 * T, zy + 4 * T, MAP_W - 44 * T, T, tex_shop_front)
	# Interactable shop doors (accessible from sidewalk, taller hitbox)
	_dialogue_area("Z3_ComicDoor", 4 * T, zy + 5 * T, T, 2 * T, "comic_shop_closed")
	_dialogue_area("Z3_Kiosk", 12 * T, zy + 5 * T, T, 2 * T, "kiosk_browse")
	_dialogue_area("Z3_Cafe", 26 * T, zy + 5 * T, T, 2 * T, "cafe_window")

	# --- ACERA NORTE (rows 5-7) ---
	for c in [2, 11, 19, 27, 34, 43, 49]:
		_deco("Z3_FA%d" % c, c * T, zy + 6 * T, tex_streetlight)
	_deco_col("Z3_PP1", 7 * T, zy + 6 * T, tex_trashcan)
	_deco_col("Z3_PP2", 39 * T, zy + 6 * T, tex_trashcan)

	# --- CARRETERA (rows 8-12) ---
	_fill("Z3_CurbN", 0, zy + 8 * T, MAP_W, T, tex_sidewalk_edge)
	_fill("Z3_Road", 0, zy + 9 * T, MAP_W, 3 * T, tex_asphalt)
	_fill("Z3_RLine", 15 * T, zy + 10 * T, 2 * T, T, tex_road_line)
	_fill("Z3_Cross", 15 * T, zy + 11 * T, 2 * T, T, tex_crosswalk)
	# Moving cars — upper lane RIGHT, lower lane LEFT
	_moving_car("Z3_CR", 7 * T, zy + 9 * T + 4, "red", tex_car_red, 60.0, 1)
	_moving_car("Z3_CB", 29 * T, zy + 10 * T + 4, "blue", tex_car_blue, 45.0, -1)
	_moving_car("Z3_CK", 46 * T, zy + 9 * T + 4, "black", tex_car_black, 75.0, 1)
	_fill("Z3_CurbS", 0, zy + 12 * T, MAP_W, T, tex_sidewalk_edge)

	# --- ACERA SUR + ENEMIGOS (rows 13-14) ---
	for c in [9, 33, 49]:
		_deco("Z3_FAS%d" % c, c * T, zy + 13 * T, tex_streetlight)
	_enemy_fear("Z3_Fear1", 22 * T, zy + 13 * T, [
		Vector2(15 * T, zy + 13 * T), Vector2(30 * T, zy + 13 * T)])
	_enemy_fear("Z3_Fear2", 40 * T, zy + 13 * T, [
		Vector2(35 * T, zy + 13 * T), Vector2(45 * T, zy + 14 * T)])

	# --- MURO SUR + CALLEJÓN 2 (rows 15-19) ---
	_wall("Z3_WallL", 0, zy + 15 * T, 29 * T, 5 * T, tex_dark)
	_wall("Z3_WallR", 32 * T, zy + 15 * T, MAP_W - 32 * T, 5 * T, tex_dark)
	_fill("Z3_Alley", 29 * T, zy + 15 * T, 3 * T, 4 * T, tex_concrete)
	# Graffiti + enemy + secret in alley
	_secret("ch1_graffiti_2", "graffiti", 30 * T, zy + 17 * T, "El arte salva")
	_enemy_lone("Z3_Lone", 30 * T, zy + 17 * T + 8)
	_secret("ch1_page_2", "comic_page", 30 * T, zy + 18 * T, "")

	# Navigation
	_arrow("Z3_ArrN", 19 * T, zy + T, "^^^ Parque")
	_arrow("Z3_ArrS", 19 * T, zy + 20 * T, "Instituto  vvv")


# =============================================================================
# ZONE 4 — EXTERIOR INSTITUTO (y=1232..1488, 16 rows)
# =============================================================================
func _build_zone4_institute_exterior():
	var zy := Z4_Y

	# --- NPCs alumnos (rows 0-2) ---
	_npc("Z4_Al1", 9 * T, zy + T, Color(0.3, 0.4, 0.6))
	_npc("Z4_Al2", 14 * T, zy + T, Color(0.4, 0.5, 0.4))
	_npc("Z4_Al3", 21 * T, zy + T, Color(0.5, 0.4, 0.3))

	# --- VERJA (rows 3-5) ---
	# Top fence row 3 — gap at cols 0-2 for side passage
	_wall("Z4_Fen1", 3 * T, zy + 3 * T, MAP_W - 3 * T, T, tex_fence)
	# Left fence row 4 — gap at cols 0-2 for side passage
	_wall("Z4_FenL", 3 * T, zy + 4 * T, 18 * T, T, tex_fence)
	# Main door (decorative — Cristian avoids it)
	_fill("Z4_MDoor", 21 * T, zy + 4 * T, 9 * T, T, tex_door_closed)
	_dialogue_area("Z4_MDoorI", 24 * T, zy + 3 * T, 3 * T, 2 * T,
		"instituto_puerta_principal")
	_wall("Z4_FenR", 30 * T, zy + 4 * T, MAP_W - 30 * T, T, tex_fence)
	# Fence row 5 — gap at cols 0-2 (left side passage for Cristian to sneak to back door)
	_wall("Z4_Fen3R", 3 * T, zy + 5 * T, MAP_W - 3 * T, T, tex_fence)

	# --- LATERAL DERECHO (fence continues right side) ---
	_wall("Z4_FenSide", 45 * T, zy + 6 * T, 10 * T, 6 * T, tex_fence)

	# --- VEGETACIÓN ---
	_veg_bush("Z4_UrbanTree1", 2 * T, zy + 7 * T, veg_urban_tree)
	_veg_bush("Z4_UrbanTree2", 12 * T, zy + 7 * T, veg_urban_tree)

	# --- CONTENEDORES (row 8) ---
	for i in range(3):
		_deco_col("Z4_CN%d" % i, (2 + i) * T, zy + 8 * T, tex_dumpster)
	# Arbustos junto a contenedores (relevancia narrativa cap 2)
	_veg_bush("Z4_Bush1", 2 * T, zy + 9 * T, veg_bush_dense)
	_veg_bush("Z4_Bush2", 3 * T, zy + 9 * T, veg_bush_dense)

	# --- PUERTA TRASERA (row 10, col 44 → classroom) ---
	_door("Z4_BackDoor", 44 * T, zy + 10 * T, T, T, tex_door_open,
		"res://scenes/chapters/chapter1/ch1_classroom.tscn")

	# --- ENEMY: Miedo en lateral ---
	_enemy_fear("Z4_Fear", 6 * T, zy + 7 * T, [
		Vector2(6 * T, zy + 7 * T), Vector2(6 * T, zy + 9 * T),
		Vector2(10 * T, zy + 9 * T), Vector2(10 * T, zy + 7 * T)])

	# --- SECRET: Página cómic 3 (narrativamente en taquilla, aquí exterior) ---
	_secret("ch1_page_3", "comic_page", 40 * T, zy + 8 * T, "")

	# Label puerta principal
	var lbl := Label.new()
	lbl.name = "Z4_InstSign"
	lbl.text = "INSTITUTO PÚBLICO"
	lbl.position = Vector2(22 * T, zy + 3 * T - 6)
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.75, 0.65))
	add_child(lbl)

	# Navigation
	_arrow("Z4_ArrDoor", 38 * T, zy + 10 * T, "[E] Puerta trasera >>>")
	_arrow("Z4_ArrBack", 5 * T, zy + T, "^^^ Volver")
	_arrow("Z4_ArrSneak", T, zy + 3 * T, "vvv Colarse")


# =============================================================================
# MAP BOUNDARIES
# =============================================================================
func _build_map_boundaries():
	_invis("BndT", 0, -T, MAP_W, T)
	_invis("BndB", 0, MAP_H, MAP_W, T)
	_invis("BndL", -T, 0, T, MAP_H)
	_invis("BndR", MAP_W, 0, T, MAP_H)


# =============================================================================
# VEGETATION LOADING
# =============================================================================

func _load_vegetation_tiles():
	# --- Trees & bushes from vegetation strip ---
	var strip: Texture2D = load("res://assets/sprites/tiles/vegetation_strip.png")
	if strip != null:
		var stiles: Array[Texture2D] = []
		for i in 13:
			var at := AtlasTexture.new()
			at.atlas = strip
			at.region = Rect2(i * 16, 0, 16, 16)
			at.filter_clip = true
			stiles.append(at)
		veg_tree_crown = stiles[0]
		veg_tree_base = stiles[1]
		veg_urban_tree = stiles[2]
		veg_pine = stiles[3]
		veg_bush_dense = stiles[4]
		veg_bush_flowers = stiles[12]
	else:
		veg_tree_crown = tex_tree
		veg_tree_base = tex_tree
		veg_urban_tree = tex_tree
		veg_pine = tex_tree
		veg_bush_dense = tex_bush
		veg_bush_flowers = tex_bush

	# --- Grass v2 atlas (3x3 grid, 16x16 each) ---
	# We extract each 16x16 region into a standalone ImageTexture so _fill()
	# can tile them correctly (AtlasTexture tiles the whole atlas, not the region).
	var grass_atlas: Texture2D = load("res://assets/sprites/tiles/grass_v2_atlas.png")
	if grass_atlas != null:
		var atlas_img: Image = grass_atlas.get_image()
		var _extract := func(col: int, row: int) -> ImageTexture:
			var tile_img := atlas_img.get_region(Rect2i(col * 16, row * 16, 16, 16))
			return ImageTexture.create_from_image(tile_img)
		veg_grass = _extract.call(0, 0)          # Césped A
		veg_grass_b = _extract.call(1, 0)        # Césped B
		veg_grass_c = _extract.call(2, 0)        # Césped C brillante
		veg_grass_flowers = _extract.call(0, 1)  # Césped con Flores
		veg_tall_grass = _extract.call(1, 1)     # Hierba Alta
		veg_grass_stones = _extract.call(2, 1)   # Piedras en Césped
		veg_path_v = _extract.call(0, 2)         # Sendero Vertical
		veg_path_h = _extract.call(1, 2)         # Sendero Horizontal
		veg_transition = _extract.call(2, 2)     # Transición Césped→Tierra
	else:
		veg_grass = tex_grass
		veg_grass_b = tex_grass
		veg_grass_c = tex_grass
		veg_grass_flowers = tex_grass
		veg_path_v = tex_dirt
		veg_path_h = tex_dirt
		veg_tall_grass = tex_grass_dark
		veg_grass_stones = tex_grass
		veg_transition = tex_dirt


# =============================================================================
# GRASS SCATTER — places Césped B & C over the base A for natural variety
# =============================================================================

func _scatter_grass_variants(start_y: int, height: int):
	var cols := MAP_W / T
	var rows := height / T
	# Deterministic pseudo-random scatter using simple hash
	var idx := 0
	for r in int(rows):
		for c in int(cols):
			var h := (c * 7 + r * 13 + c * r * 3) % 100
			var tex: Texture2D = null
			if h < 20:
				tex = veg_grass_b   # 20% Césped B
			elif h < 30:
				tex = veg_grass_c   # 10% Césped C brillante
			# else: keep base veg_grass (70%)
			if tex != null:
				_ground_tile("GV_%d" % idx, c * T, start_y + r * T, tex)
				idx += 1


# =============================================================================
# VEGETATION HELPERS
# =============================================================================

## Park tree: crown (draws above player) + base (collision).
func _park_tree(n: String, x: int, y: int):
	# Base with collision (trunk area)
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp_base := Sprite2D.new()
	sp_base.texture = veg_tree_base
	sp_base.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp_base)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(12, 12)
	c.shape = s; b.add_child(c)
	# Crown above (z_index high, draws over player)
	var sp_crown := Sprite2D.new()
	sp_crown.name = n + "_Crown"
	sp_crown.texture = veg_tree_crown
	sp_crown.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp_crown.position = Vector2(x + 8, y - 8)
	sp_crown.z_index = 10
	add_child(sp_crown)


## Pine tree: single tile with collision.
func _pine(n: String, x: int, y: int):
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp := Sprite2D.new()
	sp.texture = veg_pine
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(12, 14)
	c.shape = s; b.add_child(c)


## Dense bush with collision.
func _veg_bush(n: String, x: int, y: int, tex: Texture2D = null):
	if tex == null:
		tex = veg_bush_dense
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(14, 14)
	c.shape = s; b.add_child(c)


## Ground decoration tile (no collision, z_index = -1).
func _ground_tile(n: String, x: int, y: int, tex: Texture2D):
	var sp := Sprite2D.new()
	sp.name = n
	sp.texture = tex
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.position = Vector2(x + 8, y + 8)
	sp.z_index = -1
	add_child(sp)


## Place multiple ground tiles in a row (for decorative ground variation).
func _ground_row(prefix: String, cols: Array, y: int, tex: Texture2D):
	for c in cols:
		_ground_tile("%s_%d" % [prefix, c], c * T, y, tex)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

## Tiled ground fill (no collision).
func _fill(n: String, x: int, y: int, w: int, h: int, tex: Texture2D):
	var r := TextureRect.new()
	r.name = n; r.texture = tex
	r.stretch_mode = TextureRect.STRETCH_TILE
	r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	r.position = Vector2(x, y); r.size = Vector2(w, h)
	r.z_index = -1
	add_child(r)


## StaticBody2D wall with tiled texture.
func _wall(n: String, x: int, y: int, w: int, h: int, tex: Texture2D) -> StaticBody2D:
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + w / 2.0, y + h / 2.0)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var v := TextureRect.new()
	v.texture = tex; v.stretch_mode = TextureRect.STRETCH_TILE
	v.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	v.size = Vector2(w, h); v.position = Vector2(-w / 2.0, -h / 2.0)
	b.add_child(v)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(w, h)
	c.shape = s; b.add_child(c)
	return b


## Invisible wall (collision only).
func _invis(n: String, x: int, y: int, w: int, h: int):
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + w / 2.0, y + h / 2.0)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(w, h)
	c.shape = s; b.add_child(c)


## Tree with sprite + collision.
func _tree(n: String, x: int, y: int):
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp := Sprite2D.new()
	sp.texture = tex_tree; sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(14, 14)
	c.shape = s; b.add_child(c)


## Bush with sprite + collision.
func _bush(n: String, x: int, y: int):
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp := Sprite2D.new()
	sp.texture = tex_bush; sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(14, 14)
	c.shape = s; b.add_child(c)


## Car sprite + collision.
func _car(n: String, x: int, y: int, tex: Texture2D):
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp := Sprite2D.new()
	sp.texture = tex; sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(14, 14)
	c.shape = s; b.add_child(c)


## Animated moving car.
func _moving_car(n: String, x: int, y: int, color: String, fallback_tex: Texture2D, spd: float, dir: int):
	var c := Node2D.new()
	c.set_script(car_script)
	c.name = n
	c.position = Vector2(x + 12, y + 12)
	c.setup(CAR_SHEETS.get(color, ""), fallback_tex, spd, dir, float(MAP_W))
	add_child(c)


## Decorative sprite (no collision).
func _deco(n: String, x: int, y: int, tex: Texture2D):
	var sp := Sprite2D.new()
	sp.name = n; sp.texture = tex
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.position = Vector2(x + 8, y + 8)
	add_child(sp)


## Decorative sprite with collision.
func _deco_col(n: String, x: int, y: int, tex: Texture2D):
	var b := StaticBody2D.new()
	b.name = n; b.position = Vector2(x + 8, y + 8)
	b.collision_layer = 2; b.collision_mask = 0
	add_child(b)
	var sp := Sprite2D.new()
	sp.texture = tex; sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.add_child(sp)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(10, 10)
	c.shape = s; b.add_child(c)


## Scaled decorative sprite (fountain etc.).
func _deco_big(n: String, x: int, y: int, tex: Texture2D, sc: float):
	var sp := Sprite2D.new()
	sp.name = n; sp.texture = tex
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.position = Vector2(x, y); sp.scale = Vector2(sc, sc)
	add_child(sp)


## NPC placeholder (colored rectangle).
func _npc(n: String, x: int, y: int, color: Color):
	var r := ColorRect.new()
	r.name = n; r.position = Vector2(x, y)
	r.size = Vector2(10, 14); r.color = color
	add_child(r)


## Interactable door → scene transition.
func _door(n: String, x: int, y: int, w: int, h: int, tex: Texture2D, target: String):
	var vis := TextureRect.new()
	vis.name = n + "_V"; vis.texture = tex
	vis.stretch_mode = TextureRect.STRETCH_TILE
	vis.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vis.position = Vector2(x, y); vis.size = Vector2(w, h)
	add_child(vis)
	var d := Area2D.new()
	d.name = n; d.position = Vector2(x + w / 2.0, y + h / 2.0)
	d.collision_layer = 2; d.collision_mask = 0
	d.set_script(load("res://scripts/interactable.gd"))
	d.interaction_type = "transition"; d.target_scene = target
	add_child(d)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(w, h)
	c.shape = s; d.add_child(c)
	var lbl := Label.new()
	lbl.text = "[E] Entrar"
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	lbl.position = Vector2(-w / 2.0, h / 2.0 + 2)
	d.add_child(lbl)


## Interactable dialogue area.
func _dialogue_area(n: String, x: int, y: int, w: int, h: int, did: String):
	var a := Area2D.new()
	a.name = n; a.position = Vector2(x + w / 2.0, y + h / 2.0)
	a.collision_layer = 2; a.collision_mask = 0
	a.set_script(load("res://scripts/interactable.gd"))
	a.interaction_type = "dialogue"; a.dialogue_id = did
	add_child(a)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = Vector2(w, h)
	c.shape = s; a.add_child(c)


## Enemy spawners.
func _enemy_fear(n: String, x: int, y: int, patrol: Array[Vector2] = []):
	var e = EnemyFearScene.instantiate()
	e.name = n; e.position = Vector2(x, y)
	if patrol.size() > 0: e.patrol_points = patrol
	add_child(e)

func _enemy_sad(n: String, x: int, y: int, patrol: Array[Vector2] = []):
	var e = EnemySadnessScene.instantiate()
	e.name = n; e.position = Vector2(x, y)
	if patrol.size() > 0: e.patrol_points = patrol
	add_child(e)

func _enemy_lone(n: String, x: int, y: int):
	var e = EnemyLonelinessScene.instantiate()
	e.name = n; e.position = Vector2(x, y)
	add_child(e)


## Secret collectible.
func _secret(item_id: String, item_type: String, x: int, y: int, text: String):
	if GameManager.is_collected(item_id):
		return
	var it = SecretItemScene.instantiate()
	it.name = "Sec_" + item_id; it.item_id = item_id
	it.item_type = item_type; it.display_text = text
	it.position = Vector2(x, y)
	add_child(it)


## Flash trigger.
func _flash(n: String, x: int, y: int, sz: Vector2, phrase: String, one_shot: bool):
	var t := Area2D.new()
	t.name = n; t.position = Vector2(x + sz.x / 2.0, y + sz.y / 2.0)
	t.collision_layer = 0; t.collision_mask = 1
	t.set_script(load("res://scripts/ui/flash_trigger.gd"))
	t.flash_phrase = phrase; t.one_shot = one_shot
	add_child(t)
	var c := CollisionShape2D.new()
	var s := RectangleShape2D.new(); s.size = sz
	c.shape = s; t.add_child(c)


## Floating navigation arrow.
func _arrow(n: String, x: int, y: int, text: String):
	var l := Label.new()
	l.name = n; l.text = text; l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 0.9))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override("shadow_offset_x", 1)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.z_index = 10
	add_child(l)
	var tw := create_tween().set_loops()
	tw.tween_property(l, "position:y", float(y - 3), 0.8).set_trans(Tween.TRANS_SINE)
	tw.tween_property(l, "position:y", float(y + 3), 0.8).set_trans(Tween.TRANS_SINE)
