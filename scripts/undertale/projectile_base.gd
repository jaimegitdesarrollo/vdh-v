extends Area2D
## ProjectileBase — Proyectil base para combate Undertale.

@export var speed: float = 100.0
@export var damage: float = 0.5
var direction: Vector2 = Vector2.RIGHT

## Texture path lookup by projectile type
const PROJECTILE_TEXTURES: Dictionary = {
	"insult": "res://assets/sprites/ui/proj_insult.png",
	"slap": "res://assets/sprites/ui/proj_slap.png",
	"laugh": "res://assets/sprites/ui/proj_laugh.png",
	"paperball": "res://assets/sprites/ui/proj_paperball.png",
}

var sprite: Sprite2D = null


func _ready():
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)


## Call after adding to the tree to set the projectile visual from a type string.
func set_projectile_type(proj_type: String) -> void:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
	var path: String = PROJECTILE_TEXTURES.get(proj_type, "")
	if path != "":
		sprite.texture = load(path)


func _physics_process(delta):
	position += direction * speed * delta
	# Auto-destruir si sale de pantalla
	if position.x < -50 or position.x > 370 or position.y < -50 or position.y > 230:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("soul"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
