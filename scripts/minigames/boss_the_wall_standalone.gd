extends Node2D
## BossTheWallStandalone — Acceso directo a Boss The Wall desde el menú.

var boss_game: Node2D
var magic_man_texture: Texture2D


func _init():
	var sheet: Texture2D = load("res://assets/sprites/player/magicman_spritesheet.png")
	if sheet != null:
		var at := AtlasTexture.new()
		at.atlas = sheet
		at.region = Rect2(0, 0, 16, 16)
		at.filter_clip = true
		magic_man_texture = at
	else:
		magic_man_texture = load("res://assets/sprites/minigames/magic_man.png")


func _ready():
	AudioManager.play_music("magicman_boss_thewall")
	var boss_script = load("res://scripts/minigames/boss_the_wall.gd")
	boss_game = Node2D.new()
	boss_game.set_script(boss_script)
	boss_game.magic_man_texture = magic_man_texture
	add_child(boss_game)

	await get_tree().process_frame
	boss_game.boss_defeated.connect(_on_boss_defeated)


func _on_boss_defeated():
	AudioManager.stop_music(0.5)
	AudioManager.play_sfx("sfx_wall_victory")
	if boss_game:
		boss_game.queue_free()
	# Volver al menú
	await get_tree().create_timer(1.5).timeout
	TransitionManager.change_scene("res://scenes/main_menu.tscn")
