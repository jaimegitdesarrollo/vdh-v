extends Control
## PoemComposer — Composición interactiva de poemas.
## El jugador elige versos entre 3 opciones barajadas.

signal poem_finished(resonance_score: int, chosen_verses: Array)

var current_verse: int = 0
var resonance_score: int = 0
var verses_data: Array = []
var chosen_texts: Array[String] = []
var is_typing: bool = false
var is_waiting_choice: bool = false

# UI nodes (creados en _ready)
var paper_panel: Panel
var context_label: RichTextLabel
var gap_indicator: Label
var chosen_verse_label: RichTextLabel
var option_buttons: Array[Button] = []
var reaction_label: Label
var full_poem_label: RichTextLabel

const TYPEWRITER_SPEED: float = 0.03


func _ready():
	_setup_ui()
	visible = false


func _setup_ui():
	# Panel de papel
	paper_panel = Panel.new()
	paper_panel.name = "PaperPanel"
	var paper_style = StyleBoxFlat.new()
	paper_style.bg_color = Color(0.95, 0.9, 0.8, 1.0) # Color papel
	paper_style.corner_radius_top_left = 4
	paper_style.corner_radius_top_right = 4
	paper_style.corner_radius_bottom_left = 4
	paper_style.corner_radius_bottom_right = 4
	paper_panel.add_theme_stylebox_override("panel", paper_style)
	paper_panel.position = Vector2(20, 10)
	paper_panel.size = Vector2(280, 110)
	add_child(paper_panel)

	# Contexto (versos fijos antes)
	context_label = RichTextLabel.new()
	context_label.name = "ContextLabel"
	context_label.position = Vector2(10, 5)
	context_label.size = Vector2(260, 60)
	context_label.bbcode_enabled = true
	context_label.fit_content = true
	context_label.add_theme_font_size_override("normal_font_size", 11)
	context_label.add_theme_color_override("default_color", Color(0.2, 0.15, 0.1))
	paper_panel.add_child(context_label)

	# Hueco parpadeante
	gap_indicator = Label.new()
	gap_indicator.name = "GapIndicator"
	gap_indicator.text = "___________________________________"
	gap_indicator.position = Vector2(10, 55)
	gap_indicator.add_theme_font_size_override("font_size", 11)
	gap_indicator.add_theme_color_override("font_color", Color(0.5, 0.4, 0.3, 0.5))
	gap_indicator.visible = false
	paper_panel.add_child(gap_indicator)

	# Verso elegido (se escribe aquí)
	chosen_verse_label = RichTextLabel.new()
	chosen_verse_label.name = "ChosenVerse"
	chosen_verse_label.position = Vector2(10, 55)
	chosen_verse_label.size = Vector2(260, 15)
	chosen_verse_label.bbcode_enabled = true
	chosen_verse_label.add_theme_font_size_override("normal_font_size", 11)
	chosen_verse_label.add_theme_color_override("default_color", Color(0.1, 0.1, 0.4))
	paper_panel.add_child(chosen_verse_label)

	# Contexto después
	var after_label = RichTextLabel.new()
	after_label.name = "AfterContext"
	after_label.position = Vector2(10, 70)
	after_label.size = Vector2(260, 30)
	after_label.bbcode_enabled = true
	after_label.add_theme_font_size_override("normal_font_size", 11)
	after_label.add_theme_color_override("default_color", Color(0.2, 0.15, 0.1))
	paper_panel.add_child(after_label)

	# Botones de opción
	var options_container = VBoxContainer.new()
	options_container.name = "OptionsContainer"
	options_container.position = Vector2(30, 125)
	options_container.add_theme_constant_override("separation", 3)
	add_child(options_container)

	for i in range(3):
		var btn = Button.new()
		btn.name = "Option%s" % ["A", "B", "C"][i]
		btn.custom_minimum_size = Vector2(260, 14)
		btn.add_theme_font_size_override("font_size", 11)
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(0.9, 0.85, 0.75, 1.0)
		btn_style.border_color = Color(0.6, 0.5, 0.4)
		btn_style.border_width_bottom = 1
		btn_style.border_width_left = 1
		btn_style.border_width_right = 1
		btn_style.border_width_top = 1
		btn.add_theme_stylebox_override("normal", btn_style)
		var idx = i
		btn.pressed.connect(func(): _on_option_selected(idx))
		btn.visible = false
		options_container.add_child(btn)
		option_buttons.append(btn)

	# Label de reacción
	reaction_label = Label.new()
	reaction_label.name = "ReactionLabel"
	reaction_label.position = Vector2(20, 125)
	reaction_label.size = Vector2(280, 40)
	reaction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reaction_label.add_theme_font_size_override("font_size", 11)
	reaction_label.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2))
	reaction_label.visible = false
	add_child(reaction_label)


func start_composition(poem_data_path: String):
	visible = true
	current_verse = 0
	resonance_score = 0
	chosen_texts = []

	if FileAccess.file_exists(poem_data_path):
		var file = FileAccess.open(poem_data_path, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data and data.has("verses"):
			verses_data = data["verses"]
	else:
		push_warning("PoemComposer: archivo no encontrado: " + poem_data_path)
		return

	_show_next_verse()


func _show_next_verse():
	if current_verse >= verses_data.size():
		_finish_poem()
		return

	var verse = verses_data[current_verse]

	# Limpiar
	chosen_verse_label.text = ""
	context_label.text = ""
	reaction_label.visible = false
	var after_ctx = paper_panel.get_node_or_null("AfterContext")
	if after_ctx:
		after_ctx.text = ""

	# Typewriter contexto anterior
	is_typing = true
	await _typewrite(context_label, verse["context_before"])
	is_typing = false

	# Mostrar hueco
	gap_indicator.visible = true

	# Mostrar opciones barajadas
	var options = verse["options"].duplicate()
	options.shuffle()
	is_waiting_choice = true
	for i in range(min(3, options.size())):
		option_buttons[i].text = "%s) %s" % [["A", "B", "C"][i], options[i]["text"]]
		option_buttons[i].set_meta("score", options[i]["score"])
		option_buttons[i].set_meta("original_text", options[i]["text"])
		option_buttons[i].visible = true


func _on_option_selected(index: int):
	if not is_waiting_choice:
		return
	is_waiting_choice = false

	var selected_score = option_buttons[index].get_meta("score")
	var selected_text = option_buttons[index].get_meta("original_text")

	resonance_score += selected_score
	chosen_texts.append(selected_text)

	# Ocultar opciones y hueco
	for btn in option_buttons:
		btn.visible = false
	gap_indicator.visible = false

	# Escribir verso elegido
	is_typing = true
	await _typewrite(chosen_verse_label, selected_text)
	is_typing = false

	AudioManager.play_sfx("sfx_poem_select")

	# Mostrar contexto posterior
	var verse = verses_data[current_verse]
	var after_ctx = paper_panel.get_node_or_null("AfterContext")
	if after_ctx:
		is_typing = true
		await _typewrite(after_ctx, verse.get("context_after", ""))
		is_typing = false

	current_verse += 1
	await get_tree().create_timer(1.0).timeout
	_show_next_verse()


func _finish_poem():
	# Ocultar opciones
	for btn in option_buttons:
		btn.visible = false
	gap_indicator.visible = false

	# Reacción de Cristian según resonance_score
	var reaction = ""
	if resonance_score >= 3:
		reaction = "Cristian releyó sus versos y esbozó una leve sonrisa. 'Quizás sí hay esperanza.'"
	elif resonance_score <= -3:
		reaction = "Cristian cerró el diario con fuerza. '¿A quién engaño?'"
	else:
		reaction = "Cristian releyó sus versos en silencio. Asintió despacio, sin saber muy bien qué pensar."

	reaction_label.text = reaction
	reaction_label.visible = true

	await get_tree().create_timer(3.0).timeout
	emit_signal("poem_finished", resonance_score, chosen_texts)


func _typewrite(label: RichTextLabel, text: String):
	label.text = ""
	label.visible_characters = 0
	label.text = text
	for i in range(text.length()):
		label.visible_characters = i + 1
		AudioManager.play_sfx("sfx_diary_write")
		await get_tree().create_timer(TYPEWRITER_SPEED).timeout
	label.visible_characters = -1
