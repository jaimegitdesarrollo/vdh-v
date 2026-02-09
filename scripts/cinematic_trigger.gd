extends Area2D
## CinematicTrigger — Dispara una secuencia cinemática al entrar el jugador.
## Puede ejecutar diálogos, transiciones, o señales personalizadas.

@export var trigger_dialogue: String = ""
@export var trigger_scene: String = ""
@export var one_shot: bool = true
@export var auto_disable_player: bool = true

var triggered: bool = false

signal cinematic_started
signal cinematic_ended


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	if one_shot and triggered:
		return

	triggered = true
	emit_signal("cinematic_started")

	if auto_disable_player and body.has_method("set"):
		body.can_move = false

	if trigger_dialogue != "":
		DialogueManager.start_dialogue(trigger_dialogue)
		await DialogueManager.dialogue_ended

	if trigger_scene != "":
		TransitionManager.change_scene(trigger_scene)

	if auto_disable_player and body.has_method("set"):
		body.can_move = true

	emit_signal("cinematic_ended")
