extends Node
## DialogueManager — Autoload Singleton
## Sistema de diálogos con carga JSON, typewriter y señales.

signal dialogue_started
signal dialogue_ended
signal line_displayed(speaker: String, text: String, emotion: String, portrait: String)

var dialogues: Dictionary = {}
var current_dialogue: Array = []
var current_line: int = 0
var is_active: bool = false


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func load_dialogues(path: String):
	if not FileAccess.file_exists(path):
		push_warning("DialogueManager: archivo no encontrado: " + path)
		return
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(json_text)
	if parsed is Dictionary:
		dialogues.merge(parsed, true)


func start_dialogue(id: String):
	if not dialogues.has(id):
		push_warning("DialogueManager: diálogo no encontrado: " + id)
		return
	current_dialogue = dialogues[id]["lines"]
	current_line = 0
	is_active = true
	emit_signal("dialogue_started")
	_show_line()


func _show_line():
	if current_line >= current_dialogue.size():
		end_dialogue()
		return
	var line = current_dialogue[current_line]
	var speaker = line.get("speaker", "")
	var text = line.get("text", "")
	var emotion = line.get("emotion", "neutral")
	var portrait = line.get("portrait", "")
	emit_signal("line_displayed", speaker, text, emotion, portrait)


func advance():
	if not is_active:
		return
	current_line += 1
	_show_line()


func end_dialogue():
	is_active = false
	current_dialogue = []
	current_line = 0
	emit_signal("dialogue_ended")


## Input handling moved to dialogue_box.gd to support typewriter skip logic.
