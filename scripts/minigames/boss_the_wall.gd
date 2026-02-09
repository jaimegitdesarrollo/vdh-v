extends Node2D
## BossTheWall — Boss del Cap 1: muro de ladrillos que avanza.
## Mecánica Arkanoid invertida: lanza pelota contra el muro para destruirlo.

signal boss_defeated

@export var wall_speed: float = 10.0
@export var brick_hp: int = 2

# Texturas
var paddle_texture: Texture2D = preload("res://assets/sprites/minigames/paddle.png")
var ball_texture: Texture2D = preload("res://assets/sprites/minigames/ball.png")
var brick_texture: Texture2D = preload("res://assets/sprites/minigames/brick.png")
var brick_damaged_texture: Texture2D = preload("res://assets/sprites/minigames/brick_damaged.png")

# Tamaños de referencia para colisiones (paddle rotado horizontalmente: 32 wide x 8 tall)
const PADDLE_SIZE := Vector2(32, 8)
const BALL_SIZE := Vector2(8, 8)
const BRICK_SIZE := Vector2(16, 8)

var bricks: Array[Dictionary] = [] # {node, hp}
var ball: Sprite2D
var ball_direction: Vector2 = Vector2(1, -0.5).normalized()
var ball_speed: float = 180.0
var paddle: Sprite2D
var paddle_speed: float = 200.0
var wall_container: Node2D
var current_phase: int = 1
var mm_lives: int = 3
var is_active: bool = false
var shoot_timer: float = 0.0
var _advance_sfx_timer: float = 0.0
var _warning_played: bool = false

# Magic Man texture (set by parent before add_child)
var magic_man_texture: Texture2D
var magic_man_sprite: Sprite2D


func _ready():
	_setup_boss()
	is_active = true


func _setup_boss():
	# Fondo
	var bg = ColorRect.new()
	bg.size = Vector2(320, 180)
	bg.color = Color(0.05, 0.0, 0.1, 1.0)
	add_child(bg)

	# Paddle de Magic Man (abajo) — paddle.png rotado para orientación horizontal
	paddle = Sprite2D.new()
	paddle.name = "Paddle"
	paddle.texture = paddle_texture
	paddle.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paddle.centered = true
	paddle.rotation = deg_to_rad(90)
	# PADDLE_SIZE (32x8) es el tamaño visual tras rotar el sprite 8x32.
	# position indica el centro del paddle; _get_paddle_rect() calcula el Rect2.
	paddle.position = Vector2(144 + PADDLE_SIZE.x * 0.5, 165 + PADDLE_SIZE.y * 0.5)
	add_child(paddle)

	# Magic Man sprite — de pie sobre la paleta (sibling, not child, because paddle is rotated)
	if magic_man_texture:
		magic_man_sprite = Sprite2D.new()
		magic_man_sprite.name = "MagicManSprite"
		magic_man_sprite.texture = magic_man_texture
		magic_man_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		magic_man_sprite.centered = true
		magic_man_sprite.position = Vector2(paddle.position.x, paddle.position.y - 12)
		add_child(magic_man_sprite)

	# Muro de ladrillos
	wall_container = Node2D.new()
	wall_container.name = "WallContainer"
	wall_container.position = Vector2(160, 10)
	add_child(wall_container)
	_generate_wall()

	# Pelota
	ball = Sprite2D.new()
	ball.name = "Ball"
	ball.texture = ball_texture
	ball.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ball.centered = false
	ball.position = Vector2(160, 155)
	add_child(ball)

	# Lives display
	var lives_label = Label.new()
	lives_label.name = "LivesLabel"
	lives_label.position = Vector2(4, 4)
	lives_label.add_theme_font_size_override("font_size", 8)
	lives_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	add_child(lives_label)
	_update_lives_display()

	# Boss name
	var name_label = Label.new()
	name_label.text = "THE WALL"
	name_label.position = Vector2(240, 4)
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
	add_child(name_label)


func _generate_wall():
	bricks.clear()
	for child in wall_container.get_children():
		child.queue_free()

	for row in range(5):
		for col in range(8):
			var brick = Sprite2D.new()
			brick.texture = brick_texture
			brick.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			brick.centered = false
			brick.position = Vector2(col * 20, row * 12)
			wall_container.add_child(brick)
			bricks.append({"node": brick, "hp": brick_hp})


func _physics_process(delta):
	if not is_active:
		return

	_move_paddle(delta)
	_move_ball(delta)
	_advance_wall(delta)
	_check_wall_collision()

	# Fase 3: disparar proyectiles
	if current_phase >= 3:
		shoot_timer -= delta
		if shoot_timer <= 0:
			_shoot_projectile()
			shoot_timer = 2.0


func _get_paddle_rect() -> Rect2:
	# El paddle usa centered=true con rotación, position es el centro visual.
	return Rect2(paddle.position.x - PADDLE_SIZE.x * 0.5, paddle.position.y - PADDLE_SIZE.y * 0.5, PADDLE_SIZE.x, PADDLE_SIZE.y)


func _move_paddle(delta):
	var dir = Input.get_axis("move_left", "move_right")
	paddle.position.x += dir * paddle_speed * delta
	paddle.position.x = clamp(paddle.position.x, PADDLE_SIZE.x * 0.5, 320 - PADDLE_SIZE.x * 0.5)
	# Sync Magic Man position (standing on top of paddle)
	if magic_man_sprite:
		magic_man_sprite.position = Vector2(paddle.position.x, paddle.position.y - 12)


func _move_ball(delta):
	ball.position += ball_direction * ball_speed * delta

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
		# Ajustar ángulo según posición de contacto
		var paddle_center_x = paddle.position.x
		var ball_center = ball.position.x + BALL_SIZE.x * 0.5
		ball_direction.x = (ball_center - paddle_center_x) / (PADDLE_SIZE.x * 0.5)
		ball_direction = ball_direction.normalized()
		AudioManager.play_sfx("sfx_pong_hit_player")

	# Pierde si la pelota cae por abajo
	if ball.position.y > 185:
		_lose_life()


func _advance_wall(delta):
	var speed_mult = 1.0
	if current_phase >= 2:
		speed_mult = 1.5
	wall_container.position.y += wall_speed * speed_mult * delta

	# Periodic advance SFX
	_advance_sfx_timer += delta
	if _advance_sfx_timer >= 3.0:
		_advance_sfx_timer = 0.0
		AudioManager.play_sfx("sfx_wall_advance")

	# Warning when wall is close (3 rows = 36px from paddle)
	var wall_bottom = wall_container.position.y + 60
	var paddle_top = paddle.position.y - PADDLE_SIZE.y * 0.5
	if wall_bottom > paddle_top - 36 and not _warning_played:
		_warning_played = true
		AudioManager.play_sfx("sfx_wall_warning")
	elif wall_bottom < paddle_top - 50:
		_warning_played = false

	# Si el muro alcanza al paddle (position.y es el centro del paddle)
	if wall_bottom > paddle_top:
		_lose_life()
		wall_container.position.y = 10
		_warning_played = false


func _check_wall_collision():
	var ball_rect = Rect2(ball.global_position, BALL_SIZE)
	var bricks_to_remove: Array = []

	for i in range(bricks.size()):
		var brick_data = bricks[i]
		var brick_node = brick_data["node"]
		if not is_instance_valid(brick_node):
			bricks_to_remove.append(i)
			continue

		var brick_global_pos = wall_container.position + brick_node.position
		var brick_rect = Rect2(brick_global_pos, BRICK_SIZE)

		if ball_rect.intersects(brick_rect):
			ball_direction.y = -ball_direction.y
			brick_data["hp"] -= 1

			if brick_data["hp"] <= 0:
				AudioManager.play_sfx("sfx_wall_brick_break")
				brick_node.queue_free()
				bricks_to_remove.append(i)

				# Check fase
				var remaining = bricks.size() - bricks_to_remove.size()
				if remaining <= 25:
					_check_phase_change(remaining)
			else:
				AudioManager.play_sfx("sfx_wall_brick_hit")
				# Cambiar textura a ladrillo dañado
				brick_node.texture = brick_damaged_texture
			break

	# Eliminar ladrillos destruidos (en orden inverso)
	bricks_to_remove.sort()
	bricks_to_remove.reverse()
	for i in bricks_to_remove:
		if i < bricks.size():
			bricks.remove_at(i)

	# Victoria
	if bricks.size() == 0:
		is_active = false
		emit_signal("boss_defeated")


func _check_phase_change(remaining: int):
	if remaining <= 15 and current_phase < 2:
		current_phase = 2
		wall_speed = 15.0
	elif remaining <= 8 and current_phase < 3:
		current_phase = 3


func _shoot_projectile():
	if bricks.size() == 0:
		return
	# Elegir un ladrillo aleatorio para disparar
	var random_brick = bricks[randi() % bricks.size()]
	if not is_instance_valid(random_brick["node"]):
		return
	var proj = ColorRect.new()
	proj.size = Vector2(4, 4)
	proj.color = Color(1.0, 0.3, 0.3)
	proj.position = wall_container.position + random_brick["node"].position + Vector2(8, 10)
	proj.set_meta("speed", 100.0)
	proj.add_to_group("boss_projectiles")
	add_child(proj)


func _process(delta):
	# Mover proyectiles del boss
	for child in get_children():
		if child.is_in_group("boss_projectiles"):
			child.position.y += child.get_meta("speed", 100.0) * delta
			# Colisión con paddle
			var proj_rect = Rect2(child.position, Vector2(4, 4))
			var paddle_rect = _get_paddle_rect()
			if proj_rect.intersects(paddle_rect):
				_lose_life()
				child.queue_free()
			elif child.position.y > 190:
				child.queue_free()


func _lose_life():
	mm_lives -= 1
	AudioManager.play_sfx("sfx_wall_damage")
	_update_lives_display()
	if mm_lives <= 0:
		mm_lives = 3
		reset_boss()
	# Reset ball
	ball.position = Vector2(160, 155)
	ball_direction = Vector2([-1, 1].pick_random(), -0.5).normalized()


func _update_lives_display():
	if has_node("LivesLabel"):
		var text = "MM: "
		for i in range(mm_lives):
			text += "★"
		$LivesLabel.text = text


func reset_boss():
	wall_container.position = Vector2(160, 10)
	_generate_wall()
	ball.position = Vector2(160, 155)
	ball_direction = Vector2(1, -0.5).normalized()
	current_phase = 1
	wall_speed = 10.0
	mm_lives = 3
	_update_lives_display()
	# Limpiar proyectiles
	for child in get_children():
		if child.is_in_group("boss_projectiles"):
			child.queue_free()
