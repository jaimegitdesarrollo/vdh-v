extends Control
## DialogueBox — UI for displaying dialogue lines with typewriter effect.
## Connects to DialogueManager signals. Lives inside a CanvasLayer (layer 10).

@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var portrait_rect: TextureRect = %Portrait
@onready var continue_arrow: Label = %ContinueArrow
@onready var dialogue_box: PanelContainer = %DialogueBox

var is_typing: bool = false
var typewriter_speed: float = 0.03
var full_text: String = ""

var _typewriter_timer: float = 0.0
var _arrow_timer: float = 0.0
var _arrow_visible: bool = true

# Text typing SFX — plays variant sequence during typewriter
var _text_sfx_player: AudioStreamPlayer = null
var _current_variant: String = ""
var _slide_tween: Tween = null
var _original_box_y: float = -1.0

# Speaker -> text SFX variant
const TEXT_SFX_MAP: Dictionary = {
	"cristian": "soft", "Cristian": "soft", "Cristián": "soft",
	"narrador": "warm", "Narrador": "warm", "": "warm",
	"don_patrick": "woody", "Don Patrick": "woody",
	"Profesora": "woody", "Madre": "woody",
	"Joan": "anxious", "Robert": "anxious",
	"Mike": "anxious", "Lewis": "anxious",
	"Magic Man": "ghost",
	"Lucy": "soft",
}

# Text speed per variant
const TEXT_SPEED_MAP: Dictionary = {
	"soft": 0.03, "warm": 0.04, "woody": 0.03,
	"anxious": 0.02, "ghost": 0.05,
}

# Emotion -> portrait modulate color mapping
var emotion_colors: Dictionary = {
	"neutral": Color(0.8, 0.8, 0.8, 1.0),
	"scared": Color(0.6, 0.75, 1.0, 1.0),
	"mocking": Color(1.0, 0.6, 0.2, 1.0),
	"threatening": Color(1.0, 0.2, 0.2, 1.0),
	"sad": Color(0.5, 0.5, 0.8, 1.0),
	"happy": Color(1.0, 1.0, 0.5, 1.0),
	"hopeful": Color(0.6, 1.0, 0.7, 1.0),
}

# Slide animation offset (pixels from bottom)
var _slide_offset: float = 80.0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Connect to DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_displayed.connect(_on_line_displayed)
	# Start hidden
	dialogue_box.visible = false
	dialogue_box.modulate.a = 0.0
	continue_arrow.visible = false
	# Text SFX player
	_text_sfx_player = AudioStreamPlayer.new()
	_text_sfx_player.volume_db = -10.0
	_text_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_text_sfx_player)


func _process(delta: float):
	if not dialogue_box.visible:
		return

	# Typewriter effect
	if is_typing:
		_typewriter_timer += delta
		if _typewriter_timer >= typewriter_speed:
			_typewriter_timer -= typewriter_speed
			text_label.visible_characters += 1
			if text_label.visible_characters >= text_label.get_total_character_count():
				_finish_typing()

	# Blinking arrow
	if not is_typing and continue_arrow.visible:
		_arrow_timer += delta
		if _arrow_timer >= 0.5:
			_arrow_timer -= 0.5
			_arrow_visible = not _arrow_visible
			continue_arrow.modulate.a = 1.0 if _arrow_visible else 0.0


func _input(event: InputEvent):
	if not DialogueManager.is_active:
		return
	if not dialogue_box.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
		get_viewport().set_input_as_handled()
		if is_typing:
			_skip_typewriter()
		else:
			continue_arrow.visible = false
			DialogueManager.advance()


func _on_dialogue_started():
	# Kill any lingering slide tween to prevent conflicts
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()

	dialogue_box.visible = true

	# Store original position on first use
	if _original_box_y < 0:
		_original_box_y = dialogue_box.position.y

	# Reset to known good position before animating
	dialogue_box.position.y = _original_box_y + _slide_offset
	dialogue_box.modulate.a = 0.0

	# Slide up animation
	_slide_tween = create_tween()
	_slide_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_slide_tween.set_parallel(true)
	_slide_tween.tween_property(dialogue_box, "position:y", _original_box_y, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(dialogue_box, "modulate:a", 1.0, 0.2)


func _on_dialogue_ended():
	continue_arrow.visible = false
	is_typing = false
	_stop_text_sfx()

	# Kill any lingering slide tween
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()

	# Slide down animation
	if _original_box_y < 0:
		_original_box_y = dialogue_box.position.y

	_slide_tween = create_tween()
	_slide_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_slide_tween.set_parallel(true)
	_slide_tween.tween_property(dialogue_box, "position:y", _original_box_y + _slide_offset, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_slide_tween.tween_property(dialogue_box, "modulate:a", 0.0, 0.2)
	await _slide_tween.finished
	dialogue_box.visible = false
	dialogue_box.position.y = _original_box_y


func _on_line_displayed(speaker: String, text: String, emotion: String, portrait: String):
	# Set speaker name
	if speaker == "" or speaker == "Narrador":
		name_label.text = ""
	else:
		name_label.text = speaker

	# Set portrait color based on emotion
	var color = emotion_colors.get(emotion, emotion_colors["neutral"])
	portrait_rect.modulate = color

	# Determine text SFX variant and speed from speaker
	var variant: String = TEXT_SFX_MAP.get(speaker, "soft")
	typewriter_speed = TEXT_SPEED_MAP.get(variant, 0.03)

	# Start typewriter
	full_text = text
	text_label.text = text
	text_label.visible_characters = 0
	is_typing = true
	_typewriter_timer = 0.0
	continue_arrow.visible = false
	_arrow_timer = 0.0
	_arrow_visible = true

	# Play typing SFX sequence for this speaker variant
	_play_text_sfx(variant)


func _skip_typewriter():
	text_label.visible_characters = text_label.get_total_character_count()
	_finish_typing()


func _finish_typing():
	is_typing = false
	_stop_text_sfx()
	continue_arrow.visible = true
	_arrow_timer = 0.0
	_arrow_visible = true
	continue_arrow.modulate.a = 1.0


func _play_text_sfx(variant: String):
	var path: String = "res://assets/audio/sfx/text/sfx_text_%s.ogg" % variant
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/text/sfx_text_soft.ogg"
	if not ResourceLoader.exists(path):
		return
	_text_sfx_player.stream = load(path)
	_text_sfx_player.play()


func _stop_text_sfx():
	if _text_sfx_player and _text_sfx_player.playing:
		_text_sfx_player.stop()
