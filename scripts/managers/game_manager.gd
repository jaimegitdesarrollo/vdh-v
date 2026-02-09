extends Node
## GameManager — Autoload Singleton
## Controla el estado global del juego, progresión y coleccionables.

# Estado del juego
var current_chapter: int = 1
var current_exploration_scene: String = ""
var game_started: bool = false

# Corazones por capítulo
var max_hearts_by_chapter: Dictionary = {
	1: 9, 2: 8, 3: 7, 4: 6, 5: 5, 6: 4, 7: 3, 8: 1
}

# Coleccionables
var collected_items: Dictionary = {} # item_id: true
var comic_pages_count: int = 0
var grandma_memories_count: int = 0

# Flags de progresión del capítulo
var chapter_flags: Dictionary = {}

# Referencia al jugador
var player_ref: CharacterBody2D = null

signal item_collected(item_id: String, item_type: String)
signal chapter_started(chapter: int)
signal chapter_ended(chapter: int)


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	chapter_ended.connect(_on_chapter_ended)


func start_new_game():
	current_chapter = 1
	collected_items.clear()
	comic_pages_count = 0
	grandma_memories_count = 0
	chapter_flags.clear()
	game_started = true
	emit_signal("chapter_started", current_chapter)


func get_max_hearts() -> int:
	return max_hearts_by_chapter.get(current_chapter, 9)


func is_collected(item_id: String) -> bool:
	return collected_items.has(item_id)


func collect_item(item_id: String, item_type: String):
	if collected_items.has(item_id):
		return
	collected_items[item_id] = true
	match item_type:
		"comic_page":
			comic_pages_count += 1
			if comic_pages_count % 5 == 0 and player_ref:
				player_ref.get_node("HealthSystem").add_bonus_heart(0.5)
		"grandma_memory":
			grandma_memories_count += 1
	emit_signal("item_collected", item_id, item_type)


func set_flag(flag_name: String, value: bool = true):
	chapter_flags[flag_name] = value


func get_flag(flag_name: String) -> bool:
	return chapter_flags.get(flag_name, false)


func _on_chapter_ended(chapter: int):
	current_chapter = chapter + 1


func set_exploration_scene(scene_path: String):
	current_exploration_scene = scene_path


func screen_shake(intensity: float = 3.0, duration: float = 0.3):
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return
	var original_offset = camera.offset
	var tween = create_tween()
	var steps = int(duration / 0.05)
	for i in range(steps):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", original_offset + offset, 0.05)
	tween.tween_property(camera, "offset", original_offset, 0.05)
