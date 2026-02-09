extends CanvasLayer
## TransitionManager — Autoload Singleton
## Transiciones fade entre escenas.

signal transition_finished

@onready var color_rect: ColorRect = ColorRect.new()
var is_transitioning: bool = false


func _ready():
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(color_rect)


func change_scene(scene_path: String):
	if is_transitioning:
		return
	is_transitioning = true
	await _fade_to_black()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await _fade_from_black()
	is_transitioning = false
	emit_signal("transition_finished")


func return_from_battle():
	if GameManager.current_exploration_scene != "":
		change_scene(GameManager.current_exploration_scene)


func _fade_to_black(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished


func _fade_from_black(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished


func fade_to_black_only(duration: float = 0.5):
	await _fade_to_black(duration)


func fade_from_black_only(duration: float = 0.5):
	await _fade_from_black(duration)
