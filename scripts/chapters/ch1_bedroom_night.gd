extends Node2D
## Ch1 Bedroom Night — Same bedroom with dark warm night tint.
## Diary on desk triggers DiaryScene. PersonaFlash auto-triggers after 3 seconds.
## On diary_finished, transitions to ch1_end.
## Uses tiled sprites for floor/walls, Sprite2D for furniture.

const TILE := 16
const ROOM_W := 10
const ROOM_H := 8
const ROOM_PX_W := ROOM_W * TILE # 160
const ROOM_PX_H := ROOM_H * TILE # 128

const OFFSET := Vector2(80, 26)

var player: CharacterBody2D
var diary_scene_instance: Control = null
var poem_done: bool = false


func _ready():
	# ---- Night tint ----
	modulate = Color(0.75, 0.55, 0.35) # dark orange/warm night

	# ---- Manager setup ----
	DialogueManager.load_dialogues("res://data/dialogues/chapter1.json")
	GameManager.set_exploration_scene("res://scenes/chapters/chapter1/ch1_bedroom_night.tscn")

	# ---- Build room ----
	_build_floor()
	_build_walls()
	_build_furniture()
	_build_interactables()

	# ---- Player ----
	player = _instance_scene("res://scenes/player/player.tscn")
	player.position = OFFSET + Vector2(ROOM_PX_W / 2.0, ROOM_PX_H / 2.0)
	player.can_move = true
	add_child(player)

	# ---- Camera ----
	var cam := Camera2D.new()
	cam.name = "Camera2D"
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	player.add_child(cam)

	# ---- UI instances ----
	add_child(_instance_scene("res://scenes/ui/hud.tscn"))
	add_child(_instance_scene("res://scenes/ui/dialogue_box.tscn"))
	add_child(_instance_scene("res://scenes/ui/persona_flash.tscn"))

	# ---- PersonaFlash auto-trigger after 3 seconds ----
	_schedule_persona_flash()


func _schedule_persona_flash():
	await get_tree().create_timer(3.0).timeout
	var flash_node = get_tree().get_first_node_in_group("persona_flash")
	if flash_node and flash_node.has_method("trigger_flash"):
		flash_node.trigger_flash("Casi me desnudan...")


# ---------------------------------------------------------------------------
# Diary interaction
# ---------------------------------------------------------------------------
func _on_diary_interacted():
	if diary_scene_instance != null:
		return # already showing

	if player:
		player.can_move = false

	# Show diary dialogue first
	DialogueManager.start_dialogue("bedroom_evening_diary")
	DialogueManager.dialogue_ended.connect(_on_diary_dialogue_done, CONNECT_ONE_SHOT)


func _on_diary_dialogue_done():
	# Create DiaryScene as a CanvasLayer child for overlay
	var diary_script = load("res://scripts/ui/diary_scene.gd")
	diary_scene_instance = Control.new()
	diary_scene_instance.set_script(diary_script)
	diary_scene_instance.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Wrap in a CanvasLayer so it renders above everything
	var diary_layer := CanvasLayer.new()
	diary_layer.name = "DiaryLayer"
	diary_layer.layer = 50
	diary_layer.add_child(diary_scene_instance)
	add_child(diary_layer)

	# Wait a frame for _ready to execute
	await get_tree().process_frame
	diary_scene_instance.diary_finished.connect(_on_diary_finished)
	diary_scene_instance.start_diary(1)


func _on_diary_finished():
	poem_done = true
	# Clean up diary overlay
	var diary_layer = diary_scene_instance.get_parent()
	if diary_layer:
		diary_layer.queue_free()
	diary_scene_instance = null
	if player:
		player.can_move = true


# ---------------------------------------------------------------------------
# Bed interaction
# ---------------------------------------------------------------------------
func _on_bed_interacted():
	if player:
		player.can_move = false

	if poem_done:
		DialogueManager.start_dialogue("bedroom_night_bed_sleep")
		DialogueManager.dialogue_ended.connect(_on_bed_sleep_done, CONNECT_ONE_SHOT)
	else:
		DialogueManager.start_dialogue("bedroom_night_bed_blocked")
		DialogueManager.dialogue_ended.connect(_on_bed_blocked_done, CONNECT_ONE_SHOT)


func _on_bed_sleep_done():
	_show_chapter_end()


func _on_bed_blocked_done():
	if player:
		player.can_move = true


# ---------------------------------------------------------------------------
# Chapter end sequence
# ---------------------------------------------------------------------------
func _show_chapter_end():
	var end_layer := CanvasLayer.new()
	end_layer.name = "ChapterEndLayer"
	end_layer.layer = 90
	add_child(end_layer)

	# Black overlay — starts transparent, fades in
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	end_layer.add_child(bg)

	# "Ah, es hora de acostarse..." text
	var thought_label := Label.new()
	thought_label.text = "Ah, es hora de acostarse...\nTodo cambiará."
	thought_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thought_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	thought_label.set_anchors_preset(Control.PRESET_CENTER)
	thought_label.offset_left = -120
	thought_label.offset_right = 120
	thought_label.offset_top = -20
	thought_label.offset_bottom = 20
	thought_label.add_theme_font_size_override("font_size", 11)
	thought_label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6))
	thought_label.modulate.a = 0.0
	end_layer.add_child(thought_label)

	# Fade in thought text
	var tween := create_tween()
	tween.tween_property(thought_label, "modulate:a", 1.0, 1.5)
	await tween.finished
	await get_tree().create_timer(2.5).timeout

	# Fade out thought + fade in black
	var tween2 := create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(thought_label, "modulate:a", 0.0, 1.0)
	tween2.tween_property(bg, "color:a", 1.0, 1.5)
	await tween2.finished
	thought_label.queue_free()

	await get_tree().create_timer(1.0).timeout

	# Chapter end title
	var title_label := Label.new()
	title_label.text = "FIN CAPÍTULO 1"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_preset(Control.PRESET_CENTER)
	title_label.offset_left = -140
	title_label.offset_right = 140
	title_label.offset_top = -20
	title_label.offset_bottom = 0
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7))
	title_label.modulate.a = 0.0
	end_layer.add_child(title_label)

	# Subtitle
	var sub_label := Label.new()
	sub_label.text = "TODO CAMBIARÁ"
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sub_label.set_anchors_preset(Control.PRESET_CENTER)
	sub_label.offset_left = -140
	sub_label.offset_right = 140
	sub_label.offset_top = 5
	sub_label.offset_bottom = 25
	sub_label.add_theme_font_size_override("font_size", 12)
	sub_label.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5))
	sub_label.modulate.a = 0.0
	end_layer.add_child(sub_label)

	# Fade in titles
	var tween3 := create_tween()
	tween3.set_parallel(true)
	tween3.tween_property(title_label, "modulate:a", 1.0, 2.0)
	tween3.tween_property(sub_label, "modulate:a", 1.0, 2.5).set_delay(0.5)
	await tween3.finished

	await get_tree().create_timer(3.0).timeout

	# Wait for input then go to main menu
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("confirm"):
			break

	TransitionManager.change_scene("res://scenes/main_menu.tscn")


# ---------------------------------------------------------------------------
# Room building
# ---------------------------------------------------------------------------
func _build_floor():
	var floor_rect := TextureRect.new()
	floor_rect.name = "Floor"
	floor_rect.texture = load("res://assets/sprites/tiles/floor_wood.png")
	floor_rect.stretch_mode = TextureRect.STRETCH_TILE
	floor_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor_rect.position = OFFSET
	floor_rect.size = Vector2(ROOM_PX_W, ROOM_PX_H)
	floor_rect.z_index = -10
	add_child(floor_rect)


func _build_walls():
	var wt := 8.0

	_add_wall("WallTop", OFFSET, Vector2(ROOM_PX_W, wt))
	# Bottom wall with door gap (door is visible but blocked)
	var door_x := ROOM_PX_W / 2.0 - 12 # door gap 24px wide
	_add_wall("WallBottomLeft", OFFSET + Vector2(0, ROOM_PX_H - wt), Vector2(door_x, wt))
	_add_wall("WallBottomRight", OFFSET + Vector2(door_x + 24, ROOM_PX_H - wt), Vector2(ROOM_PX_W - door_x - 24, wt))
	_add_wall("WallLeft", OFFSET, Vector2(wt, ROOM_PX_H))
	_add_wall("WallRight", OFFSET + Vector2(ROOM_PX_W - wt, 0), Vector2(wt, ROOM_PX_H))
	# Door blocker — invisible collision so player can't walk through
	_add_door_blocker("DoorBlocker", OFFSET + Vector2(door_x, ROOM_PX_H - wt), Vector2(24, wt))


func _add_wall(wall_name: String, pos: Vector2, wall_size: Vector2):
	var wall := StaticBody2D.new()
	wall.name = wall_name
	wall.position = pos + wall_size / 2.0
	wall.collision_layer = 2
	wall.collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = wall_size
	shape.shape = rect_shape
	wall.add_child(shape)

	var visual := TextureRect.new()
	visual.texture = load("res://assets/sprites/tiles/wall_house.png")
	visual.stretch_mode = TextureRect.STRETCH_TILE
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.size = wall_size
	visual.position = -wall_size / 2.0
	wall.add_child(visual)

	add_child(wall)


func _add_door_blocker(blocker_name: String, pos: Vector2, blocker_size: Vector2):
	var body := StaticBody2D.new()
	body.name = blocker_name
	body.position = pos + blocker_size / 2.0
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = blocker_size
	shape.shape = rect_shape
	body.add_child(shape)
	add_child(body)


func _build_furniture():
	# Desk
	_add_furniture("Desk", OFFSET + Vector2(120, 16), Vector2(24, 16),
		"res://assets/sprites/tiles/desk.png")


func _add_furniture(furniture_name: String, pos: Vector2, furniture_size: Vector2, sprite_path: String):
	var body := StaticBody2D.new()
	body.name = furniture_name
	body.position = pos + furniture_size / 2.0
	body.collision_layer = 2
	body.collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = furniture_size
	shape.shape = rect_shape
	body.add_child(shape)

	var visual := Sprite2D.new()
	visual.texture = load(sprite_path)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(visual)

	add_child(body)


func _build_interactables():
	# Bed — custom interaction (blocks until poem is done)
	var bed := _add_interactable("Bed", OFFSET + Vector2(12, 16), Vector2(32, 24), Color.TRANSPARENT,
		"item", "", "",
		"res://assets/sprites/tiles/bed.png")
	bed.interacted.connect(_on_bed_interacted)

	# Door — bottom center (visible but blocked, shows dialogue)
	var door_pos := OFFSET + Vector2(ROOM_PX_W / 2.0 - 12, ROOM_PX_H - 6)
	_add_interactable("Door", door_pos, Vector2(24, 12), Color.TRANSPARENT,
		"dialogue", "bedroom_night_door", "",
		"res://assets/sprites/tiles/door_open.png")

	# Diary on desk — custom interaction
	var diary := _add_interactable("Diary", OFFSET + Vector2(126, 18), Vector2(10, 8), Color.TRANSPARENT,
		"item", "", "")
	diary.interacted.connect(_on_diary_interacted)
	_build_diary(OFFSET + Vector2(126, 18))

	# Guitar (just viewable at night, no special effect)
	_add_interactable("Guitar", OFFSET + Vector2(48, 16), Vector2(8, 20), Color.TRANSPARENT,
		"dialogue", "interact_guitar", "")
	_build_guitar(OFFSET + Vector2(48, 16))

	# Poster
	_add_interactable("Poster", OFFSET + Vector2(72, 2), Vector2(16, 12), Color.TRANSPARENT,
		"dialogue", "interact_poster", "")
	_build_poster(OFFSET + Vector2(72, 2))


func _add_interactable(obj_name: String, pos: Vector2, obj_size: Vector2, color: Color,
		type: String, dlg_id: String, target: String, sprite_path: String = "") -> Area2D:
	var interactable_script = load("res://scripts/interactable.gd")
	var area := Area2D.new()
	area.name = obj_name
	area.set_script(interactable_script)
	area.position = pos + obj_size / 2.0
	area.collision_layer = 2
	area.collision_mask = 0
	area.interaction_type = type
	area.dialogue_id = dlg_id
	area.target_scene = target

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = obj_size
	shape.shape = rect_shape
	area.add_child(shape)

	if sprite_path != "":
		var visual := Sprite2D.new()
		visual.texture = load(sprite_path)
		visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		visual.z_index = -1
		area.add_child(visual)
	else:
		var visual := ColorRect.new()
		visual.color = color
		visual.size = obj_size
		visual.position = -obj_size / 2.0
		visual.z_index = -1
		area.add_child(visual)

	add_child(area)
	return area


func _instance_scene(path: String) -> Node:
	var packed := load(path) as PackedScene
	if packed:
		return packed.instantiate()
	push_warning("Ch1BedroomNight: Could not load scene: " + path)
	return Node.new()


func _build_guitar(pos: Vector2):
	var c := Node2D.new(); c.name = "GuitarVisual"; c.position = pos
	_px(c, 3, 0, 2, 10, Color(0.55, 0.3, 0.12))
	_px(c, 2, 0, 1, 1, Color(0.75, 0.7, 0.6)); _px(c, 5, 0, 1, 1, Color(0.75, 0.7, 0.6))
	_px(c, 2, 2, 1, 1, Color(0.75, 0.7, 0.6)); _px(c, 5, 2, 1, 1, Color(0.75, 0.7, 0.6))
	_px(c, 3, 3, 2, 1, Color(0.8, 0.7, 0.5)); _px(c, 3, 6, 2, 1, Color(0.8, 0.7, 0.5))
	_px(c, 1, 10, 6, 4, Color(0.7, 0.35, 0.1)); _px(c, 0, 11, 8, 2, Color(0.7, 0.35, 0.1))
	_px(c, 1, 14, 6, 3, Color(0.65, 0.3, 0.08)); _px(c, 2, 17, 4, 1, Color(0.65, 0.3, 0.08))
	_px(c, 3, 12, 2, 2, Color(0.2, 0.1, 0.05))
	_px(c, 4, 1, 1, 13, Color(0.85, 0.8, 0.7, 0.6))
	add_child(c)

func _build_poster(pos: Vector2):
	var c := Node2D.new(); c.name = "PosterVisual"; c.position = pos
	_px(c, 0, 0, 16, 12, Color(0.15, 0.15, 0.3)); _px(c, 1, 1, 14, 10, Color(0.85, 0.2, 0.2))
	_px(c, 6, 2, 4, 2, Color(0.2, 0.35, 0.9)); _px(c, 5, 4, 6, 3, Color(0.2, 0.35, 0.9))
	_px(c, 4, 7, 8, 2, Color(0.15, 0.25, 0.75))
	_px(c, 2, 2, 1, 1, Color(1, 0.95, 0.3)); _px(c, 12, 3, 1, 1, Color(1, 0.95, 0.3))
	_px(c, 3, 8, 1, 1, Color(1, 0.95, 0.3)); _px(c, 13, 7, 1, 1, Color(1, 0.95, 0.3))
	_px(c, 2, 10, 12, 1, Color(1, 0.95, 0.3, 0.7))
	add_child(c)

func _build_diary(pos: Vector2):
	var c := Node2D.new(); c.name = "DiaryVisual"; c.position = pos
	_px(c, 0, 0, 10, 8, Color(0.75, 0.6, 0.35))  # cover
	_px(c, 1, 1, 8, 6, Color(0.9, 0.82, 0.55))    # pages
	_px(c, 0, 0, 1, 8, Color(0.6, 0.45, 0.25))    # spine
	_px(c, 2, 2, 6, 1, Color(0.4, 0.3, 0.2, 0.5)) # text line
	_px(c, 2, 4, 5, 1, Color(0.4, 0.3, 0.2, 0.5)) # text line
	_px(c, 2, 6, 4, 1, Color(0.4, 0.3, 0.2, 0.5)) # text line
	add_child(c)

func _px(parent: Node2D, x: int, y: int, w: int, h: int, color: Color):
	var r := ColorRect.new()
	r.position = Vector2(x, y); r.size = Vector2(w, h)
	r.color = color; r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
