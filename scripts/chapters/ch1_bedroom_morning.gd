extends Node2D
## Ch1 Bedroom Morning — Cristian's room, first scene of the game.
## Builds the room with tiled sprites for floor/walls and Sprite2D for furniture,
## interactable objects (guitar, comic, poster, figure, door).

const TILE := 16
const ROOM_W := 10 # tiles
const ROOM_H := 8  # tiles
const ROOM_PX_W := ROOM_W * TILE # 160
const ROOM_PX_H := ROOM_H * TILE # 128

# Room offset so it sits nicely in the 320x180 viewport
const OFFSET := Vector2(80, 26)

var player: CharacterBody2D
var intro_done := false


func _ready():
	# ---- Manager setup ----
	DialogueManager.load_dialogues("res://data/dialogues/chapter1.json")
	GameManager.set_exploration_scene("res://scenes/chapters/chapter1/ch1_bedroom_morning.tscn")
	# No music inside the house
	AudioManager.stop_music(0.5)

	# ---- Build room ----
	_build_floor()
	_build_walls()
	_build_furniture()
	_build_interactables()

	# ---- Player ----
	player = _instance_scene("res://scenes/player/player.tscn")
	player.position = OFFSET + Vector2(ROOM_PX_W / 2.0, ROOM_PX_H / 2.0)
	player.can_move = false
	add_child(player)

	# ---- Camera ----
	var cam := Camera2D.new()
	cam.name = "Camera2D"
	cam.zoom = Vector2(1, 1)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	player.add_child(cam)

	# ---- UI instances ----
	var hud := _instance_scene("res://scenes/ui/hud.tscn")
	add_child(hud)

	var dialogue_box := _instance_scene("res://scenes/ui/dialogue_box.tscn")
	add_child(dialogue_box)

	# ---- Intro dialogue ----
	await get_tree().create_timer(0.3).timeout
	DialogueManager.start_dialogue("bedroom_morning")
	DialogueManager.dialogue_ended.connect(_on_intro_ended, CONNECT_ONE_SHOT)


func _on_intro_ended():
	intro_done = true
	if player:
		player.can_move = true


# ---------------------------------------------------------------------------
# Room building helpers
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
	var wall_thickness := 8.0

	# Top wall
	_add_wall("WallTop", OFFSET + Vector2(0, 0), Vector2(ROOM_PX_W, wall_thickness))
	# Bottom wall (with gap for door)
	var door_x := ROOM_PX_W / 2.0 - 12 # door gap 24px wide
	_add_wall("WallBottomLeft", OFFSET + Vector2(0, ROOM_PX_H - wall_thickness), Vector2(door_x, wall_thickness))
	_add_wall("WallBottomRight", OFFSET + Vector2(door_x + 24, ROOM_PX_H - wall_thickness), Vector2(ROOM_PX_W - door_x - 24, wall_thickness))
	# Left wall
	_add_wall("WallLeft", OFFSET + Vector2(0, 0), Vector2(wall_thickness, ROOM_PX_H))
	# Right wall
	_add_wall("WallRight", OFFSET + Vector2(ROOM_PX_W - wall_thickness, 0), Vector2(wall_thickness, ROOM_PX_H))


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
	# Bed — top-left area
	_add_furniture("Bed", OFFSET + Vector2(12, 16), Vector2(32, 24),
		"res://assets/sprites/tiles/bed.png")

	# Desk with computer — top-right area
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
	# Door — bottom center (transition to kitchen)
	var door_pos := OFFSET + Vector2(ROOM_PX_W / 2.0 - 12, ROOM_PX_H - 6)
	_add_interactable("Door", door_pos, Vector2(24, 12), Color(0.45, 0.3, 0.15),
		"transition", "", "res://scenes/chapters/chapter1/ch1_kitchen.tscn",
		"res://assets/sprites/tiles/door_open.png")

	# Guitar — left side, near bed
	_add_interactable("Guitar", OFFSET + Vector2(48, 24), Vector2(8, 16), Color(0.6, 0.35, 0.15),
		"dialogue", "interact_guitar", "")

	# Comic book on shelf — right wall area
	_add_interactable("ComicBook", OFFSET + Vector2(140, 50), Vector2(8, 8), Color(0.9, 0.85, 0.2),
		"dialogue", "interact_comic", "")

	# Poster on wall — top wall
	_add_interactable("Poster", OFFSET + Vector2(72, 2), Vector2(16, 10), Color(0.85, 0.2, 0.2),
		"dialogue", "interact_poster", "")

	# Magic Man figure — on the desk
	_add_interactable("MagicManFigure", OFFSET + Vector2(128, 12), Vector2(6, 6), Color(0.2, 0.4, 0.9),
		"dialogue", "interact_figure", "")


func _add_interactable(obj_name: String, pos: Vector2, obj_size: Vector2, color: Color,
		type: String, dlg_id: String, target: String, sprite_path: String = ""):
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


func _instance_scene(path: String) -> Node:
	var packed := load(path) as PackedScene
	if packed:
		return packed.instantiate()
	push_warning("Ch1BedroomMorning: Could not load scene: " + path)
	return Node.new()
