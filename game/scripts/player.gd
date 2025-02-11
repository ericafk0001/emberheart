extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer

const SPEED = 140.0
const JUMP_VELOCITY = -280.0
const GRAVITY = -960.0
const DASH_SPEED = 360.0
const WALL_SLIDE_SPEED = 1200
const WALL_JUMP_FORCE = 150

var is_jumping = false
var jump_buffered = false
var has_coyote_time = false
var is_dashing = false
var can_dash = true
var jumps = 0
var do_wall_jump = false
var is_wall_sliding

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if is_on_wall_only() && !is_on_floor() && round(direction * get_wall_normal().x) == -1 && !do_wall_jump:
		is_wall_sliding = true
		velocity.y = WALL_SLIDE_SPEED * delta
	elif !is_on_floor() && !is_dashing:
		is_wall_sliding = false
		velocity += calculate_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_only() && !is_on_floor():
			do_wall_jump = true
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * WALL_JUMP_FORCE
			wall_jump_timer.start()
			jumps = 1  # Allow one more air jump after wall jump
			print("wall jump")
		elif jumps == 0:
			if is_on_floor() && !is_dashing || !coyote_timer.is_stopped() && !is_dashing:
				jump()
		elif jumps == 1:
			jump()
		elif jumps >= 2:
			jump_buffered = true
			jump_buffer_timer.start()
			
	if Input.is_action_just_pressed("dash") && !is_dashing && can_dash:
		if direction:
			is_dashing = true
			can_dash = false
			velocity.x = direction * DASH_SPEED
			velocity.y = 0
			dash_timer.start()
			dash_cooldown_timer.start()
		else:
			is_dashing = false
	
	#Flip Sprite
	if is_wall_sliding:
		if direction < 0:
			animated_sprite.flip_h = false
		elif direction > 0:
			animated_sprite.flip_h = true
	else:
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
	elif is_wall_sliding:
		animated_sprite.play("wall_slide")
	elif is_dashing:
		animated_sprite.play("dash")
		print(jumps)
	else:
		animated_sprite.play("jump")
	
	if !is_dashing:
		if direction && !do_wall_jump:
			velocity.x = direction * SPEED
		elif !do_wall_jump:
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
		

func jump():
	jumps += 1
	is_jumping = true
	jump_buffered = false
	velocity.y = JUMP_VELOCITY
	has_coyote_time = false 
	coyote_timer.stop()

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

func _on_wall_jump_timer_timeout() -> void:
	do_wall_jump = false
	jumps = 0


func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
	print("dash cooldown over")
