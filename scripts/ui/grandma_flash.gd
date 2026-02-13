extends CanvasLayer
## GrandmaFlash — Warm sepia-toned text flash for grandma memory moments.
## Similar to PersonaFlash but with warm tones. Waits for player input to dismiss.

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

var _is_flashing: bool = false
var _waiting_input: bool = false
var _hint_label: Label = null


func _ready():
	layer = 90
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	add_to_group("grandma_flash")
	_setup_label_style()
	_create_hint_label()


func _setup_label_style():
	label.add_theme_color_override("font_color", Color(1.0, 0.97, 0.88))
	label.add_theme_color_override("font_outline_color", Color(0.25, 0.18, 0.08))
	label.add_theme_color_override("font_shadow_color", Color(0.15, 0.1, 0.0, 0.8))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_font_size_override("font_size", 13)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _create_hint_label():
	_hint_label = Label.new()
	_hint_label.text = "[ E ]"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_size_override("font_size", 11)
	_hint_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8, 0.6))
	_hint_label.add_theme_color_override("font_outline_color", Color(0.2, 0.15, 0.0, 0.5))
	_hint_label.add_theme_constant_override("outline_size", 2)
	_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_label.offset_top = -25.0
	_hint_label.offset_bottom = -8.0
	_hint_label.visible = false
	color_rect.add_child(_hint_label)


func _input(event: InputEvent):
	if not _waiting_input:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
		_dismiss()
		get_viewport().set_input_as_handled()


func trigger(phrase: String):
	if _is_flashing:
		return
	_is_flashing = true

	label.text = phrase
	label.rotation_degrees = randf_range(-5.0, 5.0)

	color_rect.color = Color(0.6, 0.5, 0.3, 0.85)
	label.modulate = Color(1.0, 0.97, 0.88, 0.0)
	label.scale = Vector2(1.2, 1.2)
	if _hint_label:
		_hint_label.visible = false
		_hint_label.modulate.a = 0.0

	visible = true
	get_tree().paused = true
	_waiting_input = false

	# Flash in
	var tween_in := create_tween()
	tween_in.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_in.set_parallel(true)
	tween_in.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15)
	tween_in.tween_property(label, "modulate:a", 1.0, 0.15)
	await tween_in.finished

	# Show hint after a brief delay
	if _hint_label:
		_hint_label.visible = true
		var hint_tween := create_tween()
		hint_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		hint_tween.tween_property(_hint_label, "modulate:a", 1.0, 0.3)

	_waiting_input = true


func _dismiss():
	_waiting_input = false

	# Flash out
	var tween_out := create_tween()
	tween_out.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(label, "modulate:a", 0.0, 0.2)
	await tween_out.finished

	visible = false
	get_tree().paused = false
	_is_flashing = false
