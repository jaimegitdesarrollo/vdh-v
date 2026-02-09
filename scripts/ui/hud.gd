extends CanvasLayer
## HUD — Displays hearts, chapter info, comic page count, and interaction hints.

@onready var hearts_container: HBoxContainer = $Control/HeartsContainer
@onready var chapter_label: Label = $Control/ChapterLabel
@onready var pages_label: Label = $Control/PagesLabel
@onready var interact_hint: Label = $Control/InteractHint

var heart_textures: Array[TextureRect] = []

# Prebuilt textures for heart states
var _tex_full: Texture2D
var _tex_half: Texture2D
var _tex_empty: Texture2D


func _ready():
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS

	_create_heart_textures()
	_build_hearts(9)

	interact_hint.visible = false

	# Connect to the player's HealthSystem when it becomes available
	_connect_to_player.call_deferred()


func _connect_to_player():
	var player = _find_player()
	if player:
		var health_system = player.get_node_or_null("HealthSystem")
		if health_system:
			if not health_system.health_changed.is_connected(update_hearts):
				health_system.health_changed.connect(update_hearts)
			# Initial update
			update_hearts(health_system.current_health, health_system.get_effective_max())


func _find_player() -> Node:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null


func _create_heart_textures():
	_tex_full = load("res://assets/sprites/ui/heart_full.png")
	_tex_half = load("res://assets/sprites/ui/heart_half.png")
	_tex_empty = load("res://assets/sprites/ui/heart_empty.png")


func _build_hearts(count: int):
	# Clear existing hearts
	for child in hearts_container.get_children():
		child.queue_free()
	heart_textures.clear()

	for i in range(count):
		var tex_rect := TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(8, 8)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = _tex_full
		hearts_container.add_child(tex_rect)
		heart_textures.append(tex_rect)


func update_hearts(current: float, max_h: float):
	var heart_count: int = ceili(max_h)

	# Rebuild heart icons if the count changed
	if heart_textures.size() != heart_count:
		_build_hearts(heart_count)

	# Update each heart icon based on current health
	for i in range(heart_count):
		var heart_value: float = current - float(i)
		if heart_value >= 1.0:
			heart_textures[i].texture = _tex_full
		elif heart_value >= 0.5:
			heart_textures[i].texture = _tex_half
		else:
			heart_textures[i].texture = _tex_empty


func update_pages(count: int, total: int = 5):
	pages_label.text = "%d/%d paginas" % [count, total]


func show_interact_hint(show: bool = true):
	interact_hint.visible = show


func set_chapter_text(chapter: int, day_name: String):
	chapter_label.text = "Cap.%d — %s" % [chapter, day_name]
