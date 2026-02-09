extends Node2D
## Ch1 Bedroom Evening — Same bedroom layout with warm orange tint.
## Guitar heals 0.5 heart. Comic triggers Magic Man minigame after dialogue.
## Includes PersonaFlash and GrandmaFlash instances.
## Uses tiled sprites for floor/walls, Sprite2D for furniture.

const TILE := 16
const ROOM_W := 10
const ROOM_H := 8
const ROOM_PX_W := ROOM_W * TILE # 160
const ROOM_PX_H := ROOM_H * TILE # 128

const OFFSET := Vector2(80, 26)

var player: CharacterBody2D
var guitar_used := false


func _ready():
	# ---- Evening tint ----
	modulate = Color(1.0, 0.85, 0.65) # warm orange evening

	# ---- Manager setup ----
	DialogueManager.load_dialogues("res://data/dialogues/chapter1.json")
	GameManager.set_exploration_scene("res://scenes/chapters/chapter1/ch1_bedroom_evening.tscn")

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
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	player.add_child(cam)

	# ---- UI instances ----
	add_child(_instance_scene("res://scenes/ui/hud.tscn"))
	add_child(_instance_scene("res://scenes/ui/dialogue_box.tscn"))
	add_child(_instance_scene("res://scenes/ui/persona_flash.tscn"))
	add_child(_instance_scene("res://scenes/ui/grandma_flash.tscn"))

	# ---- Evening intro dialogue ----
	await get_tree().create_timer(0.3).timeout
	DialogueManager.start_dialogue("bedroom_evening_intro")
	DialogueManager.dialogue_ended.connect(_on_evening_intro_ended, CONNECT_ONE_SHOT)


func _on_evening_intro_ended():
	if player:
		player.can_move = true


# ---------------------------------------------------------------------------
# Guitar interaction: heals 0.5 heart after dialogue
# ---------------------------------------------------------------------------
func _on_guitar_interacted():
	# The interactable script starts the dialogue via interaction_type="dialogue".
	# We listen for dialogue_ended to apply the heal afterwards.
	if guitar_used:
		return
	guitar_used = true
	DialogueManager.dialogue_ended.connect(_on_guitar_dialogue_done, CONNECT_ONE_SHOT)


func _on_guitar_dialogue_done():
	if player:
		var health_system = player.get_node_or_null("HealthSystem")
		if health_system:
			health_system.heal(0.5)


# ---------------------------------------------------------------------------
# Comic interaction: transitions to Magic Man level after dialogue
# ---------------------------------------------------------------------------
func _on_comic_interacted():
	DialogueManager.dialogue_ended.connect(_on_comic_dialogue_done, CONNECT_ONE_SHOT)


func _on_comic_dialogue_done():
	TransitionManager.change_scene("res://scenes/minigames/pong/ch1_magic_man_pong.tscn")


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
	# Bottom wall with door gap (door is blocked in evening — no exit)
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
	# Guitar — dialogue + heal (custom signal handling)
	var guitar := _add_interactable("Guitar", OFFSET + Vector2(48, 24), Vector2(8, 16), Color(0.6, 0.35, 0.15),
		"dialogue", "interact_guitar_evening", "")
	guitar.interacted.connect(_on_guitar_interacted)
	# We also need to detect when the dialogue-type interactable fires.
	# Since interaction_type is "dialogue", the interactable calls DialogueManager directly.
	# We hook into the Area2D's interact() being called indirectly via monitoring.
	# Instead, we connect to the guitar being entered by the interaction area.
	# Simpler approach: override by watching dialogue starts.
	_watch_dialogue_for_heal("interact_guitar_evening")

	# Console — dialogue only
	_add_interactable("Console", OFFSET + Vector2(120, 40), Vector2(16, 12), Color(0.2, 0.2, 0.2),
		"dialogue", "interact_console", "")

	# Comic book — dialogue, then transition to Magic Man
	var comic := _add_interactable("ComicBook", OFFSET + Vector2(140, 50), Vector2(8, 8), Color(0.9, 0.85, 0.2),
		"dialogue", "interact_comic_evening", "")
	_watch_dialogue_for_comic("interact_comic_evening")

	# Poster (still viewable)
	_add_interactable("Poster", OFFSET + Vector2(72, 2), Vector2(16, 10), Color(0.85, 0.2, 0.2),
		"dialogue", "interact_poster", "")

	# Magic Man figure
	_add_interactable("MagicManFigure", OFFSET + Vector2(128, 12), Vector2(6, 6), Color(0.2, 0.4, 0.9),
		"dialogue", "interact_figure", "")


## Watch for a specific dialogue to start, then connect heal on its end.
func _watch_dialogue_for_heal(target_dialogue_id: String):
	DialogueManager.dialogue_started.connect(func():
		if DialogueManager.dialogues.has(target_dialogue_id):
			# Check if the current dialogue matches by comparing lines arrays
			if DialogueManager.current_dialogue == DialogueManager.dialogues[target_dialogue_id]["lines"]:
				_on_guitar_interacted()
	)


## Watch for comic dialogue to start, then transition on its end.
func _watch_dialogue_for_comic(target_dialogue_id: String):
	DialogueManager.dialogue_started.connect(func():
		if DialogueManager.dialogues.has(target_dialogue_id):
			if DialogueManager.current_dialogue == DialogueManager.dialogues[target_dialogue_id]["lines"]:
				_on_comic_interacted()
	)


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
	push_warning("Ch1BedroomEvening: Could not load scene: " + path)
	return Node.new()
