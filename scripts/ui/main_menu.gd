extends Control
## MainMenu — Pantalla principal del juego.
## Muestra el título, botones de Nueva Partida y Salir.

@onready var btn_new_game: Button = %BtnNewGame
@onready var btn_magic_man: Button = %BtnMagicMan
@onready var btn_classroom: Button = %BtnClassroom
@onready var btn_the_wall: Button = %BtnTheWall
@onready var btn_poems: Button = %BtnPoems
@onready var btn_quit: Button = %BtnQuit

var poem_layer: CanvasLayer


func _ready():
	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_magic_man.pressed.connect(_on_magic_man_pressed)
	btn_classroom.pressed.connect(_on_classroom_pressed)
	btn_the_wall.pressed.connect(_on_the_wall_pressed)
	btn_poems.pressed.connect(_on_poems_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

	# Focus highlighting
	for btn in [btn_new_game, btn_magic_man, btn_classroom, btn_the_wall, btn_poems, btn_quit]:
		btn.focus_entered.connect(_on_button_focus_entered.bind(btn))
		btn.focus_exited.connect(_on_button_focus_exited.bind(btn))

	# Auto-focus first button
	btn_new_game.grab_focus()

	# Menu music
	AudioManager.play_music("ch1_soledad_piano")


func _on_new_game_pressed():
	GameManager.start_new_game()
	TransitionManager.change_scene("res://scenes/chapters/chapter1/ch1_bedroom_morning.tscn")


func _on_magic_man_pressed():
	AudioManager.stop_music(0.3)
	TransitionManager.change_scene("res://scenes/minigames/pong/ch1_magic_man_pong.tscn")


func _on_classroom_pressed():
	AudioManager.stop_music(0.3)
	TransitionManager.change_scene("res://scenes/chapters/chapter1/ch1_classroom.tscn")


func _on_the_wall_pressed():
	AudioManager.stop_music(0.3)
	TransitionManager.change_scene("res://scenes/minigames/boss/the_wall_standalone.tscn")


func _on_poems_pressed():
	AudioManager.stop_music(0.3)
	_open_poem_minigame()


func _on_quit_pressed():
	get_tree().quit()


func _on_button_focus_entered(button: Button):
	button.add_theme_color_override("font_color", Color(1.0, 0.95, 0.2, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.2, 1.0))


func _on_button_focus_exited(button: Button):
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))


func _open_poem_minigame():
	if poem_layer != null:
		return

	poem_layer = CanvasLayer.new()
	poem_layer.name = "PoemLayer"
	poem_layer.layer = 50
	add_child(poem_layer)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	poem_layer.add_child(bg)

	var poem_script = load("res://scripts/ui/poem_composer.gd")
	var composer := Control.new()
	composer.set_script(poem_script)
	composer.set_anchors_preset(Control.PRESET_FULL_RECT)
	poem_layer.add_child(composer)

	await get_tree().process_frame
	composer.poem_finished.connect(_on_standalone_poem_finished)
	composer.start_composition("res://data/poems/poem_chapter1.json")


func _on_standalone_poem_finished(_score: int, _verses: Array):
	if poem_layer:
		poem_layer.queue_free()
		poem_layer = null
	AudioManager.play_music("ch1_soledad_piano")
