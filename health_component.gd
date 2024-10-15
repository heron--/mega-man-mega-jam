extends Node

class_name HealthComponent

@export var starting_health = 100
@export var max_health = 100
var current_health := 0

signal health_depleted
signal health_changed(old_value: int, new_value: int)
 
func _ready() -> void:
	current_health = starting_health

func damage(damage_amount: int):
	var starting_health = current_health
	current_health = clampi(current_health - abs(damage_amount), 0, max_health)
	health_changed.emit(starting_health, current_health)
	
	if current_health <= 0:
		health_depleted.emit()
		
	print("remaining health %d" % current_health)
		
func heal(heal_amount: int):
	var starting_health = current_health	
	current_health = clampi(current_health + abs(heal_amount), 0, max_health)	
	health_changed.emit(starting_health, current_health)
	
	print("remaining health %d" % current_health)
