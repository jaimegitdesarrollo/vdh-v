extends Control
## WordShield — Sistema de combate "Escudo de Palabras".
## Cristian recoge Palabras Luz para formar un escudo y esquiva Palabras Sombra.
## Configurable por capítulo vía JSON en data/word_shield/.

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

# --- Game state ---
var health: float = 100.0
var shield_power: float = 0.0
var collected_words: Array[String] = []
var is_active: bool = false
var _spawn_timer: float = 0.0
var _auto_lose_elapsed: float = 0.0
var _bg_phrase_timer: float = 0.0
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
	_spawn_timer = 0.0
	_auto_lose_elapsed = 0.0
	_bg_phrase_timer = randf_range(BG_PHRASE_MIN_INTERVAL, BG_PHRASE_MAX_INTERVAL)
	is_invincible = false
	visible = true
	get_tree().paused = true
	_setup_ui()
	is_active = true


func _load_chapter(ch: int):
	var path := "res://data/word_shield/chapter_%d.json" % ch
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("WordShield: no config for chapter %d" % ch)
		return
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
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



# =============================================================================
# GAME LOOP
# =============================================================================

func _physics_process(delta):
	if not is_active:
		return

	_move_player(delta)
	_update_invincibility(delta)
	_move_and_check_words(delta)
	_spawn_tick(delta)
	_bg_phrase_tick(delta)

	if auto_lose:
		_auto_lose_elapsed += delta
		if _auto_lose_elapsed >= auto_lose_timer:
			_end_battle(false)


func _move_player(delta):
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player_heart.position += dir * PLAYER_SPEED * delta

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
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.55, 0.5, 0.65))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Top of screen, centered horizontally
	label.position = Vector2(80, 4)
	label.size = Vector2(160, 12)
	add_child(label)
	# Fade in → hold → fade out
	label.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(label, "modulate:a", 1.0, 0.8)
	tw.tween_interval(2.5)
	tw.tween_property(label, "modulate:a", 0.0, 1.0)
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
			_on_word_touched(word, is_light)
			words_to_remove.append(word)

	for w in words_to_remove:
		floating_words.erase(w)


# =============================================================================
# WORD SPAWNING
# =============================================================================

func _spawn_word():
	var is_light := randf() < light_ratio
	var word_list: Array = light_words if is_light else shadow_words
	if word_list.size() == 0:
		return
	var text: String = word_list[randi() % word_list.size()]

	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", _get_word_font_size(is_light))
	label.add_theme_color_override("font_color", _get_word_color(is_light))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Need to add to tree first so size is calculated
	add_child(label)
	await get_tree().process_frame
	# Force label size to match text content (non-Container children keep size=0)
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
		# Glow effect for early chapters (bright outline via duplicate)
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
	var text: String = word.text
	word.queue_free()

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

		# Victory check
		if shield_power >= 100.0:
			_end_battle(true)
			return
	else:
		# Shadow damage: first drains shield, then health
		if is_invincible:
			return
		var damage := 15.0
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

	_update_health_display()

	# Defeat check
	if health <= 0:
		_end_battle(false)


func _flash_player_hurt():
	player_heart.modulate = Color.RED
	var tw = create_tween()
	tw.tween_property(player_heart, "modulate", Color.WHITE, 0.2)



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
