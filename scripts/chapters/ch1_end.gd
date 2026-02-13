extends Node2D
## Ch1 End — Chapter 1 ending screen.
## "Capitulo 1" title fades in, "Todo Cambiara" subtitle, "Continuara..."
## After 5 seconds or interact/confirm pressed, returns to main menu.

var can_skip := false
var has_ended := false


func _ready():
	# ---- Black background ----
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -10
	# Use CanvasLayer for proper full-screen overlay
	var bg_layer := CanvasLayer.new()
	bg_layer.name = "BGLayer"
	bg_layer.layer = 0
	bg_layer.add_child(bg)
	add_child(bg_layer)

	# ---- Text layer ----
	var text_layer := CanvasLayer.new()
	text_layer.name = "TextLayer"
	text_layer.layer = 1
	add_child(text_layer)

	var container := Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	text_layer.add_child(container)

	# ---- Chapter title ----
	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Capitulo 1"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.offset_left = -100
	title.offset_right = 100
	title.offset_top = -30
	title.offset_bottom = -10
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title.modulate.a = 0.0
	container.add_child(title)

	# ---- Subtitle ----
	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "Todo Cambiara"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_CENTER)
	subtitle.offset_left = -100
	subtitle.offset_right = 100
	subtitle.offset_top = -5
	subtitle.offset_bottom = 15
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6, 1))
	subtitle.modulate.a = 0.0
	container.add_child(subtitle)

	# ---- Continue text ----
	var continue_label := Label.new()
	continue_label.name = "ContinueLabel"
	continue_label.text = "Continuara..."
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continue_label.set_anchors_preset(Control.PRESET_CENTER)
	continue_label.offset_left = -100
	continue_label.offset_right = 100
	continue_label.offset_top = 25
	continue_label.offset_bottom = 40
	continue_label.add_theme_font_size_override("font_size", 11)
	continue_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
	continue_label.modulate.a = 0.0
	container.add_child(continue_label)

	# ---- Animate ----
	await get_tree().create_timer(0.5).timeout

	# Title fade in
	var tween1 := create_tween()
	tween1.tween_property(title, "modulate:a", 1.0, 1.5)
	await tween1.finished

	await get_tree().create_timer(0.5).timeout

	# Subtitle fade in
	var tween2 := create_tween()
	tween2.tween_property(subtitle, "modulate:a", 1.0, 1.5)
	await tween2.finished

	await get_tree().create_timer(1.0).timeout

	# Continue fade in
	var tween3 := create_tween()
	tween3.tween_property(continue_label, "modulate:a", 1.0, 1.0)
	await tween3.finished

	can_skip = true

	# Auto-return to menu after 5 seconds
	await get_tree().create_timer(5.0).timeout
	_go_to_menu()


func _input(event: InputEvent):
	if not can_skip:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
		_go_to_menu()


func _go_to_menu():
	if has_ended:
		return
	has_ended = true
	GameManager.emit_signal("chapter_ended", 1)
	TransitionManager.change_scene("res://scenes/main_menu.tscn")
