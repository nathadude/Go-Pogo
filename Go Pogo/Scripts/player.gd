extends CharacterBody2D

##Signals
signal jumped(value, buckling_status) ##emit jump data in launch() for feedback label

## Movement variables
@export var bounce_restitution := 0.8 #how much energy is saved from init bounce
@export var gravity := 900
@export var max_fall_speed := 1200
@export var air_rotation_speed := 300.0

##K Variables
@export var base_k := 3.0  # Stiffness coefficient
@export var add_k := 0.25   # k reward
@export var max_k := 10.0   # maximum k

##Compression variables
@export var max_compression_x := 100.0 # Maximum "charge" allowed
@export var min_compression_x := 50.0
@export var charge_decay_speed := 100.0
@export var compression_speed := 150.0 # How fast x increases while holding button
@export var peak_hold_time := 0.08 # Seconds to stay at 100 before buckling
var peak_timer := 0.0

#sprite/animation variables
@onready var sprite = $Sprite2D

# State variables
var current_x       := 0.0
var current_k       := base_k
var is_compressing  := false
var last_velocity_y := 0.0
var current_rot     := get_rotation_degrees()
var is_buckling     := false
var has_buckled     := false

func _physics_process(delta):
	#AIRBORNE LOGIC
	if not is_on_floor():
		last_velocity_y = velocity.y
		velocity.y += gravity * delta
		velocity.y = clamp(velocity.y, -99999, max_fall_speed)

	else: #if on ground
		#Initial Impact
		if last_velocity_y > 50:
			if Input.is_action_pressed("move_up"):
				#initial "Slam" boost into compression
				current_x = clamp(current_x + (last_velocity_y * 0.1), 0, max_compression_x)
			else:
				#Passive decay
				var decay_factor = clamp(1.0 - (last_velocity_y / max_fall_speed), 0.2, 1.0)
				current_k = lerp(current_k, base_k, decay_factor)
				velocity.y = -last_velocity_y * bounce_restitution
				#position.y -= 2
			last_velocity_y = 0
				
		#Active compression logic
		if Input.is_action_pressed("move_up"):
			is_compressing = true
			
			if current_x >= max_compression_x: ##AT PEAK
				#Delay then buckle
				peak_timer += delta
				if peak_timer >= peak_hold_time:
					is_buckling = true
					has_buckled = true
					
			if is_buckling:
				current_x -= charge_decay_speed * delta
				
			else:
				#LOGARITHMIC INCREASE
				#calculate diff by finding how much compression room is left
				#adding a fraction of diff makes compression slow down with increase towards 100
				var diff = max_compression_x - current_x
				var log_speed = clamp(diff * 0.05, 0.5, 10.0) #Ensure it doesn't stop entirely
				current_x += log_speed * compression_speed * delta
				
			current_x = clamp(current_x, min_compression_x, max_compression_x)
			print(current_x)
		
		# RELEASE: The moment they let go OR hit max compression and reset buckling
		elif is_compressing and Input.is_action_just_released("move_up"):
			is_buckling = false
			# TIE K INCREASE TO ACCURACY
			# Calculate how close current_x is to 100 (1.0 = Perfect, 0.0 = Far off)
			var accuracy = current_x / max_compression_x 
			
			# We only reward if they are above 80% charge
			if accuracy > 0.8:
				var reward = add_k * accuracy
				current_k = clamp(current_k + reward, base_k, max_k)
				print("Great Timing! Accuracy: ", accuracy, "Added reward of ", reward, "New K: ", current_k)
			else:
				print("Early Release. No K bonus.")
				
			jumped.emit(current_x, has_buckled)
			peak_timer = 0.0
			launch_player()
	move_and_slide()
	#apply_visual_juice()
	
func launch_player():
	#reset buckle after launch
	has_buckled = false 
	
	# F = k * x 
	# We use current_x as our displacement. 
	# We multiply by -1 because in Godot, Up is Negative Y.
	var spring_force = (current_k * current_x) * -1
	#base_k += .5
	
	position.y -= 2 # Force off floor to stay in air state
	velocity.y = spring_force
	current_x = 0.0 # Reset compression for next landing
	is_compressing = false
	print("Launched with force: ", spring_force)
	print("force added")
	print("Current Rotation in degrees: ", current_rot)
	
	##LOGIC MOVED TO SCRIPT ON SPRITE
#func apply_visual_juice():
	#if is_on_floor():
		## As current_x increases (0 to 100), y scale goes down (1.0 to 0.5)
		## and x scale goes up (1.0 to 1.5) to preserve volume
		#var squash_amount = (current_x / max_compression_x) * 0.08
		#sprite.scale.y = 0.25 - squash_amount
		#sprite.scale.x = 0.25 + squash_amount
	#else:
		## In the air, stretch based on vertical velocity
		#var stretch = clamp(abs(velocity.y) / max_fall_speed, 0, 0.05)
		#sprite.scale.y = 0.25 + stretch
		#sprite.scale.x = 0.25 - stretch
