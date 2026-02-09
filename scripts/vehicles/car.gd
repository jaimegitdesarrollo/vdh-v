extends Node2D
## Car — Animated vehicle that drives along a road lane.
## Deals damage to the player on contact and wraps around the map edges.

@export var car_speed: float = 60.0
@export var drive_direction: int = 1  # 1 = right, -1 = left
@export var damage: float = 1.0
@export var map_width: float = 880.0

var _anim_sprite: AnimatedSprite2D = null
var _hitbox: Area2D = null
var _spritesheet_path: String = ""
var _fallback_tex: Texture2D = null
var _dir_name: String = "right"

const FW: int = 24
const FH: int = 24


func setup(spritesheet: String, fallback: Texture2D, spd: float, dir: int, map_w: float):
	_spritesheet_path = spritesheet
	_fallback_tex = fallback
	car_speed = spd
	drive_direction = dir
	map_width = map_w
	_dir_name = "right" if dir > 0 else "left"


var _horn_timer: float = 0.0
var _next_horn: float = 0.0


func _ready():
	_setup_sprite()
	_setup_hitbox()
	_next_horn = randf_range(5.0, 20.0)


func _physics_process(delta: float):
	position.x += car_speed * drive_direction * delta

	# Wrap around map edges (margin accounts for sprite size x2)
	if drive_direction > 0 and position.x > map_width + 40:
		position.x = -40.0
	elif drive_direction < 0 and position.x < -40:
		position.x = map_width + 40.0

	# Honk only when player is close to this car's lane (crossing the road)
	_horn_timer += delta
	if _horn_timer >= _next_horn:
		_horn_timer = 0.0
		_next_horn = randf_range(8.0, 25.0)
		var p = get_tree().get_first_node_in_group("player")
		if p and abs(p.global_position.y - global_position.y) < 30.0 and abs(p.global_position.x - global_position.x) < 120.0:
			AudioManager.play_sfx("sfx_car_horn_short")


func _setup_sprite():
	var sheet: Texture2D = load(_spritesheet_path) if _spritesheet_path != "" else null
	if sheet != null:
		_anim_sprite = AnimatedSprite2D.new()
		_anim_sprite.name = "CarSprite"
		_anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var frames := SpriteFrames.new()
		if frames.has_animation("default"):
			frames.remove_animation("default")

		# Spritesheet: 48x96, 2 cols (Idle, Moving) × 4 rows (Down, Up, Left, Right)
		var rows := {"down": 0, "up": 1, "left": 2, "right": 3}
		for d in rows:
			var row: int = rows[d]
			# Idle animation (1 frame)
			var idle_anim: String = "idle_" + d
			frames.add_animation(idle_anim)
			frames.set_animation_speed(idle_anim, 4)
			frames.set_animation_loop(idle_anim, true)
			var at_idle := AtlasTexture.new()
			at_idle.atlas = sheet
			at_idle.region = Rect2(0, row * FH, FW, FH)
			at_idle.filter_clip = true
			frames.add_frame(idle_anim, at_idle)

			# Moving animation (2 frames: idle + moving for a wobble effect)
			var move_anim: String = "move_" + d
			frames.add_animation(move_anim)
			frames.set_animation_speed(move_anim, 6)
			frames.set_animation_loop(move_anim, true)
			var at0 := AtlasTexture.new()
			at0.atlas = sheet
			at0.region = Rect2(0, row * FH, FW, FH)
			at0.filter_clip = true
			frames.add_frame(move_anim, at0)
			var at1 := AtlasTexture.new()
			at1.atlas = sheet
			at1.region = Rect2(FW, row * FH, FW, FH)
			at1.filter_clip = true
			frames.add_frame(move_anim, at1)

		_anim_sprite.sprite_frames = frames
		_anim_sprite.play("move_" + _dir_name)
		_anim_sprite.scale = Vector2(2.0, 2.0)
		add_child(_anim_sprite)
	elif _fallback_tex:
		# Fallback: use the old static sprite
		var sp := Sprite2D.new()
		sp.name = "CarSprite"
		sp.texture = _fallback_tex
		sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sp.scale = Vector2(2.0, 2.0)
		add_child(sp)


func _setup_hitbox():
	_hitbox = Area2D.new()
	_hitbox.name = "CarHitbox"
	_hitbox.collision_layer = 4  # Enemy layer
	_hitbox.collision_mask = 1   # Detect player
	_hitbox.monitoring = true
	_hitbox.monitorable = false
	add_child(_hitbox)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 32)
	shape.shape = rect
	_hitbox.add_child(shape)

	_hitbox.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		# Strong knockback away from car direction
		if body.has_method("_apply_car_knockback"):
			body._apply_car_knockback(Vector2(drive_direction, -0.5).normalized(), car_speed)
