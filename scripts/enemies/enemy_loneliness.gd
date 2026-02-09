extends "res://scripts/enemies/enemy_base.gd"
## EnemyLoneliness — Silueta gris que aparece si el jugador está quieto 3s.
## Velocidad: 80 px/s (dash), daño: 1 corazón

var idle_timer: float = 0.0
@export var appear_delay: float = 3.0
var has_appeared: bool = false


func _ready():
	speed = 80.0
	damage = 1.0
	detection_range = 200.0
	enemy_type = "loneliness"
	spritesheet_path = "res://assets/sprites/enemies/soledad_spritesheet.png"
	sprite_path = "res://assets/sprites/enemies/enemy_loneliness.png"
	super._ready()
	# Empieza invisible
	visible = false
	set_physics_process(true)
	# Desactivar colisión hasta que aparezca
	_set_collision_enabled(false)


func _physics_process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	if not has_appeared:
		# Comprobar si el jugador está quieto
		if player.velocity.length() < 5.0:
			idle_timer += delta
			if idle_timer >= appear_delay:
				_appear()
		else:
			idle_timer = 0.0
	else:
		super._physics_process(delta)


func _appear():
	has_appeared = true
	visible = true
	state = "CHASE"
	_set_collision_enabled(true)
	# Efecto de aparición
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.6, 0.5)


func _set_collision_enabled(enabled: bool):
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = not enabled
		elif child is Area2D:
			for sub in child.get_children():
				if sub is CollisionShape2D:
					sub.disabled = not enabled
