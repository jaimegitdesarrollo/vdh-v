extends Node
## HealthSystem — Manages player health (hearts) with bonus hearts support.
## Attached as a child node of the Player scene.

signal health_changed(current: float, max_health: float)
signal player_died

@export var max_hearts: int = 9

var bonus_hearts: float = 0.0
var current_health: float = 9.0


func _ready():
	# Use GameManager's chapter-based max hearts if available
	if Engine.has_singleton("GameManager") or get_node_or_null("/root/GameManager"):
		max_hearts = GameManager.get_max_hearts()
	current_health = max_hearts


func get_effective_max() -> float:
	return max_hearts + bonus_hearts


func take_damage(amount: float):
	current_health = max(0.0, current_health - amount)
	health_changed.emit(current_health, get_effective_max())
	if current_health <= 0.0:
		player_died.emit()


func heal(amount: float):
	current_health = min(get_effective_max(), current_health + amount)
	health_changed.emit(current_health, get_effective_max())


func add_bonus_heart(amount: float):
	bonus_hearts += amount
	current_health += amount
	health_changed.emit(current_health, get_effective_max())


func reset():
	current_health = get_effective_max()
	health_changed.emit(current_health, get_effective_max())
