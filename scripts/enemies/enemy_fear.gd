extends "res://scripts/enemies/enemy_base.gd"
## EnemyFear — Sombra oscura que persigue lentamente.
## Velocidad: 60 px/s, daño: 0.5 corazón


func _ready():
	speed = 60.0
	damage = 0.5
	detection_range = 150.0
	enemy_type = "fear"
	spritesheet_path = "res://assets/sprites/enemies/miedo_spritesheet.png"
	sprite_path = "res://assets/sprites/enemies/enemy_fear.png"
	super._ready()
