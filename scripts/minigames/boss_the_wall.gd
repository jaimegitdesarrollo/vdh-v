extends Node2D
## BossTheWall — Boss del Cap 1: muro de ladrillos con 10 tiles + demonio 64x64.
## Mecánica Arkanoid: lanza pelota contra el muro para destruirlo.
## Tiles: Normal(3HP), Dañado, Crítico, Reforzado(5HP), ReforzadoDañado,
##        Indestructible, Ojo(4HP), GrietaLuz, BordeSuperior, BordeInferior.

signal boss_defeated

# Texturas
var paddle_texture: Texture2D = preload("res://assets/sprites/minigames/paddle.png")
var ball_texture: Texture2D = preload("res://assets/sprites/minigames/ball.png")
var tileset_strip: Texture2D = preload("res://assets/sprites/bosses/the_wall/thewall_tileset_strip.png")
var demon_texture: Texture2D = preload("res://assets/sprites/bosses/the_wall/thewall_demon_64x64.png")

# Tile indices in the strip (160x16, 10 tiles of 16x16)
enum Tile { NORMAL, DAMAGED, CRITICAL, REINFORCED, REINFORCED_DMG, INDESTRUCTIBLE, EYE, LIGHT, BORDER_TOP, BORDER_BOTTOM }

# Tamaños de referencia para colisiones
const PADDLE_SIZE := Vector2(32, 8)
const BALL_SIZE := Vector2(8, 8)
const BRICK_SIZE := Vector2(16, 16)
const WALL_COLS: int = 10
const WALL_ROWS: int = 8

# Brick data: {node: Sprite2D, hp: int, type: String, max_hp: int, row: int, col: int}
var bricks: Array[Dictionary] = []
var ball: Sprite2D
var ball_direction: Vector2 = Vector2(1, -0.5).normalized()
var ball_speed: float = 110.0
var paddle: Sprite2D
var paddle_speed: float = 220.0
var wall_container: Node2D
var demon_sprite: Sprite2D
var current_phase: int = 1
var mm_lives: int = 10
var is_active: bool = false
var shoot_timer: float = 0.0
var _critical_pulse_time: float = 0.0
var score: int = 0
var boss_hp_bar: ColorRect
var boss_hp_bar_bg: ColorRect
const BOSS_HP_BAR_WIDTH: float = 50.0

# Magic Man texture (set by parent before add_child)
var magic_man_texture: Texture2D
var magic_man_sprite: Sprite2D

# Wall layout per phase — 2D arrays of Tile enum values (-1 = empty/light)
# Layout: 5 rows × 10 cols — compact wall leaves ~73px play area
var wall_layout_phase1: Array = [
	[8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
	[0, 0, 3, 0, 5, 5, 0, 3, 0, 0],
	[0, 3, 0, 6, 0, 0, 6, 0, 3, 0],
	[0, 0, 0, 0, 3, 3, 0, 0, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
]

# Atlas textures cache (one per tile index)
var _tile_textures: Array[AtlasTexture] = []


func _ready():
	_build_tile_textures()
	_setup_boss()
	is_active = true


func _build_tile_textures():
	_tile_textures.clear()
	for i in range(10):
		var atlas = AtlasTexture.new()
		atlas.atlas = tileset_strip
		atlas.region = Rect2(i * 16, 0, 16, 16)
		atlas.filter_clip = true
		_tile_textures.append(atlas)


func _get_tile_texture(tile_id: int) -> AtlasTexture:
	if tile_id >= 0 and tile_id < _tile_textures.size():
		return _tile_textures[tile_id]
	return _tile_textures[Tile.NORMAL]


# =============================================================================
# SETUP
# =============================================================================

func _setup_boss():
	# Fondo
	var bg = ColorRect.new()
	bg.size = Vector2(320, 180)
	bg.color = Color(0.05, 0.0, 0.1, 1.0)
	add_child(bg)

	# Paddle de Magic Man (abajo — lowered so wall/demon are visible)
	paddle = Sprite2D.new()
	paddle.name = "Paddle"
	paddle.texture = paddle_texture
	paddle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paddle.centered = true
	paddle.rotation = deg_to_rad(90)
	paddle.position = Vector2(160, 174)
	add_child(paddle)

	# Magic Man sprite sobre la paleta
	if magic_man_texture:
		magic_man_sprite = Sprite2D.new()
		magic_man_sprite.name = "MagicManSprite"
		magic_man_sprite.texture = magic_man_texture
		magic_man_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		magic_man_sprite.centered = true
		magic_man_sprite.scale = Vector2(0.5, 0.5)
		magic_man_sprite.position = Vector2(paddle.position.x, paddle.position.y - 12)
		add_child(magic_man_sprite)

	# Muro de ladrillos — centrado: 10 cols × 16px = 160px, offset = (320-160)/2 = 80
	wall_container = Node2D.new()
	wall_container.name = "WallContainer"
	wall_container.position = Vector2(80, 16)
	add_child(wall_container)
	_generate_wall(wall_layout_phase1)

	# Demonio — centrado, visible completo, base se fusiona con las filas superiores del muro
	demon_sprite = Sprite2D.new()
	demon_sprite.name = "DemonSprite"
	demon_sprite.texture = demon_texture
	demon_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	demon_sprite.centered = true
	# 64x64 sprite: y=32 → visible from y=0 to y=64, overlaps top rows of wall
	demon_sprite.position = Vector2(160, 32)
	demon_sprite.z_index = 1
	add_child(demon_sprite)

	# Pelota
	ball = Sprite2D.new()
	ball.name = "Ball"
	ball.texture = ball_texture
	ball.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ball.centered = false
	ball.position = Vector2(156, 164)
	add_child(ball)

	# Lives display
	var lives_label = Label.new()
	lives_label.name = "LivesLabel"
	lives_label.position = Vector2(4, 4)
	lives_label.add_theme_font_size_override("font_size", 11)
	lives_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	add_child(lives_label)
	_update_lives_display()

	# Score display
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(130, 4)
	score_label.add_theme_font_size_override("font_size", 11)
	score_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.5))
	add_child(score_label)
	_update_score_display()

	# Boss name
	var name_label = Label.new()
	name_label.text = "THE WALL"
	name_label.position = Vector2(248, 2)
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
	add_child(name_label)

	# Boss HP bar (below name)
	boss_hp_bar_bg = ColorRect.new()
	boss_hp_bar_bg.position = Vector2(248, 13)
	boss_hp_bar_bg.size = Vector2(BOSS_HP_BAR_WIDTH, 4)
	boss_hp_bar_bg.color = Color(0.15, 0.05, 0.05)
	add_child(boss_hp_bar_bg)

	boss_hp_bar = ColorRect.new()
	boss_hp_bar.name = "BossHPBar"
	boss_hp_bar.position = Vector2(248, 13)
	boss_hp_bar.size = Vector2(BOSS_HP_BAR_WIDTH, 4)
	boss_hp_bar.color = Color(0.8, 0.15, 0.15)
	add_child(boss_hp_bar)
	_update_boss_hp_bar()


# =============================================================================
# WALL GENERATION
# =============================================================================

func _generate_wall(layout: Array):
	bricks.clear()
	for child in wall_container.get_children():
		child.queue_free()

	for row in range(layout.size()):
		var row_data: Array = layout[row]
		for col in range(row_data.size()):
			var tile_id: int = row_data[col]
			if tile_id < 0:
				continue  # Empty

			var brick = Sprite2D.new()
			brick.texture = _get_tile_texture(tile_id)
			brick.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			brick.centered = false
			brick.position = Vector2(col * 16, row * 16)
			wall_container.add_child(brick)

			var hp: int = _get_tile_hp(tile_id)
			var type: String = _get_tile_type(tile_id)

			bricks.append({
				"node": brick,
				"hp": hp,
				"max_hp": hp,
				"type": type,
				"tile_id": tile_id,
				"row": row,
				"col": col,
			})


func _get_tile_hp(tile_id: int) -> int:
	match tile_id:
		Tile.NORMAL: return 1
		Tile.DAMAGED: return 1
		Tile.CRITICAL: return 1
		Tile.REINFORCED: return 3
		Tile.REINFORCED_DMG: return 2
		Tile.INDESTRUCTIBLE: return -1  # Infinite
		Tile.EYE: return 2
		Tile.BORDER_TOP, Tile.BORDER_BOTTOM: return -1  # Decorative/indestructible
		_: return 0  # Light, etc. — not hittable


func _get_tile_type(tile_id: int) -> String:
	match tile_id:
		Tile.NORMAL, Tile.DAMAGED, Tile.CRITICAL: return "normal"
		Tile.REINFORCED, Tile.REINFORCED_DMG: return "reinforced"
		Tile.INDESTRUCTIBLE: return "indestructible"
		Tile.EYE: return "eye"
		Tile.LIGHT: return "light"
		Tile.BORDER_TOP, Tile.BORDER_BOTTOM: return "border"
		_: return "unknown"


# =============================================================================
# GAME LOOP
# =============================================================================

func _physics_process(delta):
	# Always allow paddle movement (even during countdown)
	_move_paddle(delta)

	if not is_active:
		return

	_move_ball(delta)
	_check_wall_collision()
	_pulse_critical_bricks(delta)
	_update_eye_tracking()

	# Fase 3+: disparar proyectiles desde ojos
	if current_phase >= 3:
		shoot_timer -= delta
		if shoot_timer <= 0:
			_shoot_projectile()
			shoot_timer = 2.5


func _get_paddle_rect() -> Rect2:
	return Rect2(paddle.position.x - PADDLE_SIZE.x * 0.5,
		paddle.position.y - PADDLE_SIZE.y * 0.5, PADDLE_SIZE.x, PADDLE_SIZE.y)


func _move_paddle(delta):
	var dir = Input.get_axis("move_left", "move_right")
	paddle.position.x += dir * paddle_speed * delta
	paddle.position.x = clamp(paddle.position.x, PADDLE_SIZE.x * 0.5, 320 - PADDLE_SIZE.x * 0.5)
	if magic_man_sprite:
		magic_man_sprite.position = Vector2(paddle.position.x, paddle.position.y - 12)


func _move_ball(delta):
	var speed_mult := 1.0
	if current_phase >= 2:
		speed_mult = 1.1
	if current_phase >= 3:
		speed_mult = 1.2

	ball.position += ball_direction * ball_speed * speed_mult * delta

	# Rebote paredes laterales
	if ball.position.x <= 0 or ball.position.x >= 320 - BALL_SIZE.x:
		ball_direction.x = -ball_direction.x
		AudioManager.play_sfx("sfx_pong_wall_bounce")

	# Rebote techo
	if ball.position.y <= 0:
		ball_direction.y = abs(ball_direction.y)
		AudioManager.play_sfx("sfx_pong_wall_bounce")

	# Rebote paddle
	var ball_rect = Rect2(ball.position, BALL_SIZE)
	var paddle_rect = _get_paddle_rect()
	if ball_rect.intersects(paddle_rect) and ball_direction.y > 0:
		ball_direction.y = -abs(ball_direction.y)
		var paddle_center_x = paddle.position.x
		var ball_center = ball.position.x + BALL_SIZE.x * 0.5
		ball_direction.x = (ball_center - paddle_center_x) / (PADDLE_SIZE.x * 0.5)
		ball_direction = ball_direction.normalized()
		AudioManager.play_sfx("sfx_pong_hit_player")

	# Pierde si la pelota cae por abajo
	if ball.position.y > 185:
		_lose_life()


# =============================================================================
# WALL COLLISION
# =============================================================================

func _check_wall_collision():
	var ball_rect = Rect2(ball.global_position, BALL_SIZE)
	var bricks_to_remove: Array = []

	for i in range(bricks.size()):
		var bd = bricks[i]
		var brick_node = bd["node"]
		if not is_instance_valid(brick_node):
			bricks_to_remove.append(i)
			continue

		var brick_type: String = bd["type"]
		# Light gaps and borders — ball passes through
		if brick_type in ["light", "border"]:
			continue

		var brick_global_pos = wall_container.position + brick_node.position
		var brick_rect = Rect2(brick_global_pos, BRICK_SIZE)

		if ball_rect.intersects(brick_rect):
			# Always bounce
			ball_direction.y = -ball_direction.y

			# Indestructible / border — just bounce
			if bd["hp"] < 0:
				AudioManager.play_sfx("sfx_pong_wall_bounce")
				break

			bd["hp"] -= 1

			if bd["hp"] <= 0:
				# Destroyed
				var pts := _get_tile_points(bd["tile_id"])
				score += pts
				_update_score_display()
				AudioManager.play_sfx("sfx_wall_brick_break")

				# Eye AoE — damage adjacent bricks
				if brick_type == "eye":
					_eye_aoe_damage(bd["row"], bd["col"])

				# Replace with Grieta con Luz
				brick_node.texture = _get_tile_texture(Tile.LIGHT)
				bd["type"] = "light"
				bd["hp"] = 0

				_update_boss_hp_bar()
				_check_phase_change()
			else:
				# Update visual based on damage
				_update_brick_visual(bd)
				if brick_type == "reinforced":
					AudioManager.play_sfx("sfx_wall_brick_hit")
				else:
					AudioManager.play_sfx("sfx_wall_brick_hit")
			break

	# Clean up invalid entries
	var cleaned: Array[Dictionary] = []
	for bd in bricks:
		if is_instance_valid(bd["node"]):
			cleaned.append(bd)
	bricks = cleaned

	# Victoria — all destructible bricks gone
	if _count_destructible() == 0:
		is_active = false
		_victory_sequence()


func _get_tile_points(tile_id: int) -> int:
	match tile_id:
		Tile.NORMAL, Tile.DAMAGED, Tile.CRITICAL: return 100
		Tile.REINFORCED, Tile.REINFORCED_DMG: return 300
		Tile.EYE: return 500
		_: return 0


func _update_brick_visual(bd: Dictionary):
	var brick_node: Sprite2D = bd["node"]
	var brick_type: String = bd["type"]
	var hp: int = bd["hp"]

	if brick_type == "normal":
		if hp == 2:
			brick_node.texture = _get_tile_texture(Tile.DAMAGED)
			bd["tile_id"] = Tile.DAMAGED
		elif hp == 1:
			brick_node.texture = _get_tile_texture(Tile.CRITICAL)
			bd["tile_id"] = Tile.CRITICAL
	elif brick_type == "reinforced":
		if hp <= 3:
			brick_node.texture = _get_tile_texture(Tile.REINFORCED_DMG)
			bd["tile_id"] = Tile.REINFORCED_DMG
	elif brick_type == "eye":
		# Eyes get redder as HP drops
		var ratio := float(hp) / 4.0
		brick_node.modulate = Color(1.0, ratio, ratio)


func _eye_aoe_damage(eye_row: int, eye_col: int):
	# Damage all adjacent bricks (8 directions)
	for dr in range(-1, 2):
		for dc in range(-1, 2):
			if dr == 0 and dc == 0:
				continue
			var tr := eye_row + dr
			var tc := eye_col + dc
			for bd in bricks:
				if bd["row"] == tr and bd["col"] == tc and bd["hp"] > 0:
					bd["hp"] -= 1
					if bd["hp"] <= 0:
						# Destroy adjacent
						if is_instance_valid(bd["node"]):
							bd["node"].texture = _get_tile_texture(Tile.LIGHT)
							bd["type"] = "light"
							bd["hp"] = 0
							score += _get_tile_points(bd["tile_id"])
					else:
						_update_brick_visual(bd)
	_update_boss_hp_bar()


func _count_destructible() -> int:
	var count := 0
	for bd in bricks:
		if bd["type"] in ["normal", "reinforced", "eye"] and bd["hp"] > 0:
			count += 1
	return count


# =============================================================================
# VISUAL EFFECTS
# =============================================================================

func _pulse_critical_bricks(delta):
	_critical_pulse_time += delta
	var alpha := 0.8 + 0.2 * sin(_critical_pulse_time * 12.0)
	for bd in bricks:
		if bd["tile_id"] == Tile.CRITICAL and is_instance_valid(bd["node"]):
			bd["node"].modulate.a = alpha


func _update_eye_tracking():
	# Eyes slightly shift modulate to "look" toward ball
	if not is_instance_valid(ball):
		return
	for bd in bricks:
		if bd["type"] == "eye" and bd["hp"] > 0 and is_instance_valid(bd["node"]):
			var brick_global = wall_container.position + bd["node"].position + BRICK_SIZE * 0.5
			var dir_to_ball = (ball.position - brick_global).normalized()
			# Subtle position offset to simulate eye tracking (max 1px)
			bd["node"].offset = dir_to_ball * 1.0


# =============================================================================
# PHASES
# =============================================================================

func _check_phase_change():
	var remaining := _count_destructible()
	var total := _count_total_destructible_in_layout()

	if total == 0:
		return

	var ratio := float(remaining) / float(total)

	if ratio <= 0.4 and current_phase < 3:
		current_phase = 3
		# Demon eyes flicker when weak
		if demon_sprite:
			var tw = create_tween().set_loops()
			tw.tween_property(demon_sprite, "modulate:a", 0.6, 0.15)
			tw.tween_property(demon_sprite, "modulate:a", 1.0, 0.15)
	elif ratio <= 0.7 and current_phase < 2:
		current_phase = 2


func _count_total_destructible_in_layout() -> int:
	var count := 0
	for row in wall_layout_phase1:
		for tile_id in row:
			if tile_id in [Tile.NORMAL, Tile.REINFORCED, Tile.EYE]:
				count += 1
	return count


# =============================================================================
# PROJECTILES (Ojos disparan en fase 3+)
# =============================================================================

func _shoot_projectile():
	# Find an eye to shoot from
	var eyes: Array = []
	for bd in bricks:
		if bd["type"] == "eye" and bd["hp"] > 0 and is_instance_valid(bd["node"]):
			eyes.append(bd)

	# No eyes — shoot from random destructible brick
	var shooter: Dictionary
	if eyes.size() > 0:
		shooter = eyes[randi() % eyes.size()]
	else:
		var shooters: Array = []
		for bd in bricks:
			if bd["hp"] > 0 and is_instance_valid(bd["node"]):
				shooters.append(bd)
		if shooters.size() == 0:
			return
		shooter = shooters[randi() % shooters.size()]

	var proj = ColorRect.new()
	proj.size = Vector2(4, 4)
	proj.color = Color(1.0, 0.3, 0.1)
	proj.position = wall_container.position + shooter["node"].position + Vector2(6, 16)
	proj.set_meta("speed", 110.0)
	proj.add_to_group("boss_projectiles")
	add_child(proj)


func _process(delta):
	for child in get_children():
		if child.is_in_group("boss_projectiles"):
			child.position.y += child.get_meta("speed", 110.0) * delta
			var proj_rect = Rect2(child.position, Vector2(4, 4))
			var paddle_rect = _get_paddle_rect()
			if proj_rect.intersects(paddle_rect):
				_lose_life()
				child.queue_free()
			elif child.position.y > 190:
				child.queue_free()


# =============================================================================
# LIVES & SCORE
# =============================================================================

func _lose_life():
	mm_lives -= 1
	AudioManager.play_sfx("sfx_wall_damage")
	_update_lives_display()
	if mm_lives <= 0:
		mm_lives = 10
		reset_boss()
		return
	# Hide ball and start countdown
	ball.visible = false
	is_active = false
	_start_countdown()


func _start_countdown():
	var countdown_label = Label.new()
	countdown_label.name = "CountdownLabel"
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.position = Vector2(120, 120)
	countdown_label.size = Vector2(80, 30)
	countdown_label.add_theme_font_size_override("font_size", 18)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.2))
	add_child(countdown_label)

	for step in ["3", "2", "1", "GO!"]:
		countdown_label.text = step
		# Scale pop effect
		countdown_label.scale = Vector2(1.5, 1.5)
		var tw = create_tween()
		tw.tween_property(countdown_label, "scale", Vector2(1, 1), 0.3).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(0.7).timeout

	countdown_label.queue_free()
	# Launch ball
	ball.position = Vector2(156, 164)
	ball_direction = Vector2([-1, 1].pick_random(), -0.5).normalized()
	ball.visible = true
	is_active = true


func _update_lives_display():
	if has_node("LivesLabel"):
		var text = "MM: "
		for i in range(mm_lives):
			text += "★"
		$LivesLabel.text = text


func _update_score_display():
	if has_node("ScoreLabel"):
		$ScoreLabel.text = str(score)


func _update_boss_hp_bar():
	if not boss_hp_bar:
		return
	var total := _count_total_destructible_in_layout()
	if total == 0:
		boss_hp_bar.size.x = 0
		return
	var remaining := _count_destructible()
	boss_hp_bar.size.x = BOSS_HP_BAR_WIDTH * (float(remaining) / float(total))


# =============================================================================
# VICTORY
# =============================================================================

func _victory_sequence():
	# Flash all light tiles
	for bd in bricks:
		if bd["type"] == "light" and is_instance_valid(bd["node"]):
			var tw = create_tween()
			tw.tween_property(bd["node"], "modulate",
				Color(1.5, 1.4, 1.0), 0.3).set_delay(randf_range(0.0, 0.5))

	# Demon crumbles
	if demon_sprite:
		var tw = create_tween()
		tw.tween_property(demon_sprite, "modulate:a", 0.0, 1.5)
		tw.parallel().tween_property(demon_sprite, "position:y",
			demon_sprite.position.y - 10, 1.5)

	# Delay then emit signal
	await get_tree().create_timer(2.0).timeout
	emit_signal("boss_defeated")


# =============================================================================
# RESET
# =============================================================================

func reset_boss():
	wall_container.position = Vector2(80, 16)
	_generate_wall(wall_layout_phase1)
	ball.position = Vector2(156, 164)
	ball_direction = Vector2(1, -0.5).normalized()
	current_phase = 1
	mm_lives = 10
	score = 0
	_critical_pulse_time = 0.0
	_update_lives_display()
	_update_score_display()
	_update_boss_hp_bar()
	# Restore demon
	if demon_sprite:
		demon_sprite.modulate = Color.WHITE
		demon_sprite.position = Vector2(160, 32)
	# Limpiar proyectiles
	for child in get_children():
		if child.is_in_group("boss_projectiles"):
			child.queue_free()
