extends CharacterBody2D
## Pedestrian — NPC peatón animado que camina entre waypoints.
## Tiene colisión (obstáculo para jugador y enemigos) y spritesheet animado.

@export var walk_speed: float = 25.0

var waypoints: Array[Vector2] = []
var current_wp: int = 0
var wait_timer: float = 0.0
var facing: String = "down"
var is_moving: bool = false

var sheet_path: String = ""
var animated_sprite: AnimatedSprite2D


func setup(spritesheet: String, points: Array[Vector2], spd: float = 25.0):
	sheet_path = spritesheet
	waypoints = points
	walk_speed = spd


func _ready():
	collision_layer = 16   # Pedestrian-only layer (not wall layer 2)
	collision_mask = 0
	_build_visual()

	if waypoints.size() >= 2:
		position = waypoints[0]
		current_wp = 1


func _physics_process(delta: float):
	if waypoints.size() < 2:
		return

	# Waiting at waypoint
	if wait_timer > 0.0:
		wait_timer -= delta
		if is_moving:
			is_moving = false
			_play_anim("idle_" + facing)
		return

	var target := waypoints[current_wp]
	var diff := target - position
	var dist := diff.length()

	if dist < 2.0:
		# Arrived at waypoint — wait briefly then move to next
		wait_timer = randf_range(0.5, 2.0)
		current_wp = (current_wp + 1) % waypoints.size()
		return

	var dir := diff.normalized()
	velocity = dir * walk_speed
	_update_facing(dir)

	if not is_moving:
		is_moving = true
		_play_anim("walk_" + facing)

	move_and_slide()


func _update_facing(dir: Vector2):
	var old_facing := facing
	if abs(dir.x) > abs(dir.y):
		facing = "right" if dir.x > 0 else "left"
	else:
		facing = "down" if dir.y > 0 else "up"
	if facing != old_facing and is_moving:
		_play_anim("walk_" + facing)


func _play_anim(anim_name: String):
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation(anim_name):
			if animated_sprite.animation != anim_name:
				animated_sprite.play(anim_name)


func _build_visual():
	# Collision shape
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 14)
	shape.shape = rect
	shape.position = Vector2(0, 4)
	add_child(shape)

	# Animated sprite from spritesheet
	var sheet: Texture2D = load(sheet_path) if sheet_path != "" else null
	if sheet == null:
		return

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	const FW: int = 32
	const FH: int = 32
	var dir_rows: Dictionary = {"down": 0, "up": 1, "left": 2, "right": 3}

	for dir_name in ["down", "up", "left", "right"]:
		var row: int = dir_rows[dir_name]

		var idle_name: String = "idle_" + dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 6)
		frames.set_animation_loop(idle_name, true)
		frames.add_frame(idle_name, _atlas(sheet, 0, row))

		var walk_name: String = "walk_" + dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, 6)
		frames.set_animation_loop(walk_name, true)
		frames.add_frame(walk_name, _atlas(sheet, 0, row))  # idle
		frames.add_frame(walk_name, _atlas(sheet, 1, row))  # step1
		frames.add_frame(walk_name, _atlas(sheet, 0, row))  # idle
		frames.add_frame(walk_name, _atlas(sheet, 2, row))  # step2

	animated_sprite = AnimatedSprite2D.new()
	animated_sprite.name = "AnimatedSprite2D"
	animated_sprite.sprite_frames = frames
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	animated_sprite.scale = Vector2(0.65, 0.65)
	animated_sprite.play("idle_down")
	add_child(animated_sprite)


func _atlas(sheet: Texture2D, col: int, row: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = sheet
	at.region = Rect2(col * 32, row * 32, 32, 32)
	at.filter_clip = true
	return at
