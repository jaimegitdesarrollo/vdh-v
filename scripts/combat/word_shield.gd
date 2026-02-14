extends Control
## WordShield — Sistema de combate "Escudo de Palabras".
## Cristian recoge Palabras Luz para formar un escudo y esquiva Palabras Sombra.
## Configurable por capítulo vía JSON en data/word_shield/.
## Soporta variantes: Parálisis, Eco, Espejo, Peso, Silencio, Raíces.

signal combat_won
signal combat_lost

# --- Chapter config (loaded from JSON) ---
var chapter: int = 1
var light_ratio: float = 0.7
var spawn_interval: float = 1.2
var base_speed: float = 40.0
var shield_color: Color = Color("#FFD700")
var shield_glow: bool = true
var max_protection: float = 1.0
var required_light_words: int = 4
var auto_lose: bool = false
var auto_lose_timer: float = 35.0
var light_damage: float = 0.0
var shadow_fade: bool = false
var shadow_fade_time: float = 3.0
var light_words: Array = []
var shadow_words: Array = []
var background_phrases: Array = []
var battle_duration: float = 30.0

# --- Active variants ---
var active_variants: Array = []

# --- Paralysis config ---
var paralysis_cfg: Dictionary = {}
var _paralysis_count: int = 0
var _paralysis_timer: float = 0.0
var _is_paralyzed: bool = false
var _paralysis_next_interval: float = 10.0
var _frost_vignette: ColorRect

# --- Echo config ---
var echo_cfg: Dictionary = {}
var _echo_words: Array[Label] = []

# --- Mirror config ---
var mirror_cfg: Dictionary = {}
var _mirror_traps: Array = []

# --- Weight config ---
var weight_cfg: Dictionary = {}
var _speed_multiplier: float = 1.0

# --- Silence config ---
var silence_cfg: Dictionary = {}
var _silence_count_done: int = 0
var _silence_timer: float = 0.0
var _silence_next_interval: float = 20.0
var _is_silence: bool = false
var _silence_spawning_paused: bool = false
var _fear_label: Label

# --- Roots config ---
var roots_cfg: Dictionary = {}
var _root_positions: Array[Vector2] = []
var _root_lines: Array[Dictionary] = []
var _roots_canvas: Control

# --- Game state ---
var health: float = 100.0
var shield_power: float = 0.0
var collected_words: Array[String] = []
var is_active: bool = false
var _spawn_timer: float = 0.0
var _auto_lose_elapsed: float = 0.0
var _bg_phrase_timer: float = 0.0
var _battle_elapsed: float = 0.0
const BG_PHRASE_MIN_INTERVAL := 5.0
const BG_PHRASE_MAX_INTERVAL := 10.0

# --- Player ---
var player_heart: Sprite2D
const HEART_SIZE := Vector2(8, 8)
const PLAYER_SPEED: float = 150.0
var is_invincible: bool = false
var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 0.8

# --- Battle area ---
var battle_area: Rect2
var split_screen: bool = false

# --- UI refs ---
var health_bar_fill: ColorRect
var shield_bar_fill: ColorRect
var shield_label: Label
var health_label: Label
var countdown_label: Label
var floating_words: Array[Label] = []

# --- Light word styles per chapter range ---
const LIGHT_COLORS: Dictionary = {
	1: Color(1.0, 0.95, 0.6),
	2: Color(1.0, 0.95, 0.6),
	3: Color(0.8, 0.78, 0.6),
	4: Color(0.8, 0.78, 0.6),
	5: Color(0.5, 0.48, 0.45),
	6: Color(0.5, 0.48, 0.45),
	7: Color(0.7, 0.2, 0.2),
	8: Color(1.0, 0.92, 0.7),
}

const SHADOW_COLOR := Color(0.6, 0.1, 0.15)
const HIDDEN_COLOR := Color(0.5, 0.5, 0.5, 0.4)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func start_battle(ch: int = 1):
	chapter = ch
	_load_chapter(ch)
	health = 100.0
	shield_power = 0.0
	collected_words.clear()
	floating_words.clear()
	_echo_words.clear()
	_root_positions.clear()
	_root_lines.clear()
	_spawn_timer = 0.0
	_auto_lose_elapsed = 0.0
	_battle_elapsed = 0.0
	_bg_phrase_timer = randf_range(BG_PHRASE_MIN_INTERVAL, BG_PHRASE_MAX_INTERVAL)
	is_invincible = false
	_speed_multiplier = 1.0
	_paralysis_count = 0
	_is_paralyzed = false
	_silence_count_done = 0
	_is_silence = false
	_silence_spawning_paused = false
	_tremble_active = false
	visible = true
	get_tree().paused = true
	_setup_ui()
	_init_variants()
	is_active = true


func _load_chapter(ch: int):
	var path := "res://data/word_shield/chapter_%d.json" % ch
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("WordShield: no config for chapter %d" % ch)
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK or json.data == null:
		push_warning("WordShield: JSON parse error for chapter %d" % ch)
		return
	var data: Dictionary = json.data

	light_ratio = data.get("light_ratio", 0.7)
	spawn_interval = data.get("spawn_interval", 1.2)
	base_speed = data.get("base_speed", 40.0)
	shield_color = Color(data.get("shield_color", "#FFD700"))
	shield_glow = data.get("shield_glow", true)
	max_protection = data.get("max_protection", 1.0)
	required_light_words = data.get("required_light_words", 4)
	auto_lose = data.get("auto_lose", false)
	auto_lose_timer = data.get("auto_lose_timer", 35.0)
	light_damage = data.get("light_damage", 0.0)
	shadow_fade = data.get("shadow_fade", false)
	shadow_fade_time = data.get("shadow_fade_time", 3.0)
	light_words = data.get("light_words", [])
	shadow_words = data.get("shadow_words", [])
	background_phrases = data.get("background_phrases", [])
	battle_duration = data.get("battle_duration", 30.0)

	# Variants
	active_variants = data.get("variants", [])
	paralysis_cfg = data.get("paralysis_config", {})
	echo_cfg = data.get("echo_config", {})
	mirror_cfg = data.get("mirror_config", {})
	weight_cfg = data.get("weight_config", {})
	silence_cfg = data.get("silence_config", {})
	roots_cfg = data.get("roots_config", {})
	_mirror_traps = mirror_cfg.get("traps", [])


func _init_variants():
	if "paralysis" in active_variants:
		_paralysis_next_interval = randf_range(
			paralysis_cfg.get("interval_min", 8.0),
			paralysis_cfg.get("interval_max", 15.0))
		_paralysis_timer = 0.0
		_setup_frost_vignette()

	if "silence" in active_variants:
		_silence_next_interval = randf_range(
			silence_cfg.get("min_interval", 20.0),
			silence_cfg.get("min_interval", 20.0) + 10.0)
		_silence_timer = 0.0

	if "roots" in active_variants:
		_setup_roots_canvas()


# =============================================================================
# UI SETUP
# =============================================================================

func _setup_ui():
	if split_screen:
		_setup_split_screen()
	else:
		_setup_fullscreen()


func _setup_fullscreen():
	# Background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)

	# Battle area: 260x110, centered
	var box_pos := Vector2(30, 20)
	var box_size := Vector2(260, 110)
	_setup_battle_area(box_pos, box_size)

	# UI bars at bottom
	_setup_bars(Vector2(30, 140), Vector2(260, 140))

	# Countdown timer
	_setup_countdown(Vector2(260, 6))


func _setup_split_screen():
	# Black background only on bottom half
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color.BLACK
	bg.position = Vector2(0, 88)
	bg.size = Vector2(320, 92)
	add_child(bg)
	move_child(bg, 0)

	# White divider
	var divider = ColorRect.new()
	divider.name = "Divider"
	divider.color = Color.WHITE
	divider.position = Vector2(0, 88)
	divider.size = Vector2(320, 2)
	add_child(divider)

	# Battle area in bottom half: 240x56
	var box_pos := Vector2(40, 94)
	var box_size := Vector2(240, 56)
	_setup_battle_area(box_pos, box_size)

	# UI bars
	_setup_bars(Vector2(40, 156), Vector2(220, 156))

	# Countdown timer
	_setup_countdown(Vector2(250, 90))


func _setup_battle_area(box_pos: Vector2, box_size: Vector2):
	# Battle box with white border
	var box = Panel.new()
	box.name = "BattleBox"
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.02, 0.08)
	style.border_color = Color.WHITE
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	box.add_theme_stylebox_override("panel", style)
	box.position = box_pos
	box.size = box_size
	add_child(box)

	# Inner play area (inside borders)
	battle_area = Rect2(box_pos + Vector2(4, 4), box_size - Vector2(8, 8))

	# Player heart
	player_heart = Sprite2D.new()
	player_heart.name = "PlayerHeart"
	player_heart.texture = load("res://assets/sprites/ui/soul_heart.png")
	player_heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_heart.position = battle_area.get_center()
	add_child(player_heart)


func _setup_bars(hp_pos: Vector2, shield_pos: Vector2):
	# Health label + bar
	health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.text = "VIDA"
	health_label.position = hp_pos
	health_label.add_theme_font_size_override("font_size", 9)
	health_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	add_child(health_label)

	var hp_bar_bg = ColorRect.new()
	hp_bar_bg.position = Vector2(hp_pos.x + 32, hp_pos.y + 2)
	hp_bar_bg.size = Vector2(60, 7)
	hp_bar_bg.color = Color(0.15, 0.15, 0.15)
	add_child(hp_bar_bg)

	health_bar_fill = ColorRect.new()
	health_bar_fill.name = "HealthBarFill"
	health_bar_fill.position = hp_bar_bg.position
	health_bar_fill.size = Vector2(60, 7)
	health_bar_fill.color = Color(0.8, 0.2, 0.2)
	add_child(health_bar_fill)

	# Shield label + bar
	shield_label = Label.new()
	shield_label.name = "ShieldLabel"
	shield_label.text = "ESCUDO"
	shield_label.position = Vector2(shield_pos.x - 42, shield_pos.y)
	shield_label.add_theme_font_size_override("font_size", 9)
	shield_label.add_theme_color_override("font_color", shield_color)
	add_child(shield_label)

	var shield_bar_bg = ColorRect.new()
	shield_bar_bg.position = Vector2(shield_pos.x, shield_pos.y + 2)
	shield_bar_bg.size = Vector2(60, 7)
	shield_bar_bg.color = Color(0.15, 0.15, 0.15)
	add_child(shield_bar_bg)

	shield_bar_fill = ColorRect.new()
	shield_bar_fill.name = "ShieldBarFill"
	shield_bar_fill.position = shield_bar_bg.position
	shield_bar_fill.size = Vector2(0, 7)
	shield_bar_fill.color = shield_color
	add_child(shield_bar_fill)


func _setup_countdown(pos: Vector2):
	# Background box for countdown
	var bg := ColorRect.new()
	bg.name = "CountdownBG"
	bg.color = Color(0, 0, 0, 0.6)
	bg.position = pos - Vector2(2, 1)
	bg.size = Vector2(24, 14)
	add_child(bg)

	countdown_label = Label.new()
	countdown_label.name = "CountdownLabel"
	countdown_label.position = pos
	countdown_label.size = Vector2(20, 14)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 11)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	countdown_label.text = str(int(battle_duration))
	add_child(countdown_label)


func _setup_frost_vignette():
	_frost_vignette = ColorRect.new()
	_frost_vignette.name = "FrostVignette"
	_frost_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_frost_vignette.color = Color(0.3, 0.5, 0.8, 0.0)
	_frost_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frost_vignette)


func _setup_roots_canvas():
	_roots_canvas = Control.new()
	_roots_canvas.name = "RootsCanvas"
	_roots_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_roots_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Connect draw signal
	_roots_canvas.draw.connect(_draw_roots)
	add_child(_roots_canvas)


# =============================================================================
# GAME LOOP
# =============================================================================

func _physics_process(delta):
	if not is_active:
		return

	# Countdown
	_battle_elapsed += delta
	var remaining := battle_duration - _battle_elapsed
	if countdown_label:
		countdown_label.text = str(max(0, ceili(remaining)))
		# Flash red in last 5 seconds
		if remaining <= 5.0:
			countdown_label.add_theme_color_override("font_color",
				Color(1.0, 0.3, 0.3, 0.8) if fmod(remaining, 1.0) > 0.5 else Color(1.0, 0.6, 0.3, 0.8))

	# Time's up
	if remaining <= 0:
		_end_battle(not auto_lose)
		return

	# Player movement (blocked during paralysis)
	if not _is_paralyzed:
		_move_player(delta)

	_update_invincibility(delta)
	_move_and_check_words(delta)

	if not _silence_spawning_paused:
		_spawn_tick(delta)

	_bg_phrase_tick(delta)
	_update_echo_words(delta)

	# Variant ticks
	if "paralysis" in active_variants:
		_paralysis_tick(delta)
	if "silence" in active_variants:
		_silence_tick(delta)
	if "weight" in active_variants:
		_update_weight_visual()

	# Auto-lose (cap 7)
	if auto_lose:
		_auto_lose_elapsed += delta
		if _auto_lose_elapsed >= auto_lose_timer:
			_end_battle(false)


func _move_player(delta):
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_speed := PLAYER_SPEED
	if "weight" in active_variants:
		current_speed *= _speed_multiplier
	player_heart.position += dir * current_speed * delta

	# Clamp to battle area
	player_heart.position.x = clamp(player_heart.position.x,
		battle_area.position.x + HEART_SIZE.x * 0.5,
		battle_area.end.x - HEART_SIZE.x * 0.5)
	player_heart.position.y = clamp(player_heart.position.y,
		battle_area.position.y + HEART_SIZE.y * 0.5,
		battle_area.end.y - HEART_SIZE.y * 0.5)


func _update_invincibility(delta):
	if is_invincible:
		invincibility_timer -= delta
		player_heart.visible = fmod(invincibility_timer, 0.15) > 0.075
		if invincibility_timer <= 0:
			is_invincible = false
			player_heart.visible = true


func _spawn_tick(delta):
	_spawn_timer -= delta
	if _spawn_timer <= 0:
		_spawn_word()
		_spawn_timer = spawn_interval


func _bg_phrase_tick(delta):
	if background_phrases.size() == 0:
		return
	_bg_phrase_timer -= delta
	if _bg_phrase_timer <= 0:
		_spawn_bg_phrase()
		_bg_phrase_timer = randf_range(BG_PHRASE_MIN_INTERVAL, BG_PHRASE_MAX_INTERVAL)


func _spawn_bg_phrase():
	var text: String = background_phrases[randi() % background_phrases.size()]
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.75, 0.65, 0.85))
	label.add_theme_color_override("font_outline_color", Color(0.15, 0.1, 0.2))
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Top of screen (upper classroom area), random Y for variety
	var ypos: float = randf_range(4, 30) if split_screen else randf_range(4, 12)
	label.position = Vector2(60, ypos)
	label.size = Vector2(200, 16)
	add_child(label)
	# Fade in → hold → fade out
	label.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(label, "modulate:a", 1.0, 0.5)
	tw.tween_interval(3.0)
	tw.tween_property(label, "modulate:a", 0.0, 0.8)
	tw.tween_callback(label.queue_free)


func _move_and_check_words(delta):
	var player_rect = Rect2(
		player_heart.position - HEART_SIZE * 0.5,
		HEART_SIZE
	)
	var words_to_remove: Array[Label] = []

	for word in floating_words:
		if not is_instance_valid(word):
			words_to_remove.append(word)
			continue

		var dir: Vector2 = word.get_meta("direction")
		var spd: float = word.get_meta("speed")
		word.position += dir * spd * delta

		# Mirror reveal check
		if "mirror" in active_variants and word.has_meta("is_hidden") and word.get_meta("is_hidden"):
			_mirror_check_reveal(word)

		# Roots: check if shadow touches a root line
		if "roots" in active_variants and not word.get_meta("is_light"):
			if _roots_check_shadow(word):
				_roots_destroy_shadow(word)
				words_to_remove.append(word)
				continue

		# Check if word left the battle area (with margin)
		var word_center = word.position + word.size * 0.5
		if word_center.x < battle_area.position.x - 40 or word_center.x > battle_area.end.x + 40 \
			or word_center.y < battle_area.position.y - 30 or word_center.y > battle_area.end.y + 30:
			word.queue_free()
			words_to_remove.append(word)
			continue

		# Collision with player (use minimum_size as fallback — size may be 0)
		var word_size = word.size if word.size.x > 0 else word.get_combined_minimum_size()
		var word_rect = Rect2(word.position, word_size)
		if player_rect.intersects(word_rect):
			var is_light: bool = word.get_meta("is_light")
			# Mirror: if still hidden, force reveal first
			if word.has_meta("is_hidden") and word.get_meta("is_hidden"):
				_mirror_reveal_word(word)
				is_light = word.get_meta("is_light")
			_on_word_touched(word, is_light)
			words_to_remove.append(word)

	for w in words_to_remove:
		floating_words.erase(w)


# =============================================================================
# WORD SPAWNING
# =============================================================================

func _spawn_word():
	# Check for mirror traps
	var is_trap := false
	var trap_data: Dictionary = {}
	if "mirror" in active_variants and _mirror_traps.size() > 0:
		if randf() < 0.15:  # 15% chance to spawn a trap word
			trap_data = _mirror_traps[randi() % _mirror_traps.size()]
			is_trap = true

	var is_light: bool
	var text: String

	if is_trap:
		text = trap_data.get("text", "???")
		is_light = false  # Traps are always shadow
	else:
		is_light = randf() < light_ratio
		var word_list: Array = light_words if is_light else shadow_words
		if word_list.size() == 0:
			return
		text = word_list[randi() % word_list.size()]

	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", _get_word_font_size(is_light))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Mirror: hide some words
	var should_hide := false
	if "mirror" in active_variants:
		var hidden_ratio: float = mirror_cfg.get("hidden_ratio", 0.3)
		if is_trap or randf() < hidden_ratio:
			should_hide = true

	if should_hide:
		label.add_theme_color_override("font_color", HIDDEN_COLOR)
		label.text = _obscure_text(text)
		label.set_meta("is_hidden", true)
		label.set_meta("real_text", text)
		label.set_meta("is_trap", is_trap)
	else:
		label.add_theme_color_override("font_color", _get_word_color(is_light))
		label.set_meta("is_hidden", false)
		label.set_meta("is_trap", false)

	# Need to add to tree first so size is calculated
	add_child(label)
	await get_tree().process_frame
	# Force label size to match text content
	label.size = label.get_combined_minimum_size()

	# Position from random edge
	var start_pos: Vector2
	var direction: Vector2
	var side = randi() % 4
	match side:
		0: # Top
			start_pos = Vector2(
				randf_range(battle_area.position.x, battle_area.end.x - label.size.x),
				battle_area.position.y - label.size.y)
			direction = Vector2(randf_range(-0.3, 0.3), 1).normalized()
		1: # Bottom
			start_pos = Vector2(
				randf_range(battle_area.position.x, battle_area.end.x - label.size.x),
				battle_area.end.y)
			direction = Vector2(randf_range(-0.3, 0.3), -1).normalized()
		2: # Left
			start_pos = Vector2(
				battle_area.position.x - label.size.x,
				randf_range(battle_area.position.y, battle_area.end.y - label.size.y))
			direction = Vector2(1, randf_range(-0.3, 0.3)).normalized()
		3: # Right
			start_pos = Vector2(
				battle_area.end.x,
				randf_range(battle_area.position.y, battle_area.end.y - label.size.y))
			direction = Vector2(-1, randf_range(-0.3, 0.3)).normalized()

	label.position = start_pos
	label.set_meta("direction", direction)
	label.set_meta("speed", base_speed * randf_range(0.8, 1.2))
	label.set_meta("is_light", is_light)
	label.add_to_group("floating_words")
	floating_words.append(label)

	# Visual effects per chapter
	if not should_hide:
		_apply_word_style(label, is_light)

	# Cap 8: shadow words fade away on their own
	if shadow_fade and not is_light:
		var tw = create_tween()
		tw.tween_property(label, "modulate:a", 0.0, shadow_fade_time)
		tw.tween_callback(func():
			if is_instance_valid(label):
				floating_words.erase(label)
				label.queue_free()
		)


func _get_word_font_size(is_light: bool) -> int:
	if is_light:
		return 10
	# Shadow words get bigger in later chapters
	if chapter >= 5:
		return 11
	return 10


func _get_word_color(is_light: bool) -> Color:
	if is_light:
		return LIGHT_COLORS.get(chapter, Color(1.0, 0.95, 0.6))
	return SHADOW_COLOR


func _apply_word_style(label: Label, is_light: bool):
	if is_light:
		# Glow effect for early chapters
		if chapter <= 2 and shield_glow:
			label.modulate = label.modulate.lightened(0.2)
		# Flicker for chapters 5-6
		elif chapter in [5, 6]:
			var tw = create_tween().set_loops()
			tw.tween_property(label, "modulate:a", 0.4, 0.3)
			tw.tween_property(label, "modulate:a", 1.0, 0.3)
		# Glitch for chapter 7
		elif chapter == 7:
			label.position.x += randf_range(-2, 2)
			label.rotation = deg_to_rad(randf_range(-5, 5))


# =============================================================================
# WORD COLLISION
# =============================================================================

func _on_word_touched(word: Label, is_light: bool):
	var text: String = word.get_meta("real_text") if word.has_meta("real_text") else word.text

	if is_light:
		# Collect light word
		shield_power += 100.0 / required_light_words
		shield_power = min(shield_power, 100.0)
		collected_words.append(text)
		_update_shield_display()
		AudioManager.play_sfx("sfx_pong_hit_player")

		# Cap 7: light words also hurt
		if light_damage > 0:
			health -= light_damage
			_flash_player_hurt()

		# Weight: recover speed
		if "weight" in active_variants:
			_weight_collect_light()

		# Roots: mark position
		if "roots" in active_variants:
			_roots_on_light_collected(word.position + word.size * 0.5)

		word.queue_free()

		# Victory check
		if shield_power >= 100.0:
			_end_battle(true)
			return
	else:
		# Shadow damage
		if is_invincible:
			word.queue_free()
			return

		var damage := 15.0
		# Paralysis: reduced damage while frozen
		if _is_paralyzed and "paralysis" in active_variants:
			var reduction: float = paralysis_cfg.get("damage_reduction_while_frozen", 0.5)
			damage *= reduction

		if shield_power > 0:
			var shield_absorb: float = min(shield_power, damage)
			shield_power -= shield_absorb
			damage -= shield_absorb
			_update_shield_display()
		if damage > 0:
			health -= damage
		_flash_player_hurt()
		is_invincible = true
		invincibility_timer = INVINCIBILITY_DURATION
		AudioManager.play_sfx("sfx_wall_damage")

		# Echo: create orbiting echo
		if "echo" in active_variants:
			_echo_create(text, word.position)

		# Weight: slow down
		if "weight" in active_variants:
			_weight_take_hit()

		word.queue_free()

	_update_health_display()

	# Defeat check
	if health <= 0:
		_end_battle(false)


func _flash_player_hurt():
	player_heart.modulate = Color.RED
	var tw = create_tween()
	tw.tween_property(player_heart, "modulate", Color.WHITE, 0.2)


# =============================================================================
# VARIANT: PARALYSIS
# =============================================================================

func _paralysis_tick(delta):
	if _is_paralyzed:
		return
	var max_p: int = paralysis_cfg.get("max_paralyses", 3)
	if _paralysis_count >= max_p:
		return

	_paralysis_timer += delta
	if _paralysis_timer >= _paralysis_next_interval:
		_trigger_paralysis()


func _trigger_paralysis():
	_paralysis_count += 1
	_is_paralyzed = true

	# Frost vignette flash
	if _frost_vignette:
		var tw_frost := create_tween()
		tw_frost.tween_property(_frost_vignette, "color:a", 0.35, 0.15)
		tw_frost.tween_property(_frost_vignette, "color:a", 0.2, 0.15)

	# Heart trembles
	_start_heart_tremble()

	# Show "Parálisis" status label on the right
	var status_label := Label.new()
	status_label.name = "ParalysisStatus"
	status_label.text = "Parálisis"
	status_label.add_theme_font_size_override("font_size", 9)
	status_label.add_theme_color_override("font_color", Color(0.4, 0.6, 0.9, 0.0))
	status_label.position = Vector2(battle_area.end.x + 6, battle_area.get_center().y - 5)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status_label)
	var tw_status := create_tween()
	tw_status.tween_property(status_label, "theme_override_colors/font_color:a", 1.0, 0.15)

	# Show background phrase "El miedo me paraliza"
	_spawn_paralysis_phrase()

	AudioManager.play_sfx("sfx_wall_damage")

	# Duration
	var dur := randf_range(
		paralysis_cfg.get("paralysis_duration_min", 1.0),
		paralysis_cfg.get("paralysis_duration_max", 1.5))

	await get_tree().create_timer(dur).timeout

	# Unfreeze
	_is_paralyzed = false
	_stop_heart_tremble()

	# Fade out and remove status label
	if is_instance_valid(status_label):
		var tw_fade := create_tween()
		tw_fade.tween_property(status_label, "theme_override_colors/font_color:a", 0.0, 0.3)
		tw_fade.tween_callback(status_label.queue_free)

	# Warm flash
	if _frost_vignette:
		_frost_vignette.color = Color(1.0, 0.9, 0.5, 0.3)
		var tw_thaw := create_tween()
		tw_thaw.tween_property(_frost_vignette, "color:a", 0.0, 0.25)

	# Golden flash on heart
	player_heart.modulate = Color(1.0, 0.9, 0.5)
	var tw_heart := create_tween()
	tw_heart.tween_property(player_heart, "modulate", Color.WHITE, 0.2)

	# Reset timer for next paralysis
	_paralysis_timer = 0.0
	_paralysis_next_interval = randf_range(
		paralysis_cfg.get("interval_min", 8.0),
		paralysis_cfg.get("interval_max", 15.0))


var _tremble_tween: Tween
var _heart_original_pos: Vector2
var _tremble_active: bool = false

func _start_heart_tremble():
	_heart_original_pos = player_heart.position
	_tremble_active = true
	_tremble_tween = create_tween().set_loops()
	_tremble_tween.tween_property(player_heart, "position",
		_heart_original_pos + Vector2(1, 0), 0.05)
	_tremble_tween.tween_property(player_heart, "position",
		_heart_original_pos + Vector2(-1, 0), 0.05)
	_tremble_tween.tween_property(player_heart, "position",
		_heart_original_pos + Vector2(0, 1), 0.05)
	_tremble_tween.tween_property(player_heart, "position",
		_heart_original_pos + Vector2(0, -1), 0.05)


func _stop_heart_tremble():
	if _tremble_tween and _tremble_tween.is_valid():
		_tremble_tween.kill()
	if _tremble_active and player_heart:
		player_heart.position = _heart_original_pos
	_tremble_active = false


func _spawn_paralysis_phrase():
	# Red background strip with white text, centered in the upper half of the screen
	var strip_w: float = 180.0
	var strip_h: float = 16.0
	var strip_x: float = (320.0 - strip_w) * 0.5
	# In split screen, upper half is y 0-88; in fullscreen, above battle area
	var strip_y: float = 36.0 if split_screen else 6.0

	var container := Control.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.position = Vector2(strip_x, strip_y)
	container.size = Vector2(strip_w, strip_h)
	add_child(container)

	var bg := ColorRect.new()
	bg.color = Color(0.75, 0.1, 0.1, 0.85)
	bg.position = Vector2.ZERO
	bg.size = Vector2(strip_w, strip_h)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(bg)

	var label := Label.new()
	label.text = "El miedo me paraliza"
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2.ZERO
	label.size = Vector2(strip_w, strip_h)
	container.add_child(label)

	container.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(container, "modulate:a", 1.0, 0.2)
	tw.tween_interval(2.0)
	tw.tween_property(container, "modulate:a", 0.0, 0.6)
	tw.tween_callback(container.queue_free)


# =============================================================================
# VARIANT: ECHO
# =============================================================================

func _echo_create(text: String, origin_pos: Vector2):
	var max_echoes: int = echo_cfg.get("max_echoes", 3)
	# Remove oldest if at max
	while _echo_words.size() >= max_echoes:
		var oldest = _echo_words[0]
		if is_instance_valid(oldest):
			oldest.queue_free()
		_echo_words.remove_at(0)

	var echo_label := Label.new()
	echo_label.text = text
	echo_label.add_theme_font_size_override("font_size", 9)
	echo_label.add_theme_color_override("font_color", Color(0.7, 0.15, 0.15, 0.7))
	echo_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	echo_label.position = origin_pos

	var radius_min: float = echo_cfg.get("orbit_radius_min", 15)
	var radius_max: float = echo_cfg.get("orbit_radius_max", 25)
	echo_label.set_meta("orbit_angle", randf() * TAU)
	echo_label.set_meta("orbit_radius", randf_range(radius_min, radius_max))
	echo_label.set_meta("orbit_speed", randf_range(2.0, 3.5))
	echo_label.set_meta("echo_lifetime", echo_cfg.get("orbit_duration", 5.0))
	echo_label.set_meta("echo_elapsed", 0.0)

	add_child(echo_label)
	_echo_words.append(echo_label)


func _update_echo_words(delta):
	if "echo" not in active_variants:
		return

	var to_remove: Array[Label] = []
	for echo in _echo_words:
		if not is_instance_valid(echo):
			to_remove.append(echo)
			continue

		var elapsed: float = echo.get_meta("echo_elapsed") + delta
		echo.set_meta("echo_elapsed", elapsed)
		var lifetime: float = echo.get_meta("echo_lifetime")

		# Fade out near end
		if elapsed >= lifetime - 1.5:
			echo.modulate.a = max(0.0, (lifetime - elapsed) / 1.5)
		if elapsed >= lifetime:
			echo.queue_free()
			to_remove.append(echo)
			continue

		# Orbit around player heart
		var angle: float = echo.get_meta("orbit_angle") + echo.get_meta("orbit_speed") * delta
		echo.set_meta("orbit_angle", angle)
		var radius: float = echo.get_meta("orbit_radius")
		echo.position = player_heart.position + Vector2(
			cos(angle) * radius,
			sin(angle) * radius
		)

	for e in to_remove:
		_echo_words.erase(e)


# =============================================================================
# VARIANT: MIRROR
# =============================================================================

func _mirror_check_reveal(word: Label):
	if not player_heart:
		return
	var word_center := word.position + word.size * 0.5
	var dist := word_center.distance_to(player_heart.position)
	var reveal_dist: float = mirror_cfg.get("reveal_distance", 25)

	if dist < reveal_dist:
		_mirror_reveal_word(word)
	elif dist < reveal_dist * 1.5:
		# Partially visible — interpolate alpha
		var alpha := remap(dist, reveal_dist, reveal_dist * 1.5, 0.9, 0.3)
		word.modulate.a = alpha
		# Partially reveal text
		var real_text: String = word.get_meta("real_text")
		var ratio := remap(dist, reveal_dist, reveal_dist * 1.5, 0.2, 0.8)
		word.text = _obscure_text(real_text, ratio)


func _mirror_reveal_word(word: Label):
	word.set_meta("is_hidden", false)
	var real_text: String = word.get_meta("real_text")
	word.text = real_text
	word.modulate.a = 1.0
	word.size = word.get_combined_minimum_size()

	var is_light: bool = word.get_meta("is_light")
	var is_trap: bool = word.get_meta("is_trap") if word.has_meta("is_trap") else false

	if is_trap:
		# It looked like light but is actually shadow!
		word.set_meta("is_light", false)
		word.add_theme_color_override("font_color", Color(0.7, 0.15, 0.15))
	else:
		word.add_theme_color_override("font_color", _get_word_color(is_light))
		_apply_word_style(word, is_light)


func _obscure_text(text: String, ratio: float = 0.8) -> String:
	var result := ""
	var chars := ["?", "_", "."]
	for c in text:
		if c == " ":
			result += " "
		elif randf() < ratio:
			result += chars[randi() % chars.size()]
		else:
			result += c
	return result


# =============================================================================
# VARIANT: WEIGHT
# =============================================================================

func _weight_take_hit():
	var loss: float = weight_cfg.get("speed_loss_per_hit", 0.10)
	var min_spd: float = weight_cfg.get("min_speed_multiplier", 0.30)
	_speed_multiplier = max(min_spd, _speed_multiplier - loss)


func _weight_collect_light():
	var gain: float = weight_cfg.get("speed_gain_per_light", 0.15)
	_speed_multiplier = min(1.0, _speed_multiplier + gain)

	# Flash relief if below 50%
	if _speed_multiplier < 0.5:
		player_heart.modulate = Color(1.0, 0.9, 0.5)
		var tw := create_tween()
		tw.tween_property(player_heart, "modulate", Color.WHITE, 0.3)


func _update_weight_visual():
	if not player_heart:
		return
	# Scale: 1.0 at full speed, 0.7 at minimum
	var s := remap(_speed_multiplier,
		weight_cfg.get("min_speed_multiplier", 0.30), 1.0, 0.7, 1.0)
	player_heart.scale = Vector2(s, s)
	# Darken at low speed
	var brightness := remap(_speed_multiplier,
		weight_cfg.get("min_speed_multiplier", 0.30), 1.0, 0.4, 1.0)
	if not is_invincible and not _is_paralyzed:
		player_heart.modulate = Color(brightness, brightness, brightness)


# =============================================================================
# VARIANT: SILENCE
# =============================================================================

func _silence_tick(delta):
	if _is_silence:
		return
	var max_silences: int = silence_cfg.get("silence_count", 2)
	if _silence_count_done >= max_silences:
		return

	_silence_timer += delta
	if _silence_timer >= _silence_next_interval:
		_trigger_silence()


func _trigger_silence():
	_silence_count_done += 1
	_is_silence = true
	_silence_spawning_paused = true

	# 1. Slow and fade all current words
	for word in floating_words:
		if is_instance_valid(word):
			word.set_meta("speed", 0.0)
			var tw := create_tween()
			tw.tween_property(word, "modulate:a", 0.0, 0.8)
			tw.tween_callback(func():
				if is_instance_valid(word):
					floating_words.erase(word)
					word.queue_free()
			)

	# 2. Lower music volume (using AudioManager)
	# AudioManager handles music internally, so we dim the music bus
	var music_bus_idx := AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		var tw_music := create_tween()
		tw_music.tween_method(func(v): AudioServer.set_bus_volume_db(music_bus_idx, v),
			AudioServer.get_bus_volume_db(music_bus_idx), -30.0, 1.0)

	# 3. Show "TeNgO MiEdO" text letter by letter
	var fear_text: String = silence_cfg.get("fear_text", "TeNgO MiEdO")
	_fear_label = Label.new()
	_fear_label.name = "FearLabel"
	_fear_label.text = ""
	_fear_label.add_theme_font_size_override("font_size", 14)
	_fear_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 0.0))
	_fear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_fear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_fear_label.position = Vector2(battle_area.position.x, battle_area.get_center().y - 8)
	_fear_label.size = Vector2(battle_area.size.x, 16)
	_fear_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fear_label)

	# Wait a moment then start revealing text
	var silence_dur: float = silence_cfg.get("silence_duration", 4.0)
	await get_tree().create_timer(0.5).timeout

	# Letter by letter reveal
	var time_per_letter: float = (silence_dur - 1.5) / max(fear_text.length(), 1)
	for i in range(fear_text.length()):
		if not is_active:
			return
		_fear_label.text = fear_text.substr(0, i + 1)
		_fear_label.add_theme_color_override("font_color",
			Color(0.8, 0.2, 0.2, min(1.0, 0.3 + float(i) / fear_text.length() * 0.7)))
		await get_tree().create_timer(time_per_letter).timeout

	# 4. Heartbeat
	AudioManager.play_sfx("sfx_wall_warning")
	await get_tree().create_timer(0.8).timeout

	# 5. Fade out fear text
	if is_instance_valid(_fear_label):
		var tw_fear := create_tween()
		tw_fear.tween_property(_fear_label, "modulate:a", 0.0, 0.3)
		tw_fear.tween_callback(_fear_label.queue_free)

	# 6. Restore music volume
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, 0.0)

	# 7. BOMBARDMENT
	var bombardment_count: int = silence_cfg.get("bombardment_word_count", 15)
	_silence_spawning_paused = false
	for i in range(bombardment_count):
		_spawn_word()

	# Wait for bombardment to pass
	await get_tree().create_timer(2.0).timeout

	_is_silence = false

	# Reset timer for next silence
	_silence_timer = 0.0
	_silence_next_interval = randf_range(
		silence_cfg.get("min_interval", 20.0),
		silence_cfg.get("min_interval", 20.0) + 10.0)


# =============================================================================
# VARIANT: ROOTS
# =============================================================================

func _roots_on_light_collected(pos: Vector2):
	_root_positions.append(pos)

	# Connect to nearest existing marks
	var conn_count: int = roots_cfg.get("connection_count", 2)
	if _root_positions.size() <= 1:
		if _roots_canvas:
			_roots_canvas.queue_redraw()
		return

	var sorted := _root_positions.duplicate()
	sorted.sort_custom(func(a, b): return a.distance_to(pos) < b.distance_to(pos))

	for i in range(min(conn_count, sorted.size() - 1)):
		var target_pos: Vector2 = sorted[i + 1]  # Skip self (index 0)
		_root_lines.append({"from": pos, "to": target_pos})

	if _roots_canvas:
		_roots_canvas.queue_redraw()


func _roots_check_shadow(word: Label) -> bool:
	if _root_lines.size() == 0:
		return false
	var word_center := word.position + word.size * 0.5
	var destroy_radius: float = roots_cfg.get("root_destroy_radius", 8.0)

	for line in _root_lines:
		var dist := _point_to_line_dist(word_center, line["from"], line["to"])
		if dist < destroy_radius:
			return true
	return false


func _roots_destroy_shadow(word: Label):
	# Visual: flash white and fade
	word.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	var tw := create_tween()
	tw.tween_property(word, "modulate:a", 0.0, 0.3)
	tw.tween_callback(word.queue_free)
	AudioManager.play_sfx("sfx_pong_hit_player")


func _point_to_line_dist(point: Vector2, line_a: Vector2, line_b: Vector2) -> float:
	var ab := line_b - line_a
	var ap := point - line_a
	var t: float = clamp(ap.dot(ab) / ab.length_squared(), 0.0, 1.0)
	var closest: Vector2 = line_a + ab * t
	return point.distance_to(closest)


func _draw_roots():
	if not _roots_canvas:
		return
	var color_str: String = roots_cfg.get("root_color", "#FFE880")
	var root_color := Color(color_str)
	root_color.a = 0.6
	for line in _root_lines:
		_roots_canvas.draw_line(line["from"], line["to"], root_color, 2.0)
	# Draw marks
	var mark_color := Color(color_str)
	mark_color.a = 0.8
	for pos in _root_positions:
		_roots_canvas.draw_circle(pos, 3.0, mark_color)


# =============================================================================
# UI UPDATES
# =============================================================================

func _update_health_display():
	if health_bar_fill:
		health_bar_fill.size.x = 60.0 * max(health / 100.0, 0.0)


func _update_shield_display():
	if shield_bar_fill:
		shield_bar_fill.size.x = 60.0 * (shield_power / 100.0)
	if shield_label:
		shield_label.add_theme_color_override("font_color", shield_color)


# =============================================================================
# END BATTLE
# =============================================================================

func _end_battle(won: bool):
	is_active = false

	# Clear floating words
	for word in floating_words:
		if is_instance_valid(word):
			word.queue_free()
	floating_words.clear()

	# Clear echo words
	for echo in _echo_words:
		if is_instance_valid(echo):
			echo.queue_free()
	_echo_words.clear()

	# Clear fear label if still visible
	if _fear_label and is_instance_valid(_fear_label):
		_fear_label.queue_free()

	# Restore music volume if silence was active
	var music_bus_idx := AudioServer.get_bus_index("Music")
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, 0.0)

	# Reset weight visual
	if player_heart:
		player_heart.scale = Vector2.ONE
		player_heart.modulate = Color.WHITE

	# Stop paralysis tremble
	_stop_heart_tremble()
	_is_paralyzed = false

	# Hide and unpause
	visible = false
	modulate.a = 0.0
	for child in get_children():
		child.queue_free()
	get_tree().paused = false

	if won:
		emit_signal("combat_won")
	else:
		emit_signal("combat_lost")
