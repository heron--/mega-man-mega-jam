extends AnimatableBody2D

class_name Kerog

@onready var health_component: HealthComponent = $HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_meta("is_enemy", true)
	set_meta("damage", 10)
	health_component.connect("health_depleted", _on_health_depleted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_health_depleted() -> void:
	queue_free()
