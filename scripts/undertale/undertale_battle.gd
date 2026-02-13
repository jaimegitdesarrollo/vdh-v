extends Control
## UndertaleBattle — Sistema de combate tipo Undertale.
## Cristian (corazón rojo) esquiva proyectiles de los bullies.

signal battle_finished

@export var wave_count: int = 3
@export var wave_pause: float = 1.5

var current_wave: int = 0
var is_active: bool = false
var soul_heart: CharacterBody2D = null
var battle_box_rect: Rect2

# Split-screen mode: only bottom half, no bully silhouettes (classroom visible above)
var split_screen: bool = false

# Configuración de oleadas: cada una define duración, tipos y velocidades
var waves_config: Array = [
	{"duration": 10.0, "interval": 0.8, "types": ["insult"], "speed": 100.0},
	{"duration": 12.0, "interval": 0.6, "types": ["insult", "slap"], "speed": 120.0},
	{"duration": 12.0, "interval": 0.5, "types": ["insult", "slap", "laugh", "paperball"], "speed": 100.0}
]

var wave_timer: float = 0.0
var spawn_timer: float = 0.0
var wave_active: bool = false

# Fear system (replaces HP hearts)
var fear_current: float = 0.0
var fear_max: float = 100.0
var fear_per_hit: float = 12.0
var fear_bar_bg: ColorRect
var fear_bar_fill: ColorRect
var fear_label: Label

# Intrusive thoughts during battle
var _thought_timer: float = 0.0
var _thought_interval: float = 7.0
var _thoughts_container: Control
const BATTLE_THOUGHTS: Array = [
	"¿Por qué a mí?",
	"Quiero irme a casa",
	"No quiero estar aquí",
	"Ojalá fuera invisible",
	"No puedo más",
	"¿Qué he hecho yo?",
	"Nadie me va a ayudar",
	"Quiero que pare",
	"Me da miedo venir a clase",
	"¿Por qué nadie dice nada?",
	"No soy raro...",
	"Solo quiero que me dejen en paz",
	"Mamá, quiero irme",
	"Ojalá la abuela estuviera aquí",
]

# Bully silhouettes labels
var bully_names: Array[String] = ["Lewis", "Joan", "Robert", "Mike"]
var bully_textures: Array[String] = [
	"res://assets/sprites/ui/silhouette_bully1.png",
	"res://assets/sprites/ui/silhouette_bully2.png",
	"res://assets/sprites/ui/silhouette_bully3.png",
	"res://assets/sprites/ui/silhouette_bully4.png",
]

# Projectile texture paths by type (fallback if no insult text)
const PROJ_TEXTURES: Dictionary = {
	"insult": "res://assets/sprites/ui/proj_insult.png",
	"slap": "res://assets/sprites/ui/proj_slap.png",
	"laugh": "res://assets/sprites/ui/proj_laugh.png",
	"paperball": "res://assets/sprites/ui/proj_paperball.png",
}

# Insult texts for projectiles — real bullying phrases
const INSULT_TEXTS: Dictionary = {
	"insult": ["Friki", "Perdedor", "Raro", "Bicho raro", "Pringado", "Llorica", "Payaso", "Inútil"],
	"slap": ["¡ZAS!", "¡PAM!", "¡PLAF!", "¡TAS!"],
	"laugh": ["JAJAJA", "jajaja", "JEJEJE", "ja ja ja", "JA JA"],
	"paperball": ["Basura", "Asco", "Lárgate", "Fuera"],
}

# Colors per projectile type
const PROJ_COLORS: Dictionary = {
	"insult": Color(1.0, 0.3, 0.3),
	"slap": Color(1.0, 0.6, 0.2),
	"laugh": Color(0.8, 0.8, 0.2),
	"paperball": Color(0.7, 0.5, 0.3),
}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func start_battle(custom_waves: Array = []):
	if custom_waves.size() > 0:
		waves_config = custom_waves
		wave_count = custom_waves.size()
	is_active = true
	current_wave = 0
	visible = true
	get_tree().paused = true
	_setup_battle_ui()
	_start_wave()


func _setup_battle_ui():
	if split_screen:
		_setup_split_screen_ui()
	else:
		_setup_fullscreen_ui()


func _setup_fullscreen_ui():
	# Fondo negro
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color.BLACK
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)

	# Siluetas de bullies arriba
	var bullies_container = HBoxContainer.new()
	bullies_container.name = "BulliesContainer"
	bullies_container.position = Vector2(60, 10)
	bullies_container.add_theme_constant_override("separation", 30)
	add_child(bullies_container)

	for i in range(bully_names.size()):
		var bully_panel = VBoxContainer.new()
		var silhouette = TextureRect.new()
		silhouette.texture = load(bully_textures[i])
		silhouette.custom_minimum_size = Vector2(32, 48)
		silhouette.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		silhouette.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bully_panel.add_child(silhouette)
		var name_label = Label.new()
		name_label.text = bully_names[i]
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		bully_panel.add_child(name_label)
		bullies_container.add_child(bully_panel)

	_setup_battle_box(Vector2(40, 70), Vector2(240, 90), Vector2(160, 115),
		Vector2(40, 165), Vector2(220, 165))


func _setup_split_screen_ui():
	# Black background only on bottom half (y=88 to y=180)
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color.BLACK
	bg.position = Vector2(0, 88)
	bg.size = Vector2(320, 92)
	add_child(bg)
	move_child(bg, 0)

	# White divider line between classroom (top) and battle (bottom)
	var divider = ColorRect.new()
	divider.name = "Divider"
	divider.color = Color.WHITE
	divider.position = Vector2(0, 88)
	divider.size = Vector2(320, 2)
	add_child(divider)

	# No bully silhouettes — they're visible in the classroom above

	# Battle box in bottom half: centered, 220x60
	_setup_battle_box(Vector2(50, 96), Vector2(220, 62), Vector2(160, 127),
		Vector2(50, 162), Vector2(210, 162))


func _setup_battle_box(box_pos: Vector2, box_size: Vector2, heart_pos: Vector2,
		hp_pos: Vector2, wave_pos: Vector2):
	# Battle box (recuadro blanco)
	var battle_box = Panel.new()
	battle_box.name = "BattleBox"
	var box_style = StyleBoxFlat.new()
	box_style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	box_style.border_color = Color.WHITE
	box_style.border_width_left = 2
	box_style.border_width_right = 2
	box_style.border_width_top = 2
	box_style.border_width_bottom = 2
	battle_box.add_theme_stylebox_override("panel", box_style)
	battle_box.position = box_pos
	battle_box.size = box_size
	add_child(battle_box)

	# Use position (not global_position) since battle may be inside a CanvasLayer
	battle_box_rect = Rect2(
		box_pos + Vector2(4, 4),
		box_size - Vector2(8, 8)
	)

	# Soul heart (corazón rojo del jugador)
	var heart = CharacterBody2D.new()
	heart.name = "SoulHeart"
	heart.add_to_group("soul")
	heart.position = heart_pos
	heart.set_script(load("res://scripts/undertale/soul_heart.gd"))
	add_child(heart)
	soul_heart = heart

	# Collision para el corazón
	var heart_col = CollisionShape2D.new()
	var heart_shape = RectangleShape2D.new()
	heart_shape.size = Vector2(8, 8)
	heart_col.shape = heart_shape
	heart.add_child(heart_col)

	if soul_heart.has_method("setup"):
		soul_heart.setup(battle_box_rect)

	# --- Fear bar (replaces HP hearts) ---
	fear_label = Label.new()
	fear_label.name = "FearLabel"
	fear_label.text = "MIEDO"
	fear_label.position = hp_pos
	fear_label.add_theme_font_size_override("font_size", 9)
	fear_label.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	add_child(fear_label)

	# Bar background (dark)
	fear_bar_bg = ColorRect.new()
	fear_bar_bg.name = "FearBarBg"
	fear_bar_bg.position = Vector2(hp_pos.x + 38, hp_pos.y + 2)
	fear_bar_bg.size = Vector2(80, 8)
	fear_bar_bg.color = Color(0.15, 0.15, 0.15)
	add_child(fear_bar_bg)

	# Bar fill (red, grows left to right)
	fear_bar_fill = ColorRect.new()
	fear_bar_fill.name = "FearBarFill"
	fear_bar_fill.position = fear_bar_bg.position
	fear_bar_fill.size = Vector2(0, 8)
	fear_bar_fill.color = Color(0.8, 0.15, 0.15)
	add_child(fear_bar_fill)

	# Bar border (white outline)
	var bar_border = ColorRect.new()
	bar_border.position = Vector2(fear_bar_bg.position.x - 1, fear_bar_bg.position.y - 1)
	bar_border.size = Vector2(82, 10)
	bar_border.color = Color(0.6, 0.6, 0.6)
	add_child(bar_border)
	move_child(bar_border, bar_border.get_index() - 2)  # Behind bg and fill

	_update_fear_display()

	# Wave indicator
	var wave_label = Label.new()
	wave_label.name = "WaveLabel"
	wave_label.position = wave_pos
	wave_label.add_theme_font_size_override("font_size", 9)
	wave_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	add_child(wave_label)

	# Intrusive thoughts container (overlays the battle box area)
	_thoughts_container = Control.new()
	_thoughts_container.name = "ThoughtsContainer"
	_thoughts_container.position = Vector2.ZERO
	_thoughts_container.size = Vector2(320, 180)
	_thoughts_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_thoughts_container)
	_thought_timer = randf_range(3.0, 6.0)  # First thought comes quickly


func _start_wave():
	if current_wave >= wave_count:
		_end_battle()
		return

	wave_active = true
	wave_timer = waves_config[current_wave]["duration"]
	spawn_timer = 0.0

	if has_node("WaveLabel"):
		$WaveLabel.text = "Oleada %d/%d" % [current_wave + 1, wave_count]


func _physics_process(delta):
	if not is_active or not wave_active:
		return

	wave_timer -= delta
	spawn_timer -= delta

	if spawn_timer <= 0:
		_spawn_projectile()
		spawn_timer = waves_config[current_wave]["interval"]

	if wave_timer <= 0:
		wave_active = false
		_clear_projectiles()
		current_wave += 1
		if current_wave < wave_count:
			await get_tree().create_timer(wave_pause).timeout
			_start_wave()
		else:
			_end_battle()

	_update_fear_display()


func _spawn_projectile():
	var config = waves_config[current_wave]
	var types = config["types"]
	var proj_type = types[randi() % types.size()]
	var spd = config["speed"]

	var proj = Area2D.new()
	proj.add_to_group("projectiles")
	proj.collision_layer = 0
	proj.collision_mask = 2

	# Pick a random insult text for this type
	var texts: Array = INSULT_TEXTS.get(proj_type, ["..."])
	var insult_text: String = texts[randi() % texts.size()]
	var text_color: Color = PROJ_COLORS.get(proj_type, Color.WHITE)

	# Text label as the projectile visual
	var label = Label.new()
	label.text = insult_text
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", text_color)
	# Center the label on the Area2D origin
	label.position = Vector2(-insult_text.length() * 2.5, -5)
	proj.add_child(label)

	# Collision shape sized to the text
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	var text_width: float = max(insult_text.length() * 5.0, 12.0)
	shape.size = Vector2(text_width, 8)
	col.shape = shape
	proj.add_child(col)

	# Determinar dirección de entrada
	var side = randi() % 4
	var start_pos: Vector2
	var direction: Vector2

	match side:
		0: # Izquierda
			start_pos = Vector2(battle_box_rect.position.x - 10, randf_range(battle_box_rect.position.y, battle_box_rect.end.y))
			direction = Vector2.RIGHT
		1: # Derecha
			start_pos = Vector2(battle_box_rect.end.x + 10, randf_range(battle_box_rect.position.y, battle_box_rect.end.y))
			direction = Vector2.LEFT
		2: # Arriba
			start_pos = Vector2(randf_range(battle_box_rect.position.x, battle_box_rect.end.x), battle_box_rect.position.y - 10)
			direction = Vector2.DOWN
		3: # Abajo (solo para laugh — sinusoidal)
			start_pos = Vector2(battle_box_rect.position.x - 10, randf_range(battle_box_rect.position.y, battle_box_rect.end.y))
			direction = Vector2.RIGHT

	proj.global_position = start_pos
	proj.set_meta("direction", direction)
	proj.set_meta("speed", spd)
	proj.set_meta("type", proj_type)
	proj.set_meta("time", 0.0)
	proj.set_meta("start_y", start_pos.y)

	proj.body_entered.connect(func(body):
		if body.is_in_group("soul"):
			if body.has_method("take_damage"):
				body.take_damage(0.5)
			proj.queue_free()
	)

	add_child(proj)


func _process(delta):
	if not is_active:
		return
	# Mover proyectiles
	for child in get_children():
		if child.is_in_group("projectiles"):
			var dir: Vector2 = child.get_meta("direction", Vector2.RIGHT)
			var spd: float = child.get_meta("speed", 100.0)
			var proj_type: String = child.get_meta("type", "insult")
			var t: float = child.get_meta("time", 0.0) + delta
			child.set_meta("time", t)

			if proj_type == "laugh":
				var start_y: float = child.get_meta("start_y", child.position.y)
				child.position.x += dir.x * spd * delta
				child.position.y = start_y + sin(t * 5.0) * 20.0
			elif proj_type == "paperball":
				child.position += dir * spd * delta
				child.position.y += sin(t * 3.0) * 0.5
			else:
				child.position += dir * spd * delta

			# Eliminar si sale de pantalla
			if child.position.x < -50 or child.position.x > 370 or child.position.y < -50 or child.position.y > 230:
				child.queue_free()

	# Intrusive thoughts timer
	if _thoughts_container:
		_thought_timer -= delta
		if _thought_timer <= 0:
			_spawn_battle_thought()
			_thought_timer = randf_range(5.0, 10.0)


func _clear_projectiles():
	for child in get_children():
		if child.is_in_group("projectiles"):
			child.queue_free()


# --- Fear system ---

func _on_soul_hit(_amount: float):
	fear_current = min(fear_current + fear_per_hit, fear_max)
	_update_fear_display()
	# Spawn an immediate intrusive thought on hit
	if _thoughts_container and randf() > 0.4:
		_spawn_battle_thought()


func _update_fear_display():
	if fear_bar_fill:
		var ratio = fear_current / fear_max
		fear_bar_fill.size.x = 80.0 * ratio
		# Color intensifies as fear grows
		fear_bar_fill.color = Color(0.8 + ratio * 0.2, 0.15 - ratio * 0.1, 0.15 - ratio * 0.1)
	if fear_label:
		if fear_current >= fear_max:
			fear_label.text = "¡PÁNICO!"
		elif fear_current >= fear_max * 0.7:
			fear_label.text = "TERROR"
		else:
			fear_label.text = "MIEDO"


# --- Intrusive thoughts ---

func _spawn_battle_thought():
	if not _thoughts_container:
		return
	var text: String = BATTLE_THOUGHTS[randi() % BATTLE_THOUGHTS.size()]
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3, 0.25))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.rotation = deg_to_rad(randf_range(-12.0, 12.0))

	# Random direction across the battle area
	var start_pos: Vector2
	var end_pos: Vector2
	var direction_type = randi() % 4
	match direction_type:
		0: # Left to right
			start_pos = Vector2(-60, randf_range(90, 170))
			end_pos = Vector2(340, randf_range(90, 170))
		1: # Right to left
			start_pos = Vector2(340, randf_range(90, 170))
			end_pos = Vector2(-60, randf_range(90, 170))
		2: # Top to bottom (diagonal)
			start_pos = Vector2(randf_range(-20, 280), 80)
			end_pos = Vector2(randf_range(40, 340), 185)
		3: # Bottom to top (diagonal)
			start_pos = Vector2(randf_range(40, 340), 185)
			end_pos = Vector2(randf_range(-20, 280), 80)

	lbl.position = start_pos
	_thoughts_container.add_child(lbl)

	var duration = randf_range(4.0, 7.0)
	var tw = create_tween()
	tw.tween_property(lbl, "position", end_pos, duration)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, duration * 0.3).set_delay(duration * 0.7)
	tw.tween_callback(lbl.queue_free)


func _end_battle():
	is_active = false
	wave_active = false
	_clear_projectiles()
	# Hide everything BEFORE unpausing to prevent visual artifacts
	visible = false
	modulate.a = 0.0
	for child in get_children():
		child.queue_free()
	get_tree().paused = false
	emit_signal("battle_finished")
