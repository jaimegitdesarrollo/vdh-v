extends CharacterBody2D
## Player Controller — CharacterBody2D
## Movimiento 4 direcciones, interacción, daño e invencibilidad.

@export var speed: float = 120.0
const ACCELERATION: float = 800.0
const FRICTION: float = 1200.0

var direction: Vector2 = Vector2.ZERO
var can_move: bool = true
var facing: String = "down"
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

const INVINCIBILITY_DURATION: float = 1.5
const KNOCKBACK_DURATION: float = 0.25

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var interact_indicator: Label = null
var _debug_k_held: bool = false


func _ready():
	add_to_group("player")
	GameManager.player_ref = self
	_setup_placeholder_animations()
	_setup_interact_indicator()


func _physics_process(delta: float):
	_handle_debug(delta)
	_handle_invincibility(delta)
	_handle_movement(delta)
	_handle_animation()
	_handle_interaction()
	_update_interact_indicator()


# ---------------------------------------------------------------------------
# DEBUG: K congela/descongela enemigos
# ---------------------------------------------------------------------------
func _handle_debug(_delta: float):
	if Input.is_physical_key_pressed(KEY_K) and not _debug_k_held:
		_debug_k_held = true
		var enemies = get_tree().get_nodes_in_group("enemies")
		if enemies.size() == 0:
			return
		var new_frozen = not enemies[0].frozen
		for e in enemies:
			e.frozen = new_frozen
			if new_frozen:
				e.velocity = Vector2.ZERO
				e.modulate = Color(0.5, 0.5, 1.0, 0.5)
			else:
				e.modulate = Color.WHITE
	elif not Input.is_physical_key_pressed(KEY_K):
		_debug_k_held = false


# ---------------------------------------------------------------------------
# Movement
# ---------------------------------------------------------------------------
func _handle_movement(delta: float):
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# During knockback, override player input
	if knockback_timer > 0.0:
		velocity = knockback_velocity
		move_and_slide()
		return

	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		facing = _get_facing()
		# Accelerate towards target velocity
		var target_vel: Vector2 = direction * speed
		velocity = velocity.move_toward(target_vel, ACCELERATION * delta)
	else:
		# Decelerate quickly to zero (no sliding)
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()


func _get_facing() -> String:
	if abs(direction.x) >= abs(direction.y):
		if direction.x > 0:
			return "right"
		else:
			return "left"
	else:
		if direction.y > 0:
			return "down"
		else:
			return "up"
	return facing


func get_facing() -> String:
	return facing


# ---------------------------------------------------------------------------
# Animation
# ---------------------------------------------------------------------------
func _handle_animation():
	if animated_sprite.sprite_frames == null:
		return

	var anim_name: String
	if velocity.length() < 5.0:
		anim_name = "idle_" + facing
	else:
		anim_name = "walk_" + facing

	if animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
	else:
		# Fallback: try idle_down as the safest default
		if animated_sprite.sprite_frames.has_animation("idle_down"):
			if animated_sprite.animation != "idle_down":
				animated_sprite.play("idle_down")


# ---------------------------------------------------------------------------
# Interaction
# ---------------------------------------------------------------------------
func _handle_interaction():
	if Input.is_action_just_pressed("interact"):
		var overlapping: Array[Area2D] = interaction_area.get_overlapping_areas()
		if overlapping.is_empty():
			return

		# Find nearest interactable
		var nearest: Area2D = null
		var nearest_dist: float = INF
		for area in overlapping:
			if area.has_method("interact"):
				var dist: float = global_position.distance_to(area.global_position)
				if dist < nearest_dist:
					nearest_dist = dist
					nearest = area

		if nearest != null:
			nearest.interact()


# ---------------------------------------------------------------------------
# Health — damage & healing
# ---------------------------------------------------------------------------
func take_damage(amount: float):
	if is_invincible:
		return

	var health_system = get_node_or_null("HealthSystem")
	if health_system and health_system.has_method("take_damage"):
		health_system.take_damage(amount)

	# Flash red feedback
	_flash_red()

	# Screen shake on damage
	GameManager.screen_shake(4.0, 0.3)

	# Knockback — push away from last movement direction
	var knockback_dir: Vector2 = -direction if direction != Vector2.ZERO else Vector2.DOWN
	knockback_velocity = knockback_dir * speed * 2.5
	knockback_timer = KNOCKBACK_DURATION
	velocity = knockback_velocity
	move_and_slide()

	# Start invincibility frames
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION


func heal(amount: float):
	var health_system = get_node_or_null("HealthSystem")
	if health_system and health_system.has_method("heal"):
		health_system.heal(amount)


func _handle_invincibility(delta: float):
	# Decay knockback timer
	if knockback_timer > 0.0:
		knockback_timer -= delta
		knockback_velocity *= 0.9  # Decelerate knockback
		if knockback_timer <= 0.0:
			knockback_timer = 0.0
			knockback_velocity = Vector2.ZERO

	if not is_invincible:
		return

	invincibility_timer -= delta

	# Blink effect during invincibility
	if animated_sprite:
		animated_sprite.visible = fmod(invincibility_timer, 0.2) > 0.1

	if invincibility_timer <= 0.0:
		is_invincible = false
		invincibility_timer = 0.0
		if animated_sprite:
			animated_sprite.visible = true
			animated_sprite.modulate = Color.WHITE


func _apply_car_knockback(dir: Vector2, car_spd: float):
	knockback_velocity = dir * max(car_spd, speed) * 3.0
	knockback_timer = KNOCKBACK_DURATION * 2.0
	velocity = knockback_velocity
	move_and_slide()


func _flash_red():
	if animated_sprite:
		animated_sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
		# Reset modulate after a short delay via tween
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)


# ---------------------------------------------------------------------------
# Interaction indicator — floating "E" label above the player
# ---------------------------------------------------------------------------
func _setup_interact_indicator():
	interact_indicator = Label.new()
	interact_indicator.text = "E"
	interact_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_indicator.add_theme_font_size_override("font_size", 11)
	interact_indicator.add_theme_color_override("font_color", Color.WHITE)
	interact_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	interact_indicator.add_theme_constant_override("outline_size", 2)
	interact_indicator.position = Vector2(-4, -14)
	interact_indicator.visible = false
	add_child(interact_indicator)


func _update_interact_indicator():
	if interact_indicator == null or interaction_area == null:
		return
	var overlapping: Array[Area2D] = interaction_area.get_overlapping_areas()
	var has_interactable: bool = false
	for area in overlapping:
		if area.has_method("interact"):
			has_interactable = true
			break
	interact_indicator.visible = has_interactable


# ---------------------------------------------------------------------------
# Sprite animation setup — tries spritesheet first, falls back to individual PNGs
# ---------------------------------------------------------------------------
func _setup_placeholder_animations():
	if animated_sprite == null:
		return

	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var sheet: Texture2D = load("res://assets/sprites/player/cristian_spritesheet.png")
	if sheet != null:
		_setup_from_spritesheet(sheet)
	else:
		_setup_from_individual_frames()


func _setup_from_spritesheet(sheet: Texture2D):
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
		frames.set_animation_speed(idle_name, 8)
		frames.set_animation_loop(idle_name, true)
		frames.add_frame(idle_name, _atlas(sheet, 0, row, FW, FH))

		# Walk cycle: idle → step1 → idle → step2 (proper foot-to-foot)
		var walk_name: String = "walk_" + dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, 8)
		frames.set_animation_loop(walk_name, true)
		frames.add_frame(walk_name, _atlas(sheet, 0, row, FW, FH))  # idle
		frames.add_frame(walk_name, _atlas(sheet, 1, row, FW, FH))  # step1
		frames.add_frame(walk_name, _atlas(sheet, 0, row, FW, FH))  # idle
		frames.add_frame(walk_name, _atlas(sheet, 2, row, FW, FH))  # step2

	animated_sprite.sprite_frames = frames
	animated_sprite.scale = Vector2(0.5, 0.5)
	animated_sprite.play("idle_down")


func _setup_from_individual_frames():
	## Fallback: load individual frame PNGs (already imported by Godot)
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	var base := "res://assets/sprites/player/"
	for dir_name in ["down", "up", "left", "right"]:
		var idle_tex: Texture2D = load(base + "idle_" + dir_name + ".png")
		var walk1_tex: Texture2D = load(base + "walk_" + dir_name + "_1.png")
		var walk2_tex: Texture2D = load(base + "walk_" + dir_name + "_2.png")

		var idle_name: String = "idle_" + dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 8)
		frames.set_animation_loop(idle_name, true)
		if idle_tex:
			frames.add_frame(idle_name, idle_tex)

		# Walk cycle: idle → step1 → idle → step2
		var walk_name: String = "walk_" + dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, 8)
		frames.set_animation_loop(walk_name, true)
		if idle_tex:
			frames.add_frame(walk_name, idle_tex)
		if walk1_tex:
			frames.add_frame(walk_name, walk1_tex)
		if idle_tex:
			frames.add_frame(walk_name, idle_tex)
		if walk2_tex:
			frames.add_frame(walk_name, walk2_tex)

	animated_sprite.sprite_frames = frames
	animated_sprite.play("idle_down")


## Extract a single frame from a spritesheet as AtlasTexture.
func _atlas(sheet: Texture2D, col: int, row: int, fw: int, fh: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = sheet
	at.region = Rect2(col * fw, row * fh, fw, fh)
	at.filter_clip = true
	return at
