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
	# Bottom wall (with gap for door visual, but blocked by invisible collision)
	var door_x := ROOM_PX_W / 2.0 - 12 # door gap 24px wide
	_add_wall("WallBottomLeft", OFFSET + Vector2(0, ROOM_PX_H - wall_thickness), Vector2(door_x, wall_thickness))
	_add_wall("WallBottomRight", OFFSET + Vector2(door_x + 24, ROOM_PX_H - wall_thickness), Vector2(ROOM_PX_W - door_x - 24, wall_thickness))
	# Left wall
	_add_wall("WallLeft", OFFSET + Vector2(0, 0), Vector2(wall_thickness, ROOM_PX_H))
	# Right wall
	_add_wall("WallRight", OFFSET + Vector2(ROOM_PX_W - wall_thickness, 0), Vector2(wall_thickness, ROOM_PX_H))
	# Door blocker — invisible collision so player can't walk through
	_add_door_blocker("DoorBlocker", OFFSET + Vector2(door_x, ROOM_PX_H - wall_thickness), Vector2(24, wall_thickness))


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
	_add_interactable("Door", door_pos, Vector2(24, 12), Color.TRANSPARENT,
		"transition", "", "res://scenes/chapters/chapter1/ch1_kitchen.tscn",
		"res://assets/sprites/tiles/door_open.png")

	# Guitar — left side, leaning against wall
	var guitar_pos := OFFSET + Vector2(48, 16)
	_add_interactable("Guitar", guitar_pos, Vector2(8, 20), Color.TRANSPARENT,
		"dialogue", "interact_guitar", "")
	_build_guitar(guitar_pos)

	# Comic book on shelf — right wall area
	var comic_pos := OFFSET + Vector2(140, 50)
	_add_interactable("ComicBook", comic_pos, Vector2(10, 8), Color.TRANSPARENT,
		"dialogue", "interact_comic", "")
	_build_comic(comic_pos)

	# Poster on wall — top wall
	var poster_pos := OFFSET + Vector2(72, 2)
	_add_interactable("Poster", poster_pos, Vector2(16, 12), Color.TRANSPARENT,
		"dialogue", "interact_poster", "")
	_build_poster(poster_pos)

	# Magic Man figure — on the desk
	var figure_pos := OFFSET + Vector2(128, 10)
	_add_interactable("MagicManFigure", figure_pos, Vector2(6, 10), Color.TRANSPARENT,
		"dialogue", "interact_figure", "")
	_build_figure(figure_pos)

	# Console — near the desk
	var console_pos := OFFSET + Vector2(110, 18)
	_build_console(console_pos)


func _build_guitar(pos: Vector2):
	var container := Node2D.new()
	container.name = "GuitarVisual"
	container.position = pos
	# Neck (long thin part)
	_px(container, 3, 0, 2, 10, Color(0.55, 0.3, 0.12))  # brown neck
	# Tuning pegs
	_px(container, 2, 0, 1, 1, Color(0.75, 0.7, 0.6))
	_px(container, 5, 0, 1, 1, Color(0.75, 0.7, 0.6))
	_px(container, 2, 2, 1, 1, Color(0.75, 0.7, 0.6))
	_px(container, 5, 2, 1, 1, Color(0.75, 0.7, 0.6))
	# Frets
	_px(container, 3, 3, 2, 1, Color(0.8, 0.7, 0.5))
	_px(container, 3, 6, 2, 1, Color(0.8, 0.7, 0.5))
	# Body (rounded shape with multiple rects)
	_px(container, 1, 10, 6, 4, Color(0.7, 0.35, 0.1))  # main body
	_px(container, 0, 11, 8, 2, Color(0.7, 0.35, 0.1))   # wider middle
	_px(container, 1, 14, 6, 3, Color(0.65, 0.3, 0.08))   # lower body
	_px(container, 2, 17, 4, 1, Color(0.65, 0.3, 0.08))   # bottom curve
	# Sound hole
	_px(container, 3, 12, 2, 2, Color(0.2, 0.1, 0.05))
	# Strings (thin line down center)
	_px(container, 4, 1, 1, 13, Color(0.85, 0.8, 0.7, 0.6))
	add_child(container)


func _build_comic(pos: Vector2):
	var container := Node2D.new()
	container.name = "ComicVisual"
	container.position = pos
	# Comic book cover
	_px(container, 0, 0, 10, 8, Color(0.9, 0.85, 0.2))  # yellow cover
	_px(container, 1, 1, 8, 6, Color(0.95, 0.9, 0.4))    # inner lighter
	# "M" for Magic Man
	_px(container, 2, 2, 1, 4, Color(0.2, 0.35, 0.85))   # M left
	_px(container, 3, 3, 1, 1, Color(0.2, 0.35, 0.85))   # M middle-left
	_px(container, 4, 4, 1, 1, Color(0.2, 0.35, 0.85))   # M center
	_px(container, 5, 3, 1, 1, Color(0.2, 0.35, 0.85))   # M middle-right
	_px(container, 6, 2, 1, 4, Color(0.2, 0.35, 0.85))   # M right
	# Spine
	_px(container, 0, 0, 1, 8, Color(0.8, 0.75, 0.15))
	add_child(container)


func _build_poster(pos: Vector2):
	var container := Node2D.new()
	container.name = "PosterVisual"
	container.position = pos
	# Poster background
	_px(container, 0, 0, 16, 12, Color(0.15, 0.15, 0.3))  # dark blue bg
	_px(container, 1, 1, 14, 10, Color(0.85, 0.2, 0.2))    # red inner
	# Magic Man silhouette (cape shape)
	_px(container, 6, 2, 4, 2, Color(0.2, 0.35, 0.9))   # head
	_px(container, 5, 4, 6, 3, Color(0.2, 0.35, 0.9))   # torso+cape
	_px(container, 4, 7, 8, 2, Color(0.15, 0.25, 0.75)) # cape spread
	# Stars
	_px(container, 2, 2, 1, 1, Color(1.0, 0.95, 0.3))
	_px(container, 12, 3, 1, 1, Color(1.0, 0.95, 0.3))
	_px(container, 3, 8, 1, 1, Color(1.0, 0.95, 0.3))
	_px(container, 13, 7, 1, 1, Color(1.0, 0.95, 0.3))
	# Text bar at bottom
	_px(container, 2, 10, 12, 1, Color(1.0, 0.95, 0.3, 0.7))
	add_child(container)


func _build_figure(pos: Vector2):
	var container := Node2D.new()
	container.name = "FigureVisual"
	container.position = pos
	# Base/pedestal
	_px(container, 1, 8, 4, 2, Color(0.3, 0.3, 0.35))
	# Legs
	_px(container, 2, 6, 1, 2, Color(0.2, 0.35, 0.85))
	_px(container, 4, 6, 1, 2, Color(0.2, 0.35, 0.85))
	# Body
	_px(container, 1, 3, 4, 3, Color(0.2, 0.4, 0.9))
	# Cape (side flare)
	_px(container, 0, 4, 1, 3, Color(0.7, 0.15, 0.15))
	_px(container, 5, 4, 1, 3, Color(0.7, 0.15, 0.15))
	# Head
	_px(container, 2, 1, 2, 2, Color(0.9, 0.75, 0.6))
	# Mask
	_px(container, 2, 1, 2, 1, Color(0.2, 0.35, 0.85))
	# Arm raised (heroic pose)
	_px(container, 5, 2, 1, 2, Color(0.2, 0.4, 0.9))
	_px(container, 5, 1, 1, 1, Color(0.9, 0.75, 0.6))
	add_child(container)


func _build_console(pos: Vector2):
	var container := Node2D.new()
	container.name = "ConsoleVisual"
	container.position = pos
	# TV/Monitor
	_px(container, 0, 0, 12, 9, Color(0.15, 0.15, 0.2))  # bezel
	_px(container, 1, 1, 10, 7, Color(0.1, 0.2, 0.15))    # screen off/dark
	# Screen glare
	_px(container, 2, 2, 3, 1, Color(0.15, 0.25, 0.2))
	# TV stand
	_px(container, 4, 9, 4, 1, Color(0.2, 0.2, 0.25))
	# Console box below
	_px(container, 2, 11, 8, 3, Color(0.12, 0.12, 0.15))
	# Console detail (power light off, disc slot)
	_px(container, 3, 12, 1, 1, Color(0.3, 0.1, 0.1))     # power light
	_px(container, 5, 12, 4, 1, Color(0.08, 0.08, 0.1))    # disc slot
	# Controller on floor
	_px(container, 0, 14, 4, 2, Color(0.18, 0.18, 0.22))   # controller body
	_px(container, 1, 14, 1, 1, Color(0.3, 0.3, 0.4))      # d-pad
	_px(container, 3, 14, 1, 1, Color(0.2, 0.5, 0.2))      # button
	# Cable from controller to console
	_px(container, 4, 14, 1, 1, Color(0.15, 0.15, 0.18))
	add_child(container)


## Pixel art helper — adds a tiny ColorRect to a container.
func _px(parent: Node2D, x: int, y: int, w: int, h: int, color: Color):
	var r := ColorRect.new()
	r.position = Vector2(x, y)
	r.size = Vector2(w, h)
	r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)


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
