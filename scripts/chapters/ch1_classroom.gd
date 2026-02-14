extends Node2D
## Ch1Classroom — Interior del instituto (~360x260 px, compacto).
## Secuencia lineal: entrada, auto-walk, diálogo, batalla Undertale, cartel P5, diálogo, transición.
## No hay exploración libre — todo es scriptado.

const MAP_WIDTH: int = 360
const MAP_HEIGHT: int = 260

# Packed scenes
var PlayerScene: PackedScene = preload("res://scenes/player/player.tscn")
var HUDScene: PackedScene = preload("res://scenes/ui/hud.tscn")
var DialogueBoxScene: PackedScene = preload("res://scenes/ui/dialogue_box.tscn")
var WordShieldScene: PackedScene = preload("res://scenes/combat/word_shield.tscn")

# Classmate spritesheet paths (32x32, 4 dirs × 3 frames each)
const CLASSMATE_SHEETS: Dictionary = {
	"carlos": "res://assets/sprites/npcs/classmates/carlos_spritesheet.png",
	"ahmed": "res://assets/sprites/npcs/classmates/ahmed_spritesheet.png",
	"marta": "res://assets/sprites/npcs/classmates/marta_spritesheet.png",
	"sara": "res://assets/sprites/npcs/classmates/sara_spritesheet.png",
	"pablo": "res://assets/sprites/npcs/classmates/pablo_spritesheet.png",
	"amina": "res://assets/sprites/npcs/classmates/amina_spritesheet.png",
	"elena": "res://assets/sprites/npcs/classmates/elena_spritesheet.png",
	"wei": "res://assets/sprites/npcs/classmates/wei_spritesheet.png",
}

# Sequence state
enum Phase { ENTERING, DIALOGUE_PRE, BATTLE, DIALOGUE_POST, FADE_OUT }
var current_phase: Phase = Phase.ENTERING

# Node references
var player: CharacterBody2D
var camera: Camera2D
var word_shield_battle: Control
var cristian_seat_pos: Vector2

# Bully NPC references (for cinematic movement)
var npc_lewis: Sprite2D
var npc_joan: Sprite2D
var npc_robert: Sprite2D


func _ready():
	# Crossfade from street music to classroom theme, stop traffic ambient
	AudioManager.crossfade_music("ch1_aula_inquietud", 1.5)
	AudioManager.stop_ambient(1.0)

	# Load dialogues
	DialogueManager.load_dialogues("res://data/dialogues/chapter1.json")

	# Build classroom environment
	_build_classroom()

	# Spawn player at door position
	_spawn_player(Vector2(180, 240))

	# UI layers
	add_child(DialogueBoxScene.instantiate())

	# Connect dialogue signals for sequence flow and cinematic actions
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_displayed.connect(_on_line_displayed)

	# Start scripted sequence
	await get_tree().create_timer(0.3).timeout
	_start_sequence()


# =============================================================================
# PLAYER SPAWN
# =============================================================================
func _spawn_player(pos: Vector2):
	player = PlayerScene.instantiate()
	player.position = pos
	player.can_move = false
	add_child(player)

	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.enabled = true
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = MAP_WIDTH
	camera.limit_bottom = MAP_HEIGHT
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)


# =============================================================================
# BUILD CLASSROOM LAYOUT (compacto: 3 cols × 3 filas)
# =============================================================================
func _build_classroom():
	# --- Floor ---
	_add_tiled_rect("Floor", Vector2.ZERO, Vector2(MAP_WIDTH, MAP_HEIGHT),
		"res://assets/sprites/tiles/floor_classroom.png", -2)

	# --- Hallway (bottom strip, 50px tall) ---
	_add_tiled_rect("Hallway", Vector2(0, 210), Vector2(MAP_WIDTH, 50),
		"res://assets/sprites/tiles/floor_concrete.png", -1)

	# --- Lockers along hallway ---
	for i in range(5):
		var locker_x: float = 30.0 + i * 64.0
		_add_wall_with_sprite("Locker_%d" % i, Vector2(locker_x, 212), Vector2(16, 36),
			"res://assets/sprites/tiles/locker.png")

	# --- Hallway/classroom divider wall (with doorway gap) ---
	_add_wall("ClassroomWall_L", Vector2(0, 196), Vector2(140, 16))
	_add_wall("ClassroomWall_R", Vector2(220, 196), Vector2(140, 16))
	# Gap at 140-220 is the classroom doorway

	# --- Classroom walls ---
	_add_wall("Wall_Top", Vector2(0, 0), Vector2(MAP_WIDTH, 16))
	_add_wall("Wall_Left", Vector2(0, 16), Vector2(16, 180))
	_add_wall("Wall_Right", Vector2(344, 16), Vector2(16, 180))

	# --- Blackboard ---
	_add_sprite_rect("Blackboard", Vector2(100, 18), Vector2(160, 26),
		"res://assets/sprites/tiles/blackboard.png")
	var board_text := Label.new()
	board_text.name = "BoardText"
	board_text.text = "3-A"
	board_text.position = Vector2(165, 22)
	board_text.add_theme_font_size_override("font_size", 14)
	board_text.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	add_child(board_text)

	# --- Teacher's desk ---
	_add_wall_with_sprite("TeacherDesk", Vector2(140, 50), Vector2(80, 20),
		"res://assets/sprites/tiles/desk.png")

	# --- Student desks (3 cols x 3 rows) ---
	var desk_start := Vector2(40, 80)
	var desk_spacing := Vector2(100, 38)
	var desk_size := Vector2(44, 22)

	for row in range(3):
		for col in range(3):
			var desk_pos := desk_start + Vector2(col * desk_spacing.x, row * desk_spacing.y)
			_add_wall_with_sprite("Desk_%d_%d" % [row, col], desk_pos, desk_size,
				"res://assets/sprites/tiles/table_student.png")

	# --- Cristian's seat (row 1, col 1 — center desk) ---
	cristian_seat_pos = desk_start + Vector2(1 * desk_spacing.x + desk_size.x * 0.5, 1 * desk_spacing.y + desk_size.y + 6)

	# --- NPCs: Bullies ---
	# Lewis — front row, right
	npc_lewis = _add_npc_sprite("NPC_Lewis", desk_start + Vector2(2 * desk_spacing.x + 18, 0 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/lewis.png", "Lewis")
	# Joan — second row, right
	npc_joan = _add_npc_sprite("NPC_Joan", desk_start + Vector2(2 * desk_spacing.x + 18, 1 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/joan.png", "Joan")
	# Robert — back row, right
	npc_robert = _add_npc_sprite("NPC_Robert", desk_start + Vector2(2 * desk_spacing.x + 18, 2 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/robert.png", "Robert")

	# --- Classmates ---
	_add_classmate("NPC_Carlos", desk_start + Vector2(0 * desk_spacing.x + 18, 0 * desk_spacing.y + 4), "carlos")
	_add_classmate("NPC_Marta", desk_start + Vector2(1 * desk_spacing.x + 18, 0 * desk_spacing.y + 4), "marta")
	_add_classmate("NPC_Ahmed", desk_start + Vector2(0 * desk_spacing.x + 18, 1 * desk_spacing.y + 4), "ahmed")
	_add_classmate("NPC_Sara", desk_start + Vector2(0 * desk_spacing.x + 18, 2 * desk_spacing.y + 4), "sara")
	_add_classmate("NPC_Pablo", desk_start + Vector2(1 * desk_spacing.x + 18, 2 * desk_spacing.y + 4), "pablo")

	# --- Lucy (back row, behind Cristian) ---
	_add_npc_sprite("NPC_Lucy", desk_start + Vector2(1 * desk_spacing.x + 18, 2 * desk_spacing.y + 4) + Vector2(20, 0),
		"res://assets/sprites/npcs/lucy.png", "")

	# --- Professor (initially invisible) ---
	var prof_sprite := Sprite2D.new()
	prof_sprite.name = "NPC_DonPeter"
	prof_sprite.texture = load("res://assets/sprites/npcs/teacher.png")
	prof_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	prof_sprite.position = Vector2(175, 57)
	prof_sprite.visible = false
	add_child(prof_sprite)


# =============================================================================
# SCRIPTED SEQUENCE
# =============================================================================
func _start_sequence():
	current_phase = Phase.ENTERING

	# Auto-walk player from door to seat
	await _auto_walk_player(cristian_seat_pos)

	# Small pause, then start pre-attack dialogue
	await get_tree().create_timer(0.4).timeout
	current_phase = Phase.DIALOGUE_PRE
	DialogueManager.start_dialogue("classroom_pre_attack")


func _on_line_displayed(speaker: String, text: String, _emotion: String, _portrait: String):
	# Cinematic: when narrator says bullies approach, animate them toward Cristian
	if speaker == "Narrador" and "Los tres se acercan" in text:
		_animate_bullies_approach()


func _animate_bullies_approach():
	if not player:
		return
	var target := player.position

	if npc_lewis and is_instance_valid(npc_lewis):
		var tw1 := create_tween()
		tw1.tween_property(npc_lewis, "position",
			Vector2(target.x + 20, target.y - 18), 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	if npc_joan and is_instance_valid(npc_joan):
		var tw2 := create_tween()
		tw2.tween_property(npc_joan, "position",
			Vector2(target.x + 35, target.y - 8), 1.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	if npc_robert and is_instance_valid(npc_robert):
		var tw3 := create_tween()
		tw3.tween_property(npc_robert, "position",
			Vector2(target.x - 20, target.y - 14), 1.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)


func _on_dialogue_ended():
	match current_phase:
		Phase.DIALOGUE_PRE:
			_start_battle()
		Phase.DIALOGUE_POST:
			_fade_and_transition()


func _start_battle():
	current_phase = Phase.BATTLE

	# Comic intro explaining the battle mechanics
	var intro_layer = CanvasLayer.new()
	intro_layer.layer = 15
	intro_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(intro_layer)

	var intro_script = load("res://scripts/minigames/comic_intro.gd")
	var battle_intro = Control.new()
	battle_intro.set_script(intro_script)
	battle_intro.size = Vector2(320, 180)
	battle_intro.position = Vector2.ZERO
	intro_layer.add_child(battle_intro)

	await get_tree().process_frame
	battle_intro.intro_finished.connect(func():
		intro_layer.queue_free()
	)
	battle_intro.show_single_panel("¡ESCUDO DE PALABRAS!\nRecoge las Palabras de Luz para formar tu escudo.\n¡Esquiva las Palabras Sombra!\nMueve tu corazón con las flechas.")
	await battle_intro.intro_finished

	# Create WordShield on a CanvasLayer
	var battle_layer = CanvasLayer.new()
	battle_layer.name = "BattleLayer"
	battle_layer.layer = 12
	battle_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(battle_layer)

	word_shield_battle = WordShieldScene.instantiate()
	word_shield_battle.name = "WordShield"
	word_shield_battle.split_screen = true
	battle_layer.add_child(word_shield_battle)

	word_shield_battle.combat_won.connect(_on_battle_finished)
	word_shield_battle.combat_lost.connect(_on_battle_finished)

	await get_tree().create_timer(0.3).timeout
	word_shield_battle.start_battle(1)


func _on_battle_finished():
	current_phase = Phase.DIALOGUE_POST

	# Clean up battle
	if word_shield_battle:
		var battle_layer = word_shield_battle.get_parent()
		if battle_layer is CanvasLayer:
			battle_layer.visible = false
			battle_layer.queue_free()
		else:
			word_shield_battle.queue_free()
		word_shield_battle = null

	if player:
		player.set_physics_process(true)

	await get_tree().process_frame

	# --- Cartel estilo Persona 5: "¿Por qué siempre yo?" + timbre ---
	await _show_persona_card()

	await get_tree().create_timer(0.5).timeout
	DialogueManager.start_dialogue("classroom_post_attack")


# =============================================================================
# PERSONA 5 STYLE CARD — "¿Por qué siempre yo?"
# =============================================================================
func _show_persona_card():
	# School bell sound (placeholder — replace with proper sfx_school_bell)
	AudioManager.play_sfx("sfx_wall_warning")

	var card_layer := CanvasLayer.new()
	card_layer.name = "PersonaCard"
	card_layer.layer = 80
	add_child(card_layer)

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	card_layer.add_child(overlay)

	# Red diagonal stripe (Persona 5 style)
	var stripe := ColorRect.new()
	stripe.set_anchors_preset(Control.PRESET_CENTER)
	stripe.offset_left = -200
	stripe.offset_right = 200
	stripe.offset_top = -22
	stripe.offset_bottom = 22
	stripe.color = Color(0.85, 0.1, 0.1, 0.0)
	stripe.rotation = -0.05  # Slight angle
	stripe.pivot_offset = Vector2(200, 22)
	card_layer.add_child(stripe)

	# Main text
	var text_label := Label.new()
	text_label.text = "¿Por qué siempre yo?"
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.set_anchors_preset(Control.PRESET_CENTER)
	text_label.offset_left = -140
	text_label.offset_right = 140
	text_label.offset_top = -15
	text_label.offset_bottom = 15
	text_label.add_theme_font_size_override("font_size", 16)
	text_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.0))
	text_label.rotation = -0.05
	text_label.pivot_offset = Vector2(140, 15)
	card_layer.add_child(text_label)

	# Black outline effect — shadow text behind
	var shadow_label := Label.new()
	shadow_label.text = "¿Por qué siempre yo?"
	shadow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shadow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shadow_label.set_anchors_preset(Control.PRESET_CENTER)
	shadow_label.offset_left = -139
	shadow_label.offset_right = 141
	shadow_label.offset_top = -14
	shadow_label.offset_bottom = 16
	shadow_label.add_theme_font_size_override("font_size", 16)
	shadow_label.add_theme_color_override("font_color", Color(0, 0, 0, 0.0))
	shadow_label.rotation = -0.05
	shadow_label.pivot_offset = Vector2(140, 15)
	card_layer.add_child(shadow_label)
	# Move main text in front of shadow
	card_layer.move_child(text_label, card_layer.get_child_count())

	# === ANIMATION: Slam in from left ===
	# Start off-screen left
	stripe.offset_left = -500
	stripe.offset_right = -100
	text_label.offset_left = -500
	text_label.offset_right = -220
	shadow_label.offset_left = -499
	shadow_label.offset_right = -219

	var tween := create_tween()
	tween.set_parallel(true)

	# Overlay fade in
	tween.tween_property(overlay, "color:a", 0.5, 0.15)

	# Stripe slams in
	tween.tween_property(stripe, "offset_left", -200.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(stripe, "offset_right", 200.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(stripe, "color:a", 0.95, 0.15)

	# Text slams in (slight delay)
	tween.tween_property(text_label, "offset_left", -140.0, 0.25).set_delay(0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(text_label, "offset_right", 140.0, 0.25).set_delay(0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(text_label, "theme_override_colors/font_color:a", 1.0, 0.15).set_delay(0.05)

	tween.tween_property(shadow_label, "offset_left", -139.0, 0.25).set_delay(0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(shadow_label, "offset_right", 141.0, 0.25).set_delay(0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(shadow_label, "theme_override_colors/font_color:a", 0.8, 0.15).set_delay(0.05)

	await tween.finished

	# Hold for 3 seconds
	await get_tree().create_timer(3.0).timeout

	# Slide out to the right
	var tween_out := create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(stripe, "offset_left", 300.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(stripe, "offset_right", 700.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(text_label, "offset_left", 300.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(text_label, "offset_right", 580.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(shadow_label, "offset_left", 301.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(shadow_label, "offset_right", 581.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween_out.tween_property(overlay, "color:a", 0.0, 0.3)
	await tween_out.finished

	card_layer.queue_free()


func _fade_and_transition():
	current_phase = Phase.FADE_OUT

	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	if DialogueManager.line_displayed.is_connected(_on_line_displayed):
		DialogueManager.line_displayed.disconnect(_on_line_displayed)

	TransitionManager.change_scene("res://scenes/chapters/chapter1/ch1_bedroom_evening.tscn")


# =============================================================================
# AUTO-WALK — Move player along a path to a target position
# =============================================================================
func _auto_walk_player(target: Vector2):
	if not player:
		return

	player.can_move = false
	player.set_physics_process(false)
	var walk_speed: float = 80.0

	var waypoints: Array[Vector2] = []

	# If player is in the hallway, walk through doorway first
	if player.position.y > 196:
		waypoints.append(Vector2(180, 190))

	waypoints.append(target)

	for waypoint in waypoints:
		while player.position.distance_to(waypoint) > 3.0:
			var delta_t := get_physics_process_delta_time()
			var dir := (waypoint - player.position).normalized()
			player.position += dir * walk_speed * delta_t

			if abs(dir.x) >= abs(dir.y):
				player.facing = "right" if dir.x > 0 else "left"
			else:
				player.facing = "down" if dir.y > 0 else "up"

			if player.animated_sprite and player.animated_sprite.sprite_frames:
				var anim: String = "walk_" + player.facing
				if player.animated_sprite.sprite_frames.has_animation(anim):
					if player.animated_sprite.animation != anim:
						player.animated_sprite.play(anim)

			await get_tree().process_frame

	player.position = target
	if player.animated_sprite and player.animated_sprite.sprite_frames:
		var idle: String = "idle_" + player.facing
		if player.animated_sprite.sprite_frames.has_animation(idle):
			player.animated_sprite.play(idle)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

func _add_tiled_rect(rect_name: String, pos: Vector2, rect_size: Vector2,
		sprite_path: String, z: int = -1) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = rect_name
	rect.texture = load(sprite_path)
	rect.stretch_mode = TextureRect.STRETCH_TILE
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rect.position = pos
	rect.size = rect_size
	rect.z_index = z
	add_child(rect)
	return rect


func _add_sprite_rect(rect_name: String, pos: Vector2, rect_size: Vector2,
		sprite_path: String) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.name = rect_name
	spr.texture = load(sprite_path)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = pos + rect_size * 0.5
	spr.z_index = -1
	add_child(spr)
	return spr


func _add_wall(wall_name: String, pos: Vector2, wall_size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = wall_name
	body.position = pos + wall_size * 0.5
	body.collision_layer = 2
	body.collision_mask = 0
	add_child(body)

	var visual := TextureRect.new()
	visual.texture = load("res://assets/sprites/tiles/wall_school.png")
	visual.stretch_mode = TextureRect.STRETCH_TILE
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.size = wall_size
	visual.position = -wall_size * 0.5
	body.add_child(visual)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = wall_size
	col.shape = shape
	body.add_child(col)

	return body


func _add_wall_with_sprite(wall_name: String, pos: Vector2, wall_size: Vector2,
		sprite_path: String) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = wall_name
	body.position = pos + wall_size * 0.5
	body.collision_layer = 2
	body.collision_mask = 0
	add_child(body)

	var visual := Sprite2D.new()
	visual.texture = load(sprite_path)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(visual)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = wall_size
	col.shape = shape
	body.add_child(col)

	return body


func _add_npc_sprite(npc_name: String, pos: Vector2, sprite_path: String, label_text: String) -> Sprite2D:
	var npc := Sprite2D.new()
	npc.name = npc_name
	npc.texture = load(sprite_path)
	npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.position = pos + Vector2(5, 7)
	npc.z_index = 1
	add_child(npc)

	if label_text != "":
		var label := Label.new()
		label.text = label_text
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		label.position = Vector2(-9, -17)
		npc.add_child(label)

	return npc


func _add_classmate(npc_name: String, pos: Vector2, sheet_key: String) -> AnimatedSprite2D:
	var sheet: Texture2D = load(CLASSMATE_SHEETS[sheet_key])
	if sheet == null:
		return null

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	const FW: int = 32
	const FH: int = 32
	var dir_rows: Dictionary = {"down": 0, "up": 1, "left": 2, "right": 3}

	for dir_name in ["down", "up", "left", "right"]:
		var row: int = dir_rows[dir_name]
		var idle_name: String = "idle_" + dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 8)
		frames.set_animation_loop(idle_name, true)
		frames.add_frame(idle_name, _classmate_atlas(sheet, 0, row))

		var walk_name: String = "walk_" + dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, 8)
		frames.set_animation_loop(walk_name, true)
		frames.add_frame(walk_name, _classmate_atlas(sheet, 0, row))
		frames.add_frame(walk_name, _classmate_atlas(sheet, 1, row))
		frames.add_frame(walk_name, _classmate_atlas(sheet, 0, row))
		frames.add_frame(walk_name, _classmate_atlas(sheet, 2, row))

	var npc := AnimatedSprite2D.new()
	npc.name = npc_name
	npc.sprite_frames = frames
	npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.scale = Vector2(0.5, 0.5)
	npc.position = pos + Vector2(8, 8)
	npc.z_index = 1
	npc.play("idle_down")
	add_child(npc)
	return npc


func _classmate_atlas(sheet: Texture2D, col: int, row: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = sheet
	at.region = Rect2(col * 32, row * 32, 32, 32)
	at.filter_clip = true
	return at
