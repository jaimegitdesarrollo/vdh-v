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
	TransitionManager.change_scene("res://scenes/chapters/chapter1/ch1_end.tscn")


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
	_add_wall("WallBottom", OFFSET + Vector2(0, ROOM_PX_H - wt), Vector2(ROOM_PX_W, wt))
	_add_wall("WallLeft", OFFSET, Vector2(wt, ROOM_PX_H))
	_add_wall("WallRight", OFFSET + Vector2(ROOM_PX_W - wt, 0), Vector2(wt, ROOM_PX_H))


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


func _build_furniture():
	# Bed
	_add_furniture("Bed", OFFSET + Vector2(12, 16), Vector2(32, 24),
		"res://assets/sprites/tiles/bed.png")
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
	# Diary on desk — custom interaction
	var diary := _add_interactable("Diary", OFFSET + Vector2(126, 18), Vector2(10, 8), Color(0.9, 0.8, 0.5),
		"item", "", "")
	diary.interacted.connect(_on_diary_interacted)

	# Bed (non-interactable furniture is already added above)
	# Guitar (just viewable at night, no special effect)
	_add_interactable("Guitar", OFFSET + Vector2(48, 24), Vector2(8, 16), Color(0.6, 0.35, 0.15),
		"dialogue", "interact_guitar", "")

	# Poster
	_add_interactable("Poster", OFFSET + Vector2(72, 2), Vector2(16, 10), Color(0.85, 0.2, 0.2),
		"dialogue", "interact_poster", "")


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
