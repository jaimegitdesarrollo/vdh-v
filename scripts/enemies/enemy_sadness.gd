extends "res://scripts/enemies/enemy_base.gd"
## EnemySadness — Gota/lágrima que se mueve en patrón fijo.
## Velocidad: 40 px/s, daño: 0.5 corazón

@export var patrol_radius: float = 60.0
var center_position: Vector2
var patrol_angle: float = 0.0


func _ready():
	speed = 40.0
	damage = 0.5
	detection_range = 100.0
	enemy_type = "sadness"
	spritesheet_path = "res://assets/sprites/enemies/tristeza_spritesheet.png"
	sprite_path = "res://assets/sprites/enemies/enemy_sadness.png"
	center_position = global_position
	super._ready()


func _patrol_behavior(delta):
	# Movimiento circular alrededor del punto central
	patrol_angle += delta * 1.2
	var target = center_position + Vector2(
		cos(patrol_angle) * patrol_radius,
		sin(patrol_angle) * patrol_radius
	)
	var dir = (target - global_position).normalized()
	velocity = dir * speed
	_update_facing(dir)
