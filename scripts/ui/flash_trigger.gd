extends Area2D
## FlashTrigger — Area2D that triggers a PersonaFlash when the player enters.
## Place in levels and connect the body_entered signal.

@export var flash_phrase: String = ""
@export var one_shot: bool = true

var triggered: bool = false


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if not body.is_in_group("player"):
		return
	if one_shot and triggered:
		return

	triggered = true

	# Find PersonaFlash via its group
	var flash_node = get_tree().get_first_node_in_group("persona_flash")
	if flash_node and flash_node.has_method("trigger_flash"):
		flash_node.trigger_flash(flash_phrase)
