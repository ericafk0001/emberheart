extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer

const SPEED = 140.0
const JUMP_VELOCITY = -275.0

var is_jumping = false
var jump_buffered = false

var has_coyote_time = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or !coyote_timer.is_stopped():
			is_jumping = true
			jump_buffered = false
			velocity.y = JUMP_VELOCITY
			has_coyote_time = false 
			coyote_timer.stop()  # Stop coyote timer when a jump is executed

		else:
			jump_buffered = true
			jump_buffer_timer.start()

	var direction := Input.get_axis("move_left", "move_right")
	
	#Flip Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	#animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var was_on_floor = is_on_floor()
	move_and_slide()
	
	#landing detection
	if !was_on_floor && is_on_floor() && is_jumping:
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
