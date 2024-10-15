extends RigidBody2D

@onready var trigger_timer: Timer = $TriggerTimer
@onready var clean_up_timer: Timer = $CleanUpTimer

func _ready() -> void:
	freeze = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == 'player'):
		trigger_timer.start()
		clean_up_timer.start()

func _on_clean_up_timer_timeout() -> void:
	queue_free()

func _on_trigger_timer_timeout() -> void:
	freeze = false
