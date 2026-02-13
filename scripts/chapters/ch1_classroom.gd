extends Node2D
## Ch1Classroom — Interior del instituto (~560x400 px).
## Secuencia lineal: entrada, auto-walk, diálogo, batalla Undertale, diálogo, transición.
## No hay exploración libre — todo es scriptado.
## Uses tiled sprites for floor/walls, Sprite2D for furniture and NPCs.

const MAP_WIDTH: int = 560
const MAP_HEIGHT: int = 400

# Packed scenes
var PlayerScene: PackedScene = preload("res://scenes/player/player.tscn")
var HUDScene: PackedScene = preload("res://scenes/ui/hud.tscn")
var DialogueBoxScene: PackedScene = preload("res://scenes/ui/dialogue_box.tscn")
var WordShieldScene: PackedScene = preload("res://scenes/combat/word_shield.tscn")

# Classmates spritesheet (128x24, 8 frames of 16x24)
var classmates_sheet: Texture2D = preload("res://assets/sprites/npcs/classmates_strip.png")

# Sequence state
enum Phase { ENTERING, DIALOGUE_PRE, BATTLE, DIALOGUE_POST, FADE_OUT }
var current_phase: Phase = Phase.ENTERING

# Node references
var player: CharacterBody2D
var camera: Camera2D
var word_shield_battle: Control
var cristian_seat_pos: Vector2 = Vector2(200, 240)

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
	_spawn_player(Vector2(280, 380))

	# UI layers — no HUD in this scripted scene (Undertale battle has its own HP display)
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
	player.can_move = false # No free roaming
	add_child(player)

	# Camera2D with classroom bounds
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
# BUILD CLASSROOM LAYOUT
# =============================================================================
func _build_classroom():
	# --- Floor (classroom area) ---
	_add_tiled_rect("Floor", Vector2.ZERO, Vector2(MAP_WIDTH, MAP_HEIGHT),
		"res://assets/sprites/tiles/floor_classroom.png", -2)

	# --- Hallway (bottom strip, ~80px tall) — concrete floor ---
	_add_tiled_rect("Hallway", Vector2(0, 340), Vector2(MAP_WIDTH, 60),
		"res://assets/sprites/tiles/floor_concrete.png", -1)

	# --- Lockers along hallway walls ---
	for i in range(10):
		var locker_x: float = 20.0 + i * 52.0
		_add_wall_with_sprite("Locker_%d" % i, Vector2(locker_x, 340), Vector2(16, 40),
			"res://assets/sprites/tiles/locker.png")

	# --- Hallway/classroom divider wall (with doorway gap) ---
	_add_wall("ClassroomWall_L", Vector2(0, 320), Vector2(240, 20))
	_add_wall("ClassroomWall_R", Vector2(320, 320), Vector2(240, 20))
	# Gap at 240-320 is the classroom doorway

	# --- Classroom walls ---
	_add_wall("Wall_Top", Vector2(0, 0), Vector2(MAP_WIDTH, 20))
	_add_wall("Wall_Left", Vector2(0, 20), Vector2(20, 300))
	_add_wall("Wall_Right", Vector2(540, 20), Vector2(20, 300))

	# --- Blackboard ---
	_add_sprite_rect("Blackboard", Vector2(160, 22), Vector2(200, 30),
		"res://assets/sprites/tiles/blackboard.png")
	var board_text := Label.new()
	board_text.name = "BoardText"
	board_text.text = "3-A"
	board_text.position = Vector2(235, 28)
	board_text.add_theme_font_size_override("font_size", 14)
	board_text.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	add_child(board_text)

	# --- Teacher's desk ---
	_add_wall_with_sprite("TeacherDesk", Vector2(220, 60), Vector2(80, 24),
		"res://assets/sprites/tiles/desk.png")

	# --- Student desks (4 rows x 5 columns) ---
	var desk_start := Vector2(60, 110)
	var desk_spacing := Vector2(100, 48)
	var desk_size := Vector2(44, 22)

	for row in range(4):
		for col in range(5):
			var desk_pos := desk_start + Vector2(col * desk_spacing.x, row * desk_spacing.y)
			var desk_name := "Desk_%d_%d" % [row, col]
			_add_wall_with_sprite(desk_name, desk_pos, desk_size,
				"res://assets/sprites/tiles/table_student.png")

	# --- Cristian's seat marker (row 2, col 1 — second row, second column) ---
	# Position matches desk at row=2, col=1
	cristian_seat_pos = desk_start + Vector2(1 * desk_spacing.x + desk_size.x * 0.5, 2 * desk_spacing.y + desk_size.y + 6)
	# Seat marker remains a subtle ColorRect overlay (no sprite needed)
	var seat_marker := ColorRect.new()
	seat_marker.name = "CristianSeatMarker"
	seat_marker.position = cristian_seat_pos - Vector2(5, 5)
	seat_marker.size = Vector2(10, 10)
	seat_marker.color = Color(0.3, 0.5, 0.8, 0.4)
	seat_marker.z_index = -1
	add_child(seat_marker)

	# --- NPCs: Bullies ---
	# NPC Y offset: +4 puts center ~16px below desk top → upper body above desk, legs hidden
	# z_index = -1 so desks render in front of NPC legs
	# Lewis (red-ish) — front of class
	npc_lewis = _add_npc_sprite("NPC_Lewis", desk_start + Vector2(3 * desk_spacing.x + 18, 0 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/lewis.png", "Lewis")
	# Joan (orange) — near Lewis
	npc_joan = _add_npc_sprite("NPC_Joan", desk_start + Vector2(4 * desk_spacing.x + 18, 0 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/joan.png", "Joan")
	# Robert (dark red) — second row
	npc_robert = _add_npc_sprite("NPC_Robert", desk_start + Vector2(3 * desk_spacing.x + 18, 1 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/robert.png", "Robert")
	# Mike (brown) — second row (stays at desk, doesn't approach)
	_add_npc_sprite("NPC_Mike", desk_start + Vector2(4 * desk_spacing.x + 18, 1 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/mike.png", "Mike")

	# --- Classmates (from classmates_strip.png — 8 unique characters, 16x24 each) ---
	# Frame 0=Carlos, 1=Ahmed, 2=Pablo, 3=Wei, 4=Marta, 5=Amina, 6=Sara, 7=Elena
	_add_classmate("NPC_Carlos", desk_start + Vector2(0 * desk_spacing.x + 18, 0 * desk_spacing.y + 4), 0)
	_add_classmate("NPC_Marta", desk_start + Vector2(1 * desk_spacing.x + 18, 0 * desk_spacing.y + 4), 4)
	_add_classmate("NPC_Wei", desk_start + Vector2(2 * desk_spacing.x + 18, 0 * desk_spacing.y + 4), 3)
	_add_classmate("NPC_Ahmed", desk_start + Vector2(0 * desk_spacing.x + 18, 1 * desk_spacing.y + 4), 1)
	_add_classmate("NPC_Sara", desk_start + Vector2(2 * desk_spacing.x + 18, 1 * desk_spacing.y + 4), 6)
	_add_classmate("NPC_Pablo", desk_start + Vector2(0 * desk_spacing.x + 18, 3 * desk_spacing.y + 4), 2)
	_add_classmate("NPC_Amina", desk_start + Vector2(2 * desk_spacing.x + 18, 3 * desk_spacing.y + 4), 5)
	_add_classmate("NPC_Elena", desk_start + Vector2(3 * desk_spacing.x + 18, 3 * desk_spacing.y + 4), 7)

	# --- Lucy (pink/light, in background — back row) ---
	_add_npc_sprite("NPC_Lucy", desk_start + Vector2(4 * desk_spacing.x + 18, 3 * desk_spacing.y + 4),
		"res://assets/sprites/npcs/lucy.png", "Lucy")

	# --- Professor Don Peter placeholder (will "arrive later" — initially invisible) ---
	var prof_sprite := Sprite2D.new()
	prof_sprite.name = "NPC_DonPeter"
	prof_sprite.texture = load("res://assets/sprites/npcs/teacher.png")
	prof_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	prof_sprite.position = Vector2(255 + 7, 65 + 9) # center of original 14x18 rect
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

	# Lewis — approaches from the front (closest)
	if npc_lewis and is_instance_valid(npc_lewis):
		var tw1 := create_tween()
		tw1.tween_property(npc_lewis, "position",
			Vector2(target.x + 20, target.y - 18), 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	# Joan — approaches from the right side
	if npc_joan and is_instance_valid(npc_joan):
		var tw2 := create_tween()
		tw2.tween_property(npc_joan, "position",
			Vector2(target.x + 40, target.y - 8), 1.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

	# Robert — approaches from the left side
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

	# Comic intro explaining the battle mechanics (on CanvasLayer for screen-space)
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

	# Create WordShield on a CanvasLayer (screen-space, independent of camera)
	var battle_layer = CanvasLayer.new()
	battle_layer.name = "BattleLayer"
	battle_layer.layer = 12
	battle_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(battle_layer)

	word_shield_battle = WordShieldScene.instantiate()
	word_shield_battle.name = "WordShield"
	word_shield_battle.split_screen = true
	battle_layer.add_child(word_shield_battle)

	# Connect signals — both won and lost end the scripted scene
	word_shield_battle.combat_won.connect(_on_battle_finished)
	word_shield_battle.combat_lost.connect(_on_battle_finished)

	# Small delay before starting
	await get_tree().create_timer(0.3).timeout
	word_shield_battle.start_battle(1)


func _on_battle_finished():
	current_phase = Phase.DIALOGUE_POST

	# Clean up battle + its CanvasLayer — hide immediately, then free
	if word_shield_battle:
		var battle_layer = word_shield_battle.get_parent()
		if battle_layer is CanvasLayer:
			battle_layer.visible = false
			battle_layer.queue_free()
		else:
			word_shield_battle.queue_free()
		word_shield_battle = null

	# Re-enable player physics (disabled during auto-walk)
	if player:
		player.set_physics_process(true)

	# Wait for tree to process cleanup, then brief pause
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	DialogueManager.start_dialogue("classroom_post_attack")


func _fade_and_transition():
	current_phase = Phase.FADE_OUT

	# Disconnect to avoid stale callbacks
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	if DialogueManager.line_displayed.is_connected(_on_line_displayed):
		DialogueManager.line_displayed.disconnect(_on_line_displayed)

	# Fade to black, change scene, fade from black (all handled by TransitionManager)
	TransitionManager.change_scene("res://scenes/chapters/chapter1/ch1_bedroom_evening.tscn")


# =============================================================================
# AUTO-WALK — Move player along a path to a target position
# =============================================================================
func _auto_walk_player(target: Vector2):
	if not player:
		return

	player.can_move = false
	# Disable physics collision so move_and_slide() doesn't push player
	# out of lockers/desks during the scripted walk
	player.set_physics_process(false)
	var walk_speed: float = 80.0

	# Walk through the doorway first (from hall into classroom)
	var waypoints: Array[Vector2] = []

	# If player is in the hallway, walk to doorway center first
	if player.position.y > 320:
		waypoints.append(Vector2(280, 310))

	# Then walk to the target seat
	waypoints.append(target)

	for waypoint in waypoints:
		while player.position.distance_to(waypoint) > 3.0:
			var delta_t := get_physics_process_delta_time()
			var dir := (waypoint - player.position).normalized()
			# Move position directly (player's _physics_process zeros velocity when can_move=false)
			player.position += dir * walk_speed * delta_t

			# Update facing for animation
			if abs(dir.x) >= abs(dir.y):
				player.facing = "right" if dir.x > 0 else "left"
			else:
				player.facing = "down" if dir.y > 0 else "up"

			# Force walk animation manually
			if player.animated_sprite and player.animated_sprite.sprite_frames:
				var anim: String = "walk_" + player.facing
				if player.animated_sprite.sprite_frames.has_animation(anim):
					if player.animated_sprite.animation != anim:
						player.animated_sprite.play(anim)

			await get_tree().process_frame

	# Snap to final position and show idle
	player.position = target
	if player.animated_sprite and player.animated_sprite.sprite_frames:
		var idle: String = "idle_" + player.facing
		if player.animated_sprite.sprite_frames.has_animation(idle):
			player.animated_sprite.play(idle)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

## Add a tiled TextureRect (no collision) — used for floors and large areas.
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


## Add a Sprite2D as a decorative rect (no collision) — used for blackboard etc.
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


## Add a StaticBody2D wall with a tiled TextureRect visual and CollisionShape2D.
func _add_wall(wall_name: String, pos: Vector2, wall_size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = wall_name
	body.position = pos + wall_size * 0.5
	body.collision_layer = 2 # Walls layer
	body.collision_mask = 0
	add_child(body)

	# Visual — tiled wall texture
	var visual := TextureRect.new()
	visual.texture = load("res://assets/sprites/tiles/wall_school.png")
	visual.stretch_mode = TextureRect.STRETCH_TILE
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.size = wall_size
	visual.position = -wall_size * 0.5
	body.add_child(visual)

	# Collision
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = wall_size
	col.shape = shape
	body.add_child(col)

	return body


## Add a StaticBody2D wall with a Sprite2D visual — used for desks, lockers, teacher desk.
func _add_wall_with_sprite(wall_name: String, pos: Vector2, wall_size: Vector2,
		sprite_path: String) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = wall_name
	body.position = pos + wall_size * 0.5
	body.collision_layer = 2
	body.collision_mask = 0
	add_child(body)

	# Visual — single sprite centered on the body
	var visual := Sprite2D.new()
	visual.texture = load(sprite_path)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(visual)

	# Collision
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = wall_size
	col.shape = shape
	body.add_child(col)

	return body


## Add an NPC as a Sprite2D (no collision, purely decorative). Optional name label.
func _add_npc_sprite(npc_name: String, pos: Vector2, sprite_path: String, label_text: String) -> Sprite2D:
	var npc := Sprite2D.new()
	npc.name = npc_name
	npc.texture = load(sprite_path)
	npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.position = pos + Vector2(5, 7)
	npc.z_index = 1  # In front of desks
	add_child(npc)

	if label_text != "":
		var label := Label.new()
		label.text = label_text
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
		label.position = Vector2(-9, -17)
		npc.add_child(label)

	return npc


## Add a classmate NPC from the classmates_strip.png spritesheet.
## frame_index: 0=Carlos, 1=Ahmed, 2=Pablo, 3=Wei, 4=Marta, 5=Amina, 6=Sara, 7=Elena
func _add_classmate(npc_name: String, pos: Vector2, frame_index: int) -> Sprite2D:
	var atlas := AtlasTexture.new()
	atlas.atlas = classmates_sheet
	atlas.region = Rect2(frame_index * 16, 0, 16, 24)
	atlas.filter_clip = true

	var npc := Sprite2D.new()
	npc.name = npc_name
	npc.texture = atlas
	npc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	npc.position = pos + Vector2(8, 12)
	npc.z_index = 1  # In front of desks
	add_child(npc)
	return npc
