extends CharacterBody2D
## SoulHeart — Corazón rojo del jugador en combate Undertale.
## Se mueve con las flechas/WASD dentro del BattleBox.

@export var speed: float = 200.0
var box_rect: Rect2 = Rect2(0, 0, 320, 180)
var is_invincible: bool = false
var invincibility_timer: float = 0.0
const INVINCIBILITY_DURATION: float = 1.0


func _ready():
	add_to_group("soul")
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Add sprite visual using PNG
	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/ui/soul_heart.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)


func setup(rect: Rect2):
	box_rect = rect
	global_position = rect.get_center()


func _physics_process(delta):
	# Movimiento
	var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()

	# Clamp dentro del BattleBox
	global_position.x = clamp(global_position.x, box_rect.position.x + 5, box_rect.end.x - 5)
	global_position.y = clamp(global_position.y, box_rect.position.y + 5, box_rect.end.y - 5)

	# I-frames
	if is_invincible:
		invincibility_timer -= delta
		# Parpadeo
		visible = fmod(invincibility_timer, 0.15) > 0.075
		if invincibility_timer <= 0:
			is_invincible = false
			visible = true


func take_damage(amount: float):
	if is_invincible:
		return
	is_invincible = true
	invincibility_timer = INVINCIBILITY_DURATION

	# Notify battle parent (fear system) instead of direct health damage
	var battle = get_parent()
	if battle and battle.has_method("_on_soul_hit"):
		battle._on_soul_hit(amount)
	elif GameManager.player_ref:
		var hs = GameManager.player_ref.get_node_or_null("HealthSystem")
		if hs:
			hs.take_damage(amount)

	# Flash rojo
	modulate = Color.RED
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
