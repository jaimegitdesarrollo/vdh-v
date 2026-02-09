extends CharacterBody2D
## EnemyBase — Clase base para enemigos mentales.
## Los enemigos son manifestaciones de los miedos de Cristian. NO son personas reales.

@export var speed: float = 60.0
@export var damage: float = 0.5
@export var detection_range: float = 150.0
@export var enemy_type: String = "fear"

var sprite_path: String = ""
var spritesheet_path: String = ""
var player: CharacterBody2D = null
var state: String = "IDLE" # IDLE, PATROL, CHASE
var _anim_sprite: AnimatedSprite2D = null
var _facing: String = "down"

@export var patrol_points: Array[Vector2] = []
var patrol_index: int = 0
var patrol_wait_timer: float = 0.0
var frozen: bool = false
var _patrol_audio: AudioStreamPlayer2D = null
var _appeared: bool = false


func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	_setup_sprite()
	_setup_audio()


func _setup_sprite():
	if spritesheet_path != "":
		var sheet: Texture2D = load(spritesheet_path)
		if sheet != null:
			# Animated spritesheet: 48x96, 3 cols × 4 rows, 16x24 frames
			# Cols: Idle, Anim1, Anim2 | Rows: Down, Up, Left, Right
			_anim_sprite = AnimatedSprite2D.new()
			_anim_sprite.name = "AnimSprite"
			_anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var frames := SpriteFrames.new()
			if frames.has_animation("default"):
				frames.remove_animation("default")
			const FW: int = 16
			const FH: int = 24
			var rows := {"down": 0, "up": 1, "left": 2, "right": 3}
			for dir_name in rows:
				var row: int = rows[dir_name]
				var anim_name: String = "pulse_" + dir_name
				frames.add_animation(anim_name)
				frames.set_animation_speed(anim_name, 4)
				frames.set_animation_loop(anim_name, true)
				for col in [0, 1, 2, 1]:  # idle → pulse1 → pulse2 → pulse1
					var at := AtlasTexture.new()
					at.atlas = sheet
					at.region = Rect2(col * FW, row * FH, FW, FH)
					at.filter_clip = true
					frames.add_frame(anim_name, at)
			_anim_sprite.sprite_frames = frames
			_anim_sprite.play("pulse_down")
			add_child(_anim_sprite)
			return
		# Spritesheet failed to load — fall through to single sprite fallback

	# Fallback: single sprite (old individual PNGs)
	if sprite_path != "" and not has_node("Sprite"):
		var tex: Texture2D = load(sprite_path)
		if tex:
			var sprite = Sprite2D.new()
			sprite.name = "Sprite"
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.texture = tex
			add_child(sprite)


func _physics_process(delta):
	if frozen:
		velocity = Vector2.ZERO
		return

	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	var distance = global_position.distance_to(player.global_position)

	# Only play patrol audio when player is close enough to hear
	if _patrol_audio:
		if distance < 120.0:
			if not _patrol_audio.playing:
				_patrol_audio.play()
		elif distance > 180.0:
			if _patrol_audio.playing:
				_patrol_audio.stop()

	match state:
		"IDLE":
			if distance < detection_range:
				state = "CHASE"
				if not _appeared:
					_appeared = true
					_play_appear_sfx()
			elif patrol_points.size() > 0:
				state = "PATROL"
		"PATROL":
			if distance < detection_range:
				state = "CHASE"
				if not _appeared:
					_appeared = true
					_play_appear_sfx()
			else:
				_patrol_behavior(delta)
		"CHASE":
			if distance > detection_range * 2.0:
				state = "IDLE"
			else:
				_chase_behavior(delta)

	move_and_slide()


func _chase_behavior(_delta):
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	_update_facing(dir)


func _patrol_behavior(delta):
	if patrol_points.size() == 0:
		velocity = Vector2.ZERO
		return

	var target = patrol_points[patrol_index]
	var dir = (target - global_position).normalized()
	velocity = dir * speed * 0.5

	if global_position.distance_to(target) < 5.0:
		patrol_wait_timer += delta
		velocity = Vector2.ZERO
		if patrol_wait_timer > 1.5:
			patrol_wait_timer = 0.0
			patrol_index = (patrol_index + 1) % patrol_points.size()


func _update_facing(dir: Vector2):
	if _anim_sprite == null:
		return
	var new_facing: String
	if abs(dir.x) >= abs(dir.y):
		new_facing = "right" if dir.x > 0 else "left"
	else:
		new_facing = "down" if dir.y > 0 else "up"
	if new_facing != _facing:
		_facing = new_facing
		var anim_name = "pulse_" + _facing
		if _anim_sprite.sprite_frames.has_animation(anim_name):
			_anim_sprite.play(anim_name)


func _setup_audio():
	# Patrol loop sound (spatial, only audible nearby — NOT autoplay)
	var patrol_sfx: String = "res://assets/audio/sfx/sfx_%s_patrol.ogg" % enemy_type
	if ResourceLoader.exists(patrol_sfx):
		_patrol_audio = AudioStreamPlayer2D.new()
		_patrol_audio.stream = load(patrol_sfx)
		_patrol_audio.max_distance = 150.0
		_patrol_audio.volume_db = -8.0
		_patrol_audio.autoplay = false
		add_child(_patrol_audio)


func _play_appear_sfx():
	var appear_sfx: String = "res://assets/audio/sfx/sfx_%s_appear.ogg" % enemy_type
	if ResourceLoader.exists(appear_sfx):
		var ap := AudioStreamPlayer2D.new()
		ap.stream = load(appear_sfx)
		ap.max_distance = 300.0
		add_child(ap)
		ap.play()
		ap.finished.connect(ap.queue_free)


func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		AudioManager.play_sfx("sfx_ghost_damage")
		AudioManager.duck_music(-20.0, 0.3)
		# Restore music after 1 second
		get_tree().create_timer(1.0).timeout.connect(func():
			AudioManager.unduck_music(0.5)
		)
