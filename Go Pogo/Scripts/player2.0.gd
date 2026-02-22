extends CharacterBody2D

## Signals
signal jumped(value, buckling_status)

## --- Exports ---
@export_group("Physics")
@export var gravity := 900
@export var max_fall_speed := 1200
@export var bounce_restitution := 0.8

@export_group("Spring Constants (K)")
@export var base_k := 3.0
@export var add_k := 0.25
@export var max_k := 10.0

@export_group("Compression (X)")
@export var max_compression_x := 100.0
@export var min_compression_x := 50.0
@export var compression_speed := 150.0
@export var charge_decay_speed := 100.0
@export var peak_hold_time := 0.08

## --- Nodes ---
@onready var sprite = $Sprite2D
@onready var trick_manager = $TrickManager
@onready var landing_manager = $LandingManager
@onready var floor_detector = $RayCast2D

## --- State Variables ---
var current_x        := 0.0
var current_k        := base_k
var is_compressing   := false
var is_buckling      := false
var has_buckled      := false
var can_trick        := false
var peak_timer       := 0.0
var last_velocity_y  := 0.0

func _physics_process(delta):
	# 1. AIRBORNE LOGIC
	if not is_on_floor():
		# Raycast check: If we are close to ground, we can't trick anymore
		can_trick = not floor_detector.is_colliding()
		last_velocity_y = velocity.y # track fall speed
		velocity.y += gravity * delta
		velocity.y = clamp(velocity.y, -99999, max_fall_speed)

	# 2. GROUNDED / IMPACT LOGIC
	else:
		if last_velocity_y > 50:
			_handle_impact()
			#last_velocity_y = 0 DO NOT ZERO HERE, LET THE HANDLERS HANDLE, DUH.

	# 3. INPUT HANDLING: COMPRESSION
	# This triggers if we are on floor OR close enough (RayCast hitting)
	# BIG ISSUE HERE FOR FUTURE FIX: COMPRESSION TIME VARIES AFTER RAYCAST IMPLEMENTATION
	#Raycast and collision are fighting over
	if is_on_floor() or floor_detector.is_colliding():
		if Input.is_action_pressed("move_up") and not has_buckled:
			_handle_compression_logic(delta)
		
		elif is_compressing and Input.is_action_just_released("move_up"):
			_finalize_jump()

	move_and_slide()

## Handles the moment the pogo hits the dirt
func _handle_impact():
	var error = landing_manager.get_landing_error()
	landing_manager.process_impact(error, last_velocity_y)
	
	if error < 45.0:
		trick_manager.reset_multiplier(true)
		
		# SOUL RESTORED: Smoothly right the pogo stick instead of snapping
		var tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 0, 0.1).set_trans(Tween.TRANS_SINE)
		
		if Input.is_action_pressed("move_up"):
			# Active Slam
			current_x = clamp(current_x + (last_velocity_y * 0.12), 0, max_compression_x)
		else:
			# If aren't holding the button MUST bounce back up
			var decay_factor = clamp(1.0 - (last_velocity_y / max_fall_speed), 0.4, 1.0)
			current_k = lerp(current_k, base_k, 0.2) # Slight decay of K
			velocity.y = -last_velocity_y * bounce_restitution
			position.y -= 5 # Pop off the floor slightly to maintain state
	else:
		# BAIL: TrickManager handles the reset, LandingManager handles the pity bounce
		trick_manager.reset_multiplier(false)
	
	last_velocity_y = 0 # Now we clear it

## Manages the X variable and Buckling state
func _handle_compression_logic(delta):
	is_compressing = true
	
	if current_x >= max_compression_x:
		peak_timer += delta
		if peak_timer >= peak_hold_time:
			is_buckling = true
			has_buckled = true
			
	if is_buckling:
		current_x -= charge_decay_speed * delta
	else:
		# Softened the logarithmic curve
		# Reduced the multiplier (0.05 -> 0.03) to give more room in the 90s
		var diff = max_compression_x - current_x
		var log_speed = clamp(diff * 0.03, 0.3, 8.0) 
		current_x += log_speed * compression_speed * delta
		
	current_x = clamp(current_x, min_compression_x, max_compression_x)

## Calculates accuracy, applies rewards, and launches
func _finalize_jump():
	var accuracy = current_x / max_compression_x
	
	if has_buckled:
		current_k = base_k # Penalty for buckling
	elif accuracy > 0.8:
		var reward = add_k * accuracy
		current_k = clamp(current_k + reward, base_k, max_k)
		print("Reward added. New K: ", current_k)
	
	jumped.emit(current_x, has_buckled)
	launch_player()

func launch_player():
	var spring_force = (current_k * current_x) * -1
	
	velocity.y = spring_force
	position.y -= 2 # Prevent immediate floor re-collision
	
	# Reset Jump States
	current_x = 0.0
	is_compressing = false
	is_buckling = false
	has_buckled = false
	peak_timer = 0.0
