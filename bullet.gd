extends Node2D

class_name Bullet

@export var flip_h = false;
@export var velocity = 5;
@export var damage = 10;
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.connect('body_entered', _on_body_entered)

func _process(delta: float) -> void:
	if flip_h:
		position.x -= velocity
	else:
		position.x += velocity
		
func _on_body_entered(node: Node) -> void:
	var health_node = (node.get_node("HealthComponent") as HealthComponent)
	var is_enemy = node.get_meta("is_enemy", false)
	var is_player = node.get_meta("is_player", false)
	if health_node != null and is_enemy:
		health_node.damage(damage)
	if !is_player:
		queue_free()
