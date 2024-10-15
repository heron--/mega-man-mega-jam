extends CharacterBody2D


const SPEED = 275.0
const JUMP_VELOCITY = -375.0

enum PlayerStateMovement { RUNNING, JUMPING, SLIDING, IDLING, HURTING }
enum PlayerStateAction { SHOOTING }

var player_state := {
	movement = PlayerStateMovement.IDLING,
	action = null
}

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_timer: Timer = $ShootTimer
@onready var player_health: HealthComponent = $HealthComponent
@onready var hitbox: Area2D = $Hitbox
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var muzzle: Marker2D = $Marker2D

const SHOOT_DURATION := 0.5
const HURT_VELOCITY := 20.0
const HURT_DECELERATION := -0.2
var fall_modifier = 1

var knockback_timer = 0.5
var knockback_velocity = Vector2.ZERO
var knockback_direction_modifier = 1

func _ready() -> void:
	hitbox.connect("body_entered", _on_body_entered_collision_shape)
	shoot_timer.connect("timeout", _on_shoot_timer_timeout)
	set_meta("is_player", true)

func _physics_process(delta: float) -> void:
	if player_state.movement == PlayerStateMovement.HURTING:
		knockback_timer -= delta
		if knockback_timer <= 0:
			player_state.movement = PlayerStateMovement.IDLING
			knockback_velocity = Vector2.ZERO
			knockback_timer = 0.5
		else:
			var velocity_modifier = HURT_DECELERATION * knockback_direction_modifier
			var new_x_velocity = knockback_velocity.x - (knockback_velocity.x * velocity_modifier)
			if knockback_direction_modifier < 0:
				new_x_velocity = clampf(new_x_velocity, -100, 0)
			else:
				new_x_velocity = clampf(new_x_velocity, 0, 100)
			knockback_velocity = Vector2(new_x_velocity, knockback_velocity.y)
			move_and_collide(knockback_velocity)
			update_animation()
			return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * fall_modifier
		
	# Handle jump.
	if player_state.movement != PlayerStateMovement.HURTING: 
		if Input.is_action_just_pressed("player_move_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			fall_modifier = 1
		if Input.is_action_just_released("player_move_jump"):
			fall_modifier = 2

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("player_move_left", "player_move_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
		if direction > 0:
			player_sprite.flip_h = false
		elif direction < 0:
			player_sprite.flip_h = true
		
		if Input.is_action_just_pressed("player_weapon_shoot"):
			shoot_bullet()
	
	update_player_state_action_from_input()
	update_player_state_movement_from_input()
	update_animation()
	
	move_and_slide()

func update_animation():
	player_sprite.animation = get_player_animation()
	player_sprite.play()
	
func _on_shoot_timer_timeout() -> void:
	player_state.action = null

func _on_hurt_timer_timeout() -> void:
	player_state.movement = PlayerStateMovement.IDLING

func _on_body_entered_collision_shape(node: Node) -> void:
	if node.get_meta("is_enemy", false) and player_state.movement != PlayerStateMovement.HURTING:
		# update player state and healthy
		player_state.movement = PlayerStateMovement.HURTING
		player_health.damage(node.get_meta("damage", 5))
		var direction := Input.get_axis("player_move_left", "player_move_right")
		knockback_direction_modifier = -1 if direction > 0 else 1
		knockback_velocity = Vector2(knockback_direction_modifier * HURT_VELOCITY, 0)
	
func get_player_animation() -> String:
	if player_state.movement == PlayerStateMovement.HURTING:
		return 'hurt'
		
	if player_state.action == null:
		match player_state.movement:
			PlayerStateMovement.IDLING:
				return 'idle'
			PlayerStateMovement.RUNNING:
				return 'run'
			PlayerStateMovement.JUMPING:
				return 'jump'
	elif player_state.action == PlayerStateAction.SHOOTING:
		match player_state.movement:
			PlayerStateMovement.IDLING:
				return 'shoot_still'
			PlayerStateMovement.RUNNING:
				return 'shoot_run'
			PlayerStateMovement.JUMPING:
				return 'shoot_jump'
				
	return 'idle'
		
func update_player_state_movement_from_input() -> void:
	var direction := Input.get_axis("player_move_left", "player_move_right")
	if is_on_floor():
		if Input.is_action_just_pressed("player_move_jump"):
			player_state.movement = PlayerStateMovement.JUMPING
			return
		elif direction > 0 or direction < 0:
			player_state.movement = PlayerStateMovement.RUNNING
			return
		else:
			player_state.movement = PlayerStateMovement.IDLING
			
func update_player_state_action_from_input() -> void:
	if Input.is_action_just_pressed("player_weapon_shoot"):
		player_state.action = PlayerStateAction.SHOOTING
		shoot_timer.wait_time = SHOOT_DURATION
		shoot_timer.start()
		return
	if player_state.action == PlayerStateAction.SHOOTING:
		player_state.action = PlayerStateAction.SHOOTING
		return
	else:
		player_state.action = null

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	var bullet_node = bullet.get_node("./") as Bullet
	bullet_node.flip_h = player_sprite.flip_h
	bullet.position = muzzle.global_position
	get_parent().add_child(bullet)

	
