extends CanvasLayer
## PauseMenu — Menu de pausa in-game.
## Se activa con la accion "pause" (ESC). Pausa el arbol y muestra opciones.

var is_paused: bool = false

# UI nodes (built in code)
var overlay: ColorRect
var vbox: VBoxContainer
var title_label: Label
var btn_continue: Button
var btn_main_menu: Button


func _ready():
	layer = 95
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause"):
		if is_paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause():
	# Don't interrupt active dialogues
	if DialogueManager.is_active:
		return
	# Don't pause during scene transitions
	if TransitionManager.is_transitioning:
		return
	is_paused = true
	get_tree().paused = true
	visible = true
	btn_continue.grab_focus()


func _resume():
	is_paused = false
	get_tree().paused = false
	visible = false


func _on_continue_pressed():
	_resume()


func _on_main_menu_pressed():
	_resume()
	TransitionManager.change_scene("res://scenes/main_menu.tscn")


# ---------------------------------------------------------------------------
# UI Construction
# ---------------------------------------------------------------------------

func _build_ui():
	# Semi-transparent dark overlay
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# CenterContainer to hold the VBox
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	# VBoxContainer for title + buttons
	vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	center.add_child(vbox)

	# Panel background for the VBox
	var panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	panel_style.set_corner_radius_all(4)
	panel_style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	# Inner VBox inside the panel
	var inner_vbox := VBoxContainer.new()
	inner_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	inner_vbox.add_theme_constant_override("separation", 8)
	panel.add_child(inner_vbox)

	# Title
	title_label = Label.new()
	title_label.text = "PAUSA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	inner_vbox.add_child(title_label)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 6)
	inner_vbox.add_child(sep)

	# Buttons
	btn_continue = _create_button("Continuar")
	inner_vbox.add_child(btn_continue)

	btn_main_menu = _create_button("Menu Principal")
	inner_vbox.add_child(btn_main_menu)

	# Connect signals
	btn_continue.pressed.connect(_on_continue_pressed)
	btn_main_menu.pressed.connect(_on_main_menu_pressed)

	# Focus / hover highlighting
	btn_continue.focus_entered.connect(_on_button_focus_entered.bind(btn_continue))
	btn_continue.focus_exited.connect(_on_button_focus_exited.bind(btn_continue))
	btn_continue.mouse_entered.connect(_on_button_focus_entered.bind(btn_continue))
	btn_continue.mouse_exited.connect(_on_button_focus_exited.bind(btn_continue))

	btn_main_menu.focus_entered.connect(_on_button_focus_entered.bind(btn_main_menu))
	btn_main_menu.focus_exited.connect(_on_button_focus_exited.bind(btn_main_menu))
	btn_main_menu.mouse_entered.connect(_on_button_focus_entered.bind(btn_main_menu))
	btn_main_menu.mouse_exited.connect(_on_button_focus_exited.bind(btn_main_menu))

	# Focus neighbors so keyboard navigation wraps
	btn_continue.focus_neighbor_bottom = btn_main_menu.get_path()
	btn_main_menu.focus_neighbor_top = btn_continue.get_path()


func _create_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(100, 20)

	# Normal style
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.15, 0.2, 1.0)
	normal_style.set_corner_radius_all(3)
	normal_style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("normal", normal_style)

	# Hover style
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(0.25, 0.25, 0.3, 1.0)
	hover_style.set_corner_radius_all(3)
	hover_style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("hover", hover_style)

	# Focus style
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = Color(0.25, 0.25, 0.3, 1.0)
	focus_style.set_corner_radius_all(3)
	focus_style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("focus", focus_style)

	# Pressed style
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.3, 0.3, 0.35, 1.0)
	pressed_style.set_corner_radius_all(3)
	pressed_style.set_content_margin_all(4)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	# Text colors
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_font_size_override("font_size", 8)

	return btn


func _on_button_focus_entered(button: Button):
	button.add_theme_color_override("font_color", Color(1.0, 0.95, 0.2, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.2, 1.0))


func _on_button_focus_exited(button: Button):
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
