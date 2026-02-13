extends Node2D
## PongEvolved — Minijuego Pong progresivo para Magic Man Cap 1.
## 2 fases que evolucionan cada 2 puntos. Victoria a 10 puntos.

signal gameplay_finished

# Texturas
var paddle_texture: Texture2D = preload("res://assets/sprites/minigames/paddle.png")
var ball_texture: Texture2D = preload("res://assets/sprites/minigames/ball.png")

# Tamaños de referencia para colisiones
const PADDLE_SIZE := Vector2(8, 32)
const BALL_SIZE := Vector2(8, 8)

# Configuración
var ball_speed: float = 200.0
var ball_direction: Vector2 = Vector2(1, 0.5).normalized()
var paddle_speed: float = 200.0
var player_score: int = 0
var enemy_score: int = 0
var current_phase: int = 1
var is_playing: bool = false
var vineta_active: bool = false

# Magic Man texture (set by parent before add_child)
var magic_man_texture: Texture2D
var magic_man_sprite: Sprite2D

# Nodos
var balls: Array[Node2D] = []
var player_paddle: Sprite2D
var enemy_paddle: Sprite2D
var score_label: Label
var phase_label: Label

# Área de juego (en coordenadas de viewport 320x180)
var play_area: Rect2 = Rect2(0, 0, 320, 180)
# Phase viñeta texts
const PHASE_VINETAS: Dictionary = {
	2: "¡FASE 2: MULTI-BOLA!\nMagic Man debe enfrentar dos pelotas a la vez.",
}


func _ready():
	_setup_game()
	_start_with_countdown()


func _setup_game():
	# Fondo
	var bg = ColorRect.new()
	bg.size = Vector2(320, 180)
	bg.color = Color(0.05, 0.05, 0.15, 1.0) # Azul muy oscuro
	add_child(bg)

	# Línea central
	var center_line = ColorRect.new()
	center_line.size = Vector2(2, 180)
	center_line.position = Vector2(159, 0)
	center_line.color = Color(0.2, 0.2, 0.4)
	add_child(center_line)

	# Player paddle (Magic Man — izquierda)
	player_paddle = Sprite2D.new()
	player_paddle.name = "PlayerPaddle"
	player_paddle.texture = paddle_texture
	player_paddle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player_paddle.centered = false
	player_paddle.position = Vector2(16, 74)
	add_child(player_paddle)

	# Magic Man sprite — a la izquierda de la paleta, "sujetándola"
	if magic_man_texture:
		magic_man_sprite = Sprite2D.new()
		magic_man_sprite.name = "MagicManSprite"
		magic_man_sprite.texture = magic_man_texture
		magic_man_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		magic_man_sprite.centered = false
		magic_man_sprite.position = Vector2(-14, 8)
		player_paddle.add_child(magic_man_sprite)

	# Enemy paddle (derecha)
	enemy_paddle = Sprite2D.new()
	enemy_paddle.name = "EnemyPaddle"
	enemy_paddle.texture = paddle_texture
	enemy_paddle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	enemy_paddle.centered = false
	enemy_paddle.position = Vector2(296, 74)
	add_child(enemy_paddle)

	# Ball
	_spawn_ball()

	# Score
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(120, 4)
	score_label.add_theme_font_size_override("font_size", 12)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(score_label)
	_update_score_display()

	# Phase indicator
	phase_label = Label.new()
	phase_label.name = "PhaseLabel"
	phase_label.position = Vector2(4, 4)
	phase_label.add_theme_font_size_override("font_size", 8)
	phase_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.8))
	add_child(phase_label)
	_update_phase_display()


func _spawn_ball() -> Node2D:
	var ball = Sprite2D.new()
	ball.name = "Ball_%d" % balls.size()
	ball.texture = ball_texture
	ball.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ball.centered = false
	ball.position = Vector2(156, 86)
	ball.set_meta("direction", Vector2([-1, 1].pick_random(), randf_range(-0.5, 0.5)).normalized())
	ball.set_meta("speed", ball_speed)
	add_child(ball)
	balls.append(ball)
	return ball


func _physics_process(delta):
	if not is_playing:
		return

	_move_player_paddle(delta)
	_move_enemy_ai(delta)
	_move_balls(delta)
	_check_scoring()
	_check_phase_evolution()


func _move_player_paddle(delta):
	var dir = Input.get_axis("move_up", "move_down")
	player_paddle.position.y += dir * paddle_speed * delta
	player_paddle.position.y = clamp(player_paddle.position.y, 0, 180 - PADDLE_SIZE.y)


func _move_enemy_ai(delta):
	if balls.size() == 0:
		return
	# IA deliberadamente imperfecta
	var closest_ball = balls[0]
	for ball in balls:
		if is_instance_valid(ball):
			closest_ball = ball
			break

	if not is_instance_valid(closest_ball):
		return

	var target_y = closest_ball.position.y + BALL_SIZE.y * 0.5 - PADDLE_SIZE.y * 0.5
	var error_margin = randf_range(-30, 30)
	target_y += error_margin
	var diff = target_y - enemy_paddle.position.y
	enemy_paddle.position.y += sign(diff) * paddle_speed * 0.55 * delta
	enemy_paddle.position.y = clamp(enemy_paddle.position.y, 0, 180 - PADDLE_SIZE.y)


func _move_balls(delta):
	for ball in balls:
		if not is_instance_valid(ball):
			continue
		var dir: Vector2 = ball.get_meta("direction")
		var spd: float = ball.get_meta("speed")
		ball.position += dir * spd * delta

		# Rebote arriba/abajo
		if ball.position.y <= 0 or ball.position.y >= 180 - BALL_SIZE.y:
			dir.y = -dir.y
			ball.set_meta("direction", dir)
			AudioManager.play_sfx("sfx_pong_wall_bounce")

		# Rebote con paddle del jugador
		var ball_rect = Rect2(ball.position, BALL_SIZE)
		var player_rect = Rect2(player_paddle.position, PADDLE_SIZE)
		if ball_rect.intersects(player_rect) and dir.x < 0:
			dir.x = abs(dir.x)
			var paddle_center = player_paddle.position.y + PADDLE_SIZE.y * 0.5
			var ball_center = ball.position.y + BALL_SIZE.y * 0.5
			dir.y = (ball_center - paddle_center) / (PADDLE_SIZE.y * 0.5)
			dir = dir.normalized()
			ball.set_meta("direction", dir)
			AudioManager.play_sfx("sfx_pong_hit_player")

		# Rebote con paddle enemigo
		var enemy_rect = Rect2(enemy_paddle.position, PADDLE_SIZE)
		if ball_rect.intersects(enemy_rect) and dir.x > 0:
			dir.x = -abs(dir.x)
			var paddle_center = enemy_paddle.position.y + PADDLE_SIZE.y * 0.5
			var ball_center = ball.position.y + BALL_SIZE.y * 0.5
			dir.y = (ball_center - paddle_center) / (PADDLE_SIZE.y * 0.5)
			dir = dir.normalized()
			ball.set_meta("direction", dir)
			AudioManager.play_sfx("sfx_pong_hit_enemy")



func _check_scoring():
	var balls_to_remove: Array = []
	for ball in balls:
		if not is_instance_valid(ball):
			balls_to_remove.append(ball)
			continue
		if ball.position.x < -10:
			# Enemigo anota
			enemy_score += 1
			AudioManager.play_sfx("sfx_pong_score_enemy")
			balls_to_remove.append(ball)
			ball.queue_free()
		elif ball.position.x > 330:
			# Jugador anota
			player_score += 1
			AudioManager.play_sfx("sfx_pong_score_player")
			balls_to_remove.append(ball)
			ball.queue_free()

	for ball in balls_to_remove:
		balls.erase(ball)

	if balls_to_remove.size() > 0:
		_update_score_display()
		if player_score >= 10:
			is_playing = false
			emit_signal("gameplay_finished")
		else:
			# Respawnear pelota tras breve pausa (not during viñeta)
			await get_tree().create_timer(0.5).timeout
			if is_playing and not vineta_active:
				_spawn_ball()


func _check_phase_evolution():
	var new_phase = min((player_score / 2) + 1, 2)
	if new_phase != current_phase and new_phase <= 2 and not vineta_active:
		current_phase = new_phase
		_show_phase_vineta(current_phase)


func _show_phase_vineta(phase: int):
	# Pause gameplay
	is_playing = false
	vineta_active = true

	# Clean up any remaining balls
	for b in balls:
		if is_instance_valid(b):
			b.queue_free()
	balls.clear()

	if PHASE_VINETAS.has(phase):
		# Show viñeta, then countdown
		var intro_script = load("res://scripts/minigames/comic_intro.gd")
		var vineta = Control.new()
		vineta.set_script(intro_script)
		vineta.size = Vector2(320, 180)
		vineta.position = Vector2.ZERO
		add_child(vineta)

		await get_tree().process_frame
		vineta.intro_finished.connect(func():
			vineta.queue_free()
		)
		vineta.show_single_panel(PHASE_VINETAS[phase])
		await vineta.intro_finished

	# Phase up SFX
	AudioManager.play_sfx("sfx_pong_phase_up")

	_update_phase_display()

	# Countdown before resuming
	await _show_countdown()

	# Spawn correct number of balls for this phase
	_spawn_ball()
	if current_phase >= 2:
		_spawn_ball()  # multi-ball from phase 2 onwards
		AudioManager.play_sfx("sfx_pong_multi_ball")

	vineta_active = false
	is_playing = true


func _update_score_display():
	if score_label:
		score_label.text = "%d — %d" % [player_score, enemy_score]


func _update_phase_display():
	if phase_label:
		phase_label.text = "Fase %d" % current_phase


func _start_with_countdown():
	is_playing = false
	await _show_countdown()
	is_playing = true


func _show_countdown():
	var countdown_label = Label.new()
	countdown_label.name = "CountdownLabel"
	countdown_label.position = Vector2(0, 0)
	countdown_label.size = Vector2(320, 180)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 14)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.2))
	add_child(countdown_label)

	for i in [3, 2, 1]:
		countdown_label.text = str(i)
		countdown_label.modulate.a = 1.0
		var tw = create_tween()
		tw.tween_property(countdown_label, "modulate:a", 0.3, 0.8)
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "¡GANA LA BATALLA!!"
	countdown_label.modulate.a = 1.0
	await get_tree().create_timer(1.0).timeout
	countdown_label.queue_free()


func reset_game():
	player_score = 0
	enemy_score = 0
	current_phase = 1
	for ball in balls:
		if is_instance_valid(ball):
			ball.queue_free()
	balls.clear()
	_spawn_ball()
	_update_score_display()
	_update_phase_display()
	is_playing = true
