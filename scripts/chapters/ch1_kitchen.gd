extends Node2D
## Ch1 Kitchen — Small kitchen scene. Mom's post-it on the fridge.
## Builds the room with tiled sprites for floor/walls, then auto-triggers kitchen_postit dialogue.

const TILE := 16
const ROOM_W := 12 # tiles
const ROOM_H := 8  # tiles
const ROOM_PX_W := ROOM_W * TILE # 192
const ROOM_PX_H := ROOM_H * TILE # 128

const OFFSET := Vector2(64, 26)

var player: CharacterBody2D


func _ready():
	# ---- Manager setup ----
	DialogueManager.load_dialogues("res://data/dialogues/chapter1.json")
	GameManager.set_exploration_scene("res://scenes/chapters/chapter1/ch1_kitchen.tscn")
	# No music inside the house
	AudioManager.stop_music(0.0)

	# ---- Build room ----
	_build_floor()
	_build_walls()
	_build_furniture()
	_build_interactables()

	# ---- Player ----
	player = _instance_scene("res://scenes/player/player.tscn")
	player.position = OFFSET + Vector2(ROOM_PX_W / 2.0, ROOM_PX_H / 2.0 + 16)
	player.can_move = false
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

	# ---- Auto-trigger kitchen_postit after brief delay ----
	await get_tree().create_timer(0.5).timeout
	DialogueManager.start_dialogue("kitchen_postit")
	DialogueManager.dialogue_ended.connect(_on_kitchen_intro_ended, CONNECT_ONE_SHOT)


func _on_kitchen_intro_ended():
	if player:
		player.can_move = true


# ---------------------------------------------------------------------------
# Room building helpers
# ---------------------------------------------------------------------------
func _build_floor():
	var floor_rect := TextureRect.new()
	floor_rect.name = "Floor"
	floor_rect.texture = load("res://assets/sprites/tiles/floor_tile_kitchen.png")
	floor_rect.stretch_mode = TextureRect.STRETCH_TILE
	floor_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	floor_rect.position = OFFSET
	floor_rect.size = Vector2(ROOM_PX_W, ROOM_PX_H)
	floor_rect.z_index = -10
	add_child(floor_rect)


func _build_walls():
	var wt := 8.0 # wall thickness

	# Top wall (with gap for door visual, but blocked by invisible collision)
	var door_x := ROOM_PX_W / 2.0 - 12
	_add_wall("WallTopLeft", OFFSET, Vector2(door_x, wt))
	_add_wall("WallTopRight", OFFSET + Vector2(door_x + 24, 0), Vector2(ROOM_PX_W - door_x - 24, wt))
	# Bottom wall
	_add_wall("WallBottom", OFFSET + Vector2(0, ROOM_PX_H - wt), Vector2(ROOM_PX_W, wt))
	# Left wall
	_add_wall("WallLeft", OFFSET, Vector2(wt, ROOM_PX_H))
	# Right wall
	_add_wall("WallRight", OFFSET + Vector2(ROOM_PX_W - wt, 0), Vector2(wt, ROOM_PX_H))
	# Door blocker — invisible collision so player can't walk through
	_add_door_blocker("DoorBlocker", OFFSET + Vector2(door_x, 0), Vector2(24, wt))


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
	# Counter/Table — center-bottom area
	_add_furniture("Table", OFFSET + Vector2(80, 64), Vector2(32, 16),
		"res://assets/sprites/tiles/counter.png")


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
	# Fridge — left side
	_add_interactable("Fridge", OFFSET + Vector2(16, 24), Vector2(16, 24), Color(0.92, 0.92, 0.92),
		"dialogue", "kitchen_postit", "",
		"res://assets/sprites/tiles/fridge.png")

	# Door — top center gap (leads to street)
	# Area extends 28px into room so InteractionArea (offset y+8) can detect it
	var door_pos := OFFSET + Vector2(ROOM_PX_W / 2.0 - 12, -2)
	_add_interactable("DoorToStreet", door_pos, Vector2(24, 28), Color(0.45, 0.3, 0.15),
		"transition", "", "res://scenes/chapters/chapter1/ch1_street.tscn",
		"res://assets/sprites/tiles/door_open.png")


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
	push_warning("Ch1Kitchen: Could not load scene: " + path)
	return Node.new()
