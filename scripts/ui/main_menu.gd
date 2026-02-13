extends Control
## MainMenu — Pantalla principal del juego.
## Muestra el título, botones de Nueva Partida y Salir.

@onready var btn_new_game: Button = %BtnNewGame
@onready var btn_magic_man: Button = %BtnMagicMan
@onready var btn_classroom: Button = %BtnClassroom
@onready var btn_the_wall: Button = %BtnTheWall
@onready var btn_quit: Button = %BtnQuit


func _ready():
	btn_new_game.pressed.connect(_on_new_game_pressed)
	btn_magic_man.pressed.connect(_on_magic_man_pressed)
	btn_classroom.pressed.connect(_on_classroom_pressed)
	btn_the_wall.pressed.connect(_on_the_wall_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

	# Focus highlighting
	for btn in [btn_new_game, btn_magic_man, btn_classroom, btn_the_wall, btn_quit]:
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


func _on_quit_pressed():
	get_tree().quit()


func _on_button_focus_entered(button: Button):
	button.add_theme_color_override("font_color", Color(1.0, 0.95, 0.2, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.2, 1.0))


func _on_button_focus_exited(button: Button):
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
