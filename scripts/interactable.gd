extends Area2D
## Interactable — Area2D genérico para objetos con los que el jugador interactúa.
## Soporta diálogo, transición de escena y recolección de ítems.

@export var dialogue_id: String = ""
@export var interaction_type: String = "dialogue" ## "dialogue", "transition", "item"
@export var target_scene: String = ""

signal interacted


func interact():
	match interaction_type:
		"dialogue":
			if dialogue_id != "":
				DialogueManager.start_dialogue(dialogue_id)
			else:
				push_warning("Interactable: dialogue_id vacío en " + name)
		"transition":
			if target_scene != "":
				TransitionManager.change_scene(target_scene)
			else:
				push_warning("Interactable: target_scene vacío en " + name)
		"item":
			interacted.emit()
		_:
			push_warning("Interactable: interaction_type desconocido: " + interaction_type)
