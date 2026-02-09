extends Node
## AudioManager — Autoload Singleton
## Gestiona música, ambiente y efectos de sonido.

var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var current_music: String = ""
var current_ambient: String = ""
var music_volume: float = 0.8
var ambient_volume: float = 0.5
var sfx_volume: float = 1.0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	add_child(ambient_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)


func play_music(track_name: String, fade_in: float = 0.5):
	if current_music == track_name:
		return
	current_music = track_name
	var path = "res://assets/audio/music/" + track_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/music/" + track_name + ".wav"
	if not ResourceLoader.exists(path):
		music_player.stop()
		return
	var stream = load(path)
	music_player.stream = stream
	if fade_in > 0:
		music_player.volume_db = -80.0
		music_player.play()
		var tw = create_tween()
		tw.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_in)
	else:
		music_player.volume_db = linear_to_db(music_volume)
		music_player.play()


func stop_music(fade_out: float = 0.5):
	if not music_player.playing:
		current_music = ""
		return
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_out)
	tween.tween_callback(func():
		music_player.stop()
		current_music = ""
	)


func crossfade_music(new_track: String, duration: float = 1.0):
	if current_music == new_track:
		return
	stop_music(duration * 0.5)
	await get_tree().create_timer(duration * 0.5).timeout
	play_music(new_track, duration * 0.5)


func play_ambient(track_name: String, fade_in: float = 1.0):
	if current_ambient == track_name:
		return
	current_ambient = track_name
	var path = "res://assets/audio/sfx/" + track_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/" + track_name + ".wav"
	if not ResourceLoader.exists(path):
		ambient_player.stop()
		return
	var stream = load(path)
	ambient_player.stream = stream
	if fade_in > 0:
		ambient_player.volume_db = -80.0
		ambient_player.play()
		var tw = create_tween()
		tw.tween_property(ambient_player, "volume_db", linear_to_db(ambient_volume), fade_in)
	else:
		ambient_player.volume_db = linear_to_db(ambient_volume)
		ambient_player.play()


func stop_ambient(fade_out: float = 1.0):
	if not ambient_player.playing:
		current_ambient = ""
		return
	var tween = create_tween()
	tween.tween_property(ambient_player, "volume_db", -80.0, fade_out)
	tween.tween_callback(func():
		ambient_player.stop()
		current_ambient = ""
	)


func play_sfx(sfx_name: String):
	var path = "res://assets/audio/sfx/" + sfx_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/" + sfx_name + ".wav"
	if not ResourceLoader.exists(path):
		return
	var stream = load(path)
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(sfx_volume)
	sfx_player.play()


## Lower music volume temporarily (e.g. during ghost encounter).
func duck_music(target_db: float = -20.0, duration: float = 0.3):
	var tw = create_tween()
	tw.tween_property(music_player, "volume_db", target_db, duration)


## Restore music volume after ducking.
func unduck_music(duration: float = 0.5):
	var tw = create_tween()
	tw.tween_property(music_player, "volume_db", linear_to_db(music_volume), duration)
