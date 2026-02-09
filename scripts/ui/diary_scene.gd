extends Control
## DiaryScene — Escena del diario: texto typewriter, lista esperanzas, poema interactivo.
## Fases: TEXT → HOPE_LIST → POEM → TITLE

enum DiaryPhase { TEXT, HOPE_LIST, POEM, TITLE }
var current_phase: DiaryPhase = DiaryPhase.TEXT

signal diary_finished

var diary_data: Dictionary = {}
var hope_lines: Array = []
var is_typing: bool = false
var waiting_for_input: bool = false

# UI nodes
var diary_bg: Panel
var diary_text_label: RichTextLabel
var hope_container: VBoxContainer
var poem_composer: Control
var title_label: Label
var continue_hint: Label

const TYPEWRITER_SPEED: float = 0.03


func _ready():
	_setup_ui()
	visible = false


func _setup_ui():
	# Fondo papel
	diary_bg = Panel.new()
	diary_bg.name = "DiaryBG"
	var paper_style = StyleBoxFlat.new()
	paper_style.bg_color = Color(0.95, 0.92, 0.85, 1.0)
	diary_bg.add_theme_stylebox_override("panel", paper_style)
	diary_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(diary_bg)

	# Texto del diario
	diary_text_label = RichTextLabel.new()
	diary_text_label.name = "DiaryText"
	diary_text_label.position = Vector2(30, 15)
	diary_text_label.size = Vector2(260, 140)
	diary_text_label.bbcode_enabled = true
	diary_text_label.add_theme_font_size_override("normal_font_size", 8)
	diary_text_label.add_theme_color_override("default_color", Color(0.2, 0.15, 0.1))
	diary_text_label.scroll_active = true
	add_child(diary_text_label)

	# Container lista de esperanzas
	hope_container = VBoxContainer.new()
	hope_container.name = "HopeContainer"
	hope_container.position = Vector2(40, 20)
	hope_container.add_theme_constant_override("separation", 8)
	hope_container.visible = false
	add_child(hope_container)

	# Título final
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
	title_label.visible = false
	add_child(title_label)

	# Continuar hint
	continue_hint = Label.new()
	continue_hint.name = "ContinueHint"
	continue_hint.text = "Pulsa espacio para continuar..."
	continue_hint.position = Vector2(80, 168)
	continue_hint.add_theme_font_size_override("font_size", 8)
	continue_hint.add_theme_color_override("font_color", Color(0.5, 0.4, 0.3, 0.6))
	continue_hint.visible = false
	add_child(continue_hint)


func start_diary(chapter: int):
	visible = true
	var path = "res://data/diary/diary_chapter%d.json" % chapter
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		diary_data = JSON.parse_string(file.get_as_text())
		file.close()
	else:
		push_warning("DiaryScene: archivo no encontrado: " + path)
		return

	hope_lines = diary_data.get("hope_lines", [])
	current_phase = DiaryPhase.TEXT
	_show_diary_text()


func _show_diary_text():
	diary_text_label.visible = true
	hope_container.visible = false
	title_label.visible = false

	var text = diary_data.get("diary_text", "")
	is_typing = true
	await _typewrite(diary_text_label, text)
	is_typing = false
	_show_continue_hint()
	waiting_for_input = true


func _show_hope_list():
	current_phase = DiaryPhase.HOPE_LIST
	diary_text_label.visible = false
	hope_container.visible = true
	continue_hint.visible = false

	# Limpiar container
	for child in hope_container.get_children():
		child.queue_free()

	# Título
	var title = Label.new()
	title.text = "Hay cosas más importantes por los que levantarme cada mañana."
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
	hope_container.add_child(title)

	await get_tree().create_timer(0.5).timeout

	# Líneas de esperanza
	var lines_to_cross = diary_data.get("lines_to_cross", [])
	for i in range(hope_lines.size()):
		var line = hope_lines[i]
		var label = Label.new()
		label.text = line["text"]
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color(0.15, 0.3, 0.15))
		hope_container.add_child(label)

		await get_tree().create_timer(0.4).timeout

		# Tachar si corresponde
		if line.get("crossed", false) or i in lines_to_cross:
			await get_tree().create_timer(0.3).timeout
			# Animación de tachado: cambiar color y añadir línea
			var tween = create_tween()
			tween.tween_property(label, "modulate", Color(0.5, 0.2, 0.2, 0.6), 0.5)
			label.text = "[TACHADO] " + label.text

		# Temblar si corresponde
		if line.get("shake", false):
			_shake_label(label)

	await get_tree().create_timer(1.0).timeout
	_show_continue_hint()
	waiting_for_input = true


func _show_poem_phase():
	current_phase = DiaryPhase.POEM
	hope_container.visible = false
	continue_hint.visible = false

	# Crear PoemComposer como hijo
	var composer_script = load("res://scripts/ui/poem_composer.gd")
	poem_composer = Control.new()
	poem_composer.set_script(composer_script)
	poem_composer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(poem_composer)

	# Esperar un frame para que _ready se ejecute
	await get_tree().process_frame
	poem_composer.poem_finished.connect(_on_poem_finished)
	poem_composer.start_composition(diary_data.get("poem_path", "res://data/poems/poem_chapter1.json"))


func _on_poem_finished(score: int, verses: Array):
	if poem_composer:
		poem_composer.queue_free()
	await get_tree().create_timer(1.0).timeout
	_show_title()


func _show_title():
	current_phase = DiaryPhase.TITLE
	var poem_title = diary_data.get("poem_title", "")
	var poem_author = diary_data.get("poem_author", "")

	title_label.text = "\"%s\"\npor %s" % [poem_title, poem_author]
	title_label.visible = true

	# Animación de aparición
	title_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.5)

	await get_tree().create_timer(3.0).timeout
	_show_continue_hint()
	waiting_for_input = true


func _input(event):
	if not visible:
		return
	if not waiting_for_input:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
		waiting_for_input = false
		continue_hint.visible = false
		match current_phase:
			DiaryPhase.TEXT:
				_show_hope_list()
			DiaryPhase.HOPE_LIST:
				_show_poem_phase()
			DiaryPhase.TITLE:
				visible = false
				emit_signal("diary_finished")


func _show_continue_hint():
	continue_hint.visible = true
	# Parpadeo
	var tween = create_tween().set_loops()
	tween.tween_property(continue_hint, "modulate:a", 0.3, 0.6)
	tween.tween_property(continue_hint, "modulate:a", 1.0, 0.6)


func _typewrite(label: RichTextLabel, text: String):
	label.text = ""
	label.visible_characters = 0
	label.text = text
	for i in range(text.length()):
		label.visible_characters = i + 1
		await get_tree().create_timer(TYPEWRITER_SPEED).timeout
	label.visible_characters = -1


func _shake_label(label: Label):
	var original_pos = label.position
	var tween = create_tween().set_loops(5)
	tween.tween_property(label, "position:x", original_pos.x + 2, 0.05)
	tween.tween_property(label, "position:x", original_pos.x - 2, 0.05)
	tween.tween_property(label, "position:x", original_pos.x, 0.05)
