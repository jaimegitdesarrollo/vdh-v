extends Node2D
## Ch1MagicManPong — Nivel completo de Magic Man Cap 1.
## Intro cómic → Pong Evolved → Boss The Wall → Victoria → Vuelta a Cristian.

enum Phase { INTRO, PONG, BOSS, VICTORY }
var current_phase: Phase = Phase.INTRO

var comic_intro: Control
var pong_game: Node2D
var boss_game: Node2D
var victory_screen: Control
var mm_lives: int = 3
var magic_man_texture: Texture2D


func _init():
	# Try spritesheet first, fall back to old single sprite
	var sheet: Texture2D = load("res://assets/sprites/player/magicman_spritesheet.png")
	if sheet != null:
		var at := AtlasTexture.new()
		at.atlas = sheet
		at.region = Rect2(0, 0, 16, 16)
		at.filter_clip = true
		magic_man_texture = at
	else:
		magic_man_texture = load("res://assets/sprites/minigames/magic_man.png")


func _ready():
	_start_intro()


func _start_intro():
	current_phase = Phase.INTRO
	# Crear intro de cómic — explicit size (anchors don't work inside Node2D)
	var intro_script = load("res://scripts/minigames/comic_intro.gd")
	comic_intro = Control.new()
	comic_intro.set_script(intro_script)
	comic_intro.size = Vector2(320, 180)
	comic_intro.position = Vector2.ZERO
	add_child(comic_intro)

	await get_tree().process_frame
	comic_intro.intro_finished.connect(_on_intro_finished)

	var panels: Array[String] = [
		"En las calles de Loud City, la oscuridad se cierne sobre los edificios...",
		"Magic Man patrulla los tejados, su capa azul ondeando al viento.",
		"Un muro gigante ha aparecido, bloqueando el paso a los ciudadanos.",
		"¡Es hora de actuar! Magic Man no permitirá que ningún muro le detenga."
	]
	comic_intro.start(panels)


func _on_intro_finished():
	if comic_intro:
		comic_intro.queue_free()
	_start_pong()


func _start_pong():
	current_phase = Phase.PONG
	# Pong music
	AudioManager.play_music("magicman_pong_theme")
	var pong_script = load("res://scripts/minigames/pong_evolved.gd")
	pong_game = Node2D.new()
	pong_game.set_script(pong_script)
	pong_game.magic_man_texture = magic_man_texture
	add_child(pong_game)

	await get_tree().process_frame
	pong_game.gameplay_finished.connect(_on_pong_finished)


func _on_pong_finished():
	AudioManager.stop_music(0.5)
	if pong_game:
		pong_game.queue_free()
	# Viñeta de transición al Boss
	var intro_script = load("res://scripts/minigames/comic_intro.gd")
	var boss_vineta = Control.new()
	boss_vineta.set_script(intro_script)
	boss_vineta.size = Vector2(320, 180)
	boss_vineta.position = Vector2.ZERO
	add_child(boss_vineta)

	await get_tree().process_frame
	boss_vineta.intro_finished.connect(func():
		boss_vineta.queue_free()
		_start_boss()
	)
	boss_vineta.show_single_panel("¡MAGIC MAN SE ENFRENTA A THE WALL!\nEl muro gigante bloquea Loud City.\n¡Destrúyelo ladrillo a ladrillo!")


func _start_boss():
	current_phase = Phase.BOSS
	AudioManager.play_sfx("sfx_wall_boss_intro")
	AudioManager.play_music("magicman_boss_thewall")
	var boss_script = load("res://scripts/minigames/boss_the_wall.gd")
	boss_game = Node2D.new()
	boss_game.set_script(boss_script)
	boss_game.magic_man_texture = magic_man_texture
	add_child(boss_game)

	await get_tree().process_frame
	boss_game.boss_defeated.connect(_on_boss_defeated)


func _on_boss_defeated():
	AudioManager.stop_music(0.5)
	AudioManager.play_sfx("sfx_wall_victory")
	if boss_game:
		boss_game.queue_free()
	_show_victory()


func _show_victory():
	current_phase = Phase.VICTORY

	# Pantalla victoria — explicit size (anchors don't work inside Node2D)
	victory_screen = Control.new()
	victory_screen.size = Vector2(320, 180)
	victory_screen.position = Vector2.ZERO
	add_child(victory_screen)

	var bg = ColorRect.new()
	bg.size = Vector2(320, 180)
	bg.position = Vector2.ZERO
	bg.color = Color(0.05, 0.1, 0.3, 1.0)
	victory_screen.add_child(bg)

	# Magic Man sprite en la pantalla de victoria
	var mm_victory = TextureRect.new()
	mm_victory.texture = magic_man_texture
	mm_victory.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mm_victory.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mm_victory.position = Vector2(140, 10)
	mm_victory.size = Vector2(40, 40)
	mm_victory.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	victory_screen.add_child(mm_victory)

	var title = Label.new()
	title.text = "¡MAGIC MAN VENCE!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.position = Vector2(40, 50)
	title.size = Vector2(240, 30)
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	victory_screen.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "El muro ha caído. Los ciudadanos de Loud City están a salvo."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(20, 90)
	subtitle.size = Vector2(280, 40)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 8)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	victory_screen.add_child(subtitle)

	var hint = Label.new()
	hint.text = "Pulsa espacio para continuar..."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(80, 150)
	hint.size = Vector2(160, 20)
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.7))
	victory_screen.add_child(hint)

	# Esperar input
	await _wait_for_input()
	_return_to_cristian()


func _wait_for_input():
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("confirm"):
			break


func _return_to_cristian():
	TransitionManager.change_scene("res://scenes/chapters/chapter1/ch1_bedroom_night.tscn")
