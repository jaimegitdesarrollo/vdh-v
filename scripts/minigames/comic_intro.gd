extends Control
## ComicIntro — Muestra viñetas de cómic en secuencia.
## Reutilizable: start() para multi-panel, show_single_panel() para viñetas de fase.

signal intro_finished

var panels: Array[String] = []
var current_panel: int = 0
var panel_label: Label
var panel_bg: ColorRect
var counter_label: Label
var hint_label: Label


func _ready():
	visible = false
	# Explicit size — anchors don't work when parent is Node2D
	size = Vector2(320, 180)
	position = Vector2.ZERO


func start(panel_texts: Array[String]):
	panels = panel_texts
	current_panel = 0
	visible = true
	_setup_ui()
	_show_panel()


func show_single_panel(text: String):
	panels = [text]
	current_panel = 0
	visible = true
	_setup_ui()
	_show_panel()


func _setup_ui():
	# Fondo viñeta — explicit size, no anchors
	panel_bg = ColorRect.new()
	panel_bg.position = Vector2.ZERO
	panel_bg.size = Vector2(320, 180)
	panel_bg.color = Color(0.1, 0.15, 0.35, 1.0)
	add_child(panel_bg)

	# Borde cómic — simple ColorRect frame (comic_frame.png renders as solid white)
	var border_color = Color(0.3, 0.35, 0.7, 1.0)
	for rect_data in [
		[Vector2(10, 10), Vector2(300, 2)],   # top
		[Vector2(10, 148), Vector2(300, 2)],   # bottom
		[Vector2(10, 10), Vector2(2, 140)],    # left
		[Vector2(308, 10), Vector2(2, 140)],   # right
	]:
		var line = ColorRect.new()
		line.position = rect_data[0]
		line.size = rect_data[1]
		line.color = border_color
		add_child(line)

	# Texto
	panel_label = Label.new()
	panel_label.position = Vector2(20, 20)
	panel_label.size = Vector2(280, 120)
	panel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel_label.add_theme_font_size_override("font_size", 8)
	panel_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(panel_label)

	# Contador
	counter_label = Label.new()
	counter_label.position = Vector2(260, 155)
	counter_label.add_theme_font_size_override("font_size", 8)
	counter_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.7))
	add_child(counter_label)

	# Hint
	hint_label = Label.new()
	hint_label.text = "Pulsa espacio..."
	hint_label.position = Vector2(110, 160)
	hint_label.add_theme_font_size_override("font_size", 8)
	hint_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.6))
	add_child(hint_label)


func _show_panel():
	if current_panel >= panels.size():
		_finish()
		return
	panel_label.text = panels[current_panel]
	if panels.size() > 1:
		counter_label.text = "%d/%d" % [current_panel + 1, panels.size()]
	else:
		counter_label.text = ""
	# Fade in animation
	panel_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(panel_label, "modulate:a", 1.0, 0.3)


func _input(event):
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
		get_viewport().set_input_as_handled()
		current_panel += 1
		_show_panel()


func _finish():
	visible = false
	emit_signal("intro_finished")
