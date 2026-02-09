extends Node2D
## MagicManLevel — Framework base para niveles de Magic Man.
## Fases: INTRO → GAMEPLAY → BOSS → VICTORY

enum Phase { INTRO, GAMEPLAY, BOSS, VICTORY }
var current_phase: Phase = Phase.INTRO

var mm_lives: int = 3
var intro_panels: Array[String] = []
var current_panel: int = 0

signal level_completed

# Nodos hijos esperados en la escena:
# - ComicIntro (Control) — para viñetas
# - GameplayContainer (Node2D) — para el minijuego
# - BossContainer (Node2D) — para el boss
# - VictoryScreen (Control) — pantalla victoria


func _ready():
	start_intro()


func start_intro():
	current_phase = Phase.INTRO
	_show_intro_panel()


func _show_intro_panel():
	if current_panel >= intro_panels.size():
		start_gameplay()
		return

	# Mostrar viñeta de cómic
	var panel_text = intro_panels[current_panel]
	var container = get_node_or_null("ComicIntro")
	if container:
		# Limpiar panel anterior
		for child in container.get_children():
			child.queue_free()

		# Fondo de viñeta
		var bg = ColorRect.new()
		bg.size = Vector2(280, 140)
		bg.position = Vector2(20, 20)
		bg.color = Color(0.2, 0.3, 0.8, 1.0) # Azul vibrante (mundo Magic Man)
		container.add_child(bg)

		# Borde cómic
		var border = ColorRect.new()
		border.size = Vector2(276, 136)
		border.position = Vector2(22, 22)
		border.color = Color(0.1, 0.2, 0.6, 1.0)
		container.add_child(border)

		# Texto
		var label = Label.new()
		label.text = panel_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.position = Vector2(30, 30)
		label.size = Vector2(260, 120)
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color.WHITE)
		container.add_child(label)

		container.visible = true


func _input(event):
	if current_phase == Phase.INTRO:
		if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
			current_panel += 1
			_show_intro_panel()
	elif current_phase == Phase.VICTORY:
		if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
			emit_signal("level_completed")


func start_gameplay():
	current_phase = Phase.GAMEPLAY
	var intro = get_node_or_null("ComicIntro")
	if intro:
		intro.visible = false
	var gameplay = get_node_or_null("GameplayContainer")
	if gameplay:
		gameplay.visible = true
		# El gameplay_finished signal vendrá del minijuego hijo
		for child in gameplay.get_children():
			if child.has_signal("gameplay_finished"):
				child.gameplay_finished.connect(start_boss)


func start_boss():
	current_phase = Phase.BOSS
	var gameplay = get_node_or_null("GameplayContainer")
	if gameplay:
		gameplay.visible = false
	var boss_container = get_node_or_null("BossContainer")
	if boss_container:
		boss_container.visible = true
		for child in boss_container.get_children():
			if child.has_signal("boss_defeated"):
				child.boss_defeated.connect(show_victory)


func show_victory():
	current_phase = Phase.VICTORY
	var boss_container = get_node_or_null("BossContainer")
	if boss_container:
		boss_container.visible = false

	var victory = get_node_or_null("VictoryScreen")
	if victory:
		victory.visible = true
	else:
		# Crear pantalla de victoria simple
		var screen = ColorRect.new()
		screen.name = "VictoryScreen"
		screen.set_anchors_preset(Control.PRESET_FULL_RECT)
		screen.color = Color(0.1, 0.2, 0.5, 0.9)
		add_child(screen)

		var label = Label.new()
		label.text = "¡MAGIC MAN VENCE!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_CENTER)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		screen.add_child(label)


func mm_take_damage():
	mm_lives -= 1
	if mm_lives <= 0:
		mm_lives = 3
		restart_current_phase()


func restart_current_phase():
	match current_phase:
		Phase.GAMEPLAY:
			var gameplay = get_node_or_null("GameplayContainer")
			if gameplay:
				for child in gameplay.get_children():
					if child.has_method("reset_game"):
						child.reset_game()
		Phase.BOSS:
			var boss = get_node_or_null("BossContainer")
			if boss:
				for child in boss.get_children():
					if child.has_method("reset_boss"):
						child.reset_boss()
