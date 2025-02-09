extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var dash_timer: Timer = $DashTimer

const SPEED = 140.0
const JUMP_VELOCITY = -275.0
const GRAVITY = -960.0
const DASH_SPEED = 360.0
const MAX_JUMPS = 2

var is_jumping = false
var jump_buffered = false
var has_coyote_time = false
var is_dashing = false
var jumps = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if !is_on_floor() && !is_dashing:
		velocity += calculate_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if jumps == 0:
			if is_on_floor() && !is_dashing || !coyote_timer.is_stopped() && !is_dashing:
				jumps += 1
				is_jumping = true
				jump_buffered = false
				velocity.y = JUMP_VELOCITY
				has_coyote_time = false 
				coyote_timer.stop()  # Stop coyote timer when a jump is executed
		elif jumps == 1:
			jumps += 1
			is_jumping = true
			jump_buffered = false
			velocity.y = JUMP_VELOCITY
			has_coyote_time = false 
			coyote_timer.stop()  # Stop coyote timer when a jump is executed
		elif jumps >= 2:
			jump_buffered = true
			jump_buffer_timer.start()
			

	var direction := Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("dash") && !is_dashing:
		if direction:
			jumps += 1
			is_dashing = true
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
			dash_timer.start()
		else:
			is_dashing = false
	
	#Flip Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	#animations
	if is_on_floor() && !is_dashing:
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if is_dashing:
		animated_sprite.play("dash")
	
	if !is_dashing:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	var was_on_floor = is_on_floor()
	move_and_slide()
	
	#landing detection
	if !was_on_floor && is_on_floor() && is_jumping:
		jumps = 0
		is_jumping = false 
		if jump_buffered:
			is_jumping = true
			jump_buffered = false
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			
	if was_on_floor && !is_on_floor():
		if not is_jumping:
			has_coyote_time = true
			coyote_timer.start()
		

func _on_jump_buffer_timer_timeout() -> void:
	jump_buffered = false

func _on_coyote_timer_timeout() -> void:
	has_coyote_time = false

func calculate_gravity() -> Vector2:
	if velocity.y < 0:  # Rising
		return Vector2(0, -GRAVITY)
	else:  # Falling
		return Vector2(0, -GRAVITY * 1.7)  # multiply gravity for falling


func _on_dash_timer_timeout() -> void:
	is_dashing = false
