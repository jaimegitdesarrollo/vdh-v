extends Area2D
## SecretItem — Coleccionable del mapa.
## Tipos: comic_page, grandma_memory, graffiti, safe_spot

@export var item_type: String = "comic_page" # comic_page, grandma_memory, graffiti, safe_spot
@export var item_id: String = "ch1_page_1"
@export var display_text: String = ""

var collected: bool = false


func _ready():
	add_to_group("collectibles")
	collision_layer = 8
	collision_mask = 1
	body_entered.connect(_on_body_entered)

	# Comprobar si ya fue recogido
	if GameManager.is_collected(item_id):
		queue_free()
		return

	# Sprite visual
	var sprite = Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex_path: String = "res://assets/sprites/collectibles/"
	match item_type:
		"comic_page":
			tex_path += "comic_page.png"
		"grandma_memory":
			tex_path += "grandma_memory.png"
		"graffiti":
			tex_path += "graffiti.png"
		"safe_spot":
			tex_path += "safe_spot.png"
		_:
			tex_path += "comic_page.png"
	sprite.texture = load(tex_path)
	add_child(sprite)

	# Efecto de brillo pulsante
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "modulate:a", 0.5, 0.8)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.8)


func _on_body_entered(body):
	if not body.is_in_group("player") or collected:
		return
	collected = true
	GameManager.collect_item(item_id, item_type)

	match item_type:
		"comic_page":
			_show_comic_page()
		"grandma_memory":
			_show_grandma_flash()
		"graffiti":
			_show_graffiti()
		"safe_spot":
			_activate_safe_spot(body)


func _show_comic_page():
	# Breve notificación
	_show_notification("¡Página de cómic encontrada!")
	AudioManager.play_sfx("sfx_collectible_pickup")
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _show_grandma_flash():
	var flash = get_tree().get_first_node_in_group("grandma_flash")
	if flash and flash.has_method("trigger"):
		flash.trigger(display_text)
	AudioManager.play_sfx("sfx_grandma_chime")
	await get_tree().create_timer(2.5).timeout
	queue_free()


func _show_graffiti():
	# Mostrar texto del graffiti como diálogo
	if display_text != "":
		DialogueManager.start_dialogue(display_text)
		if not DialogueManager.dialogues.has(display_text):
			_show_notification(display_text)
	await get_tree().create_timer(2.0).timeout
	queue_free()


func _activate_safe_spot(player_body):
	if not player_body.has_method("heal"):
		queue_free()
		return
	player_body.can_move = false
	AudioManager.crossfade_music("safe_spot")
	_show_notification("Cristian encontró un lugar seguro...")
	await get_tree().create_timer(2.0).timeout
	player_body.heal(1.0)
	_show_notification("Recuperó 1 corazón.")
	await get_tree().create_timer(1.5).timeout
	player_body.can_move = true
	queue_free()


func _show_notification(text: String):
	# Crear label temporal de notificación
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.position = Vector2(-60, -20)
	add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 15, 1.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free)
