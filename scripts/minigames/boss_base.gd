extends Node2D
## BossBase — Clase base para bosses de Magic Man.

@export var max_hp: float = 10.0
@export var phases: int = 3
var current_hp: float = 10.0
var current_phase: int = 1

signal boss_defeated
signal phase_changed(new_phase: int)


func _ready():
	current_hp = max_hp


func hit(damage_amount: float):
	current_hp -= damage_amount
	_flash_white()
	if current_hp <= 0:
		_die()
	elif current_hp <= max_hp * (1.0 - float(current_phase) / phases):
		current_phase += 1
		emit_signal("phase_changed", current_phase)


func _flash_white():
	modulate = Color.WHITE * 2.0
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _die():
	emit_signal("boss_defeated")
	queue_free()


func reset_boss():
	current_hp = max_hp
	current_phase = 1
