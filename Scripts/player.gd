extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 250
@export var skate_speed : float = 400
@export var jump_force : float = 600
@export var switch_force : float = 200
@export var gravity : float = 30
@export var air_jumps : int = 0
@export var veldecrease : float = 1200
@export var velincrease : float = 500
@export var airveldecrease : float = 0
@export var airvelincrease : float = 50
@export var skatingincrease : float = 300
@export var skatingdecrease : float = 50
@export var switchdelay : float = .5
var switchdebounce : bool = false
var jump_count : int = 1

var skating: bool = false

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)

var speed : float

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var switch_particles = $switchparticles

# --------- BUILT-IN FUNCTIONS ---------- #

func undebounce():
			OS.delay_msec(500)
			switchdebounce = false
			print("hello")

func _input(event):
	if Input.is_action_just_pressed("Switch Mode"):
		if switchdebounce:
			return
		switchdebounce = true
		
		switch_particles.emitting = true
		if is_on_floor():
			velocity.y = -switch_force
		skating = not skating
		

func _physics_process(_delta):
	# Calling functions
	movement(_delta)
	cameraeffects(_delta)
	
# --------- CUSTOM FUNCTIONS ---------- #


func cameraeffects(dt):
	var vp = get_viewport()
	var xmid : int = vp.size.x / 2
	var ymid : int = vp.size.y / 2
	var velmagnitude : float = sqrt((velocity.x ** 2) + (velocity.y ** 2))
	var goalzoom : float = clamp(1 - (velmagnitude / 3000), .6, 1)
	var mousepos = vp.get_mouse_position()
	var cam = get_node("Camera2D")

	cam.offset.x = lerp(cam.offset.x, (mousepos.x - xmid)/20,dt * 10)
	cam.offset.y = lerp(cam.offset.y, (mousepos.y - ymid)/20,dt * 10)
	cam.zoom.x = lerp(cam.zoom.x, goalzoom, dt * .5)
	cam.zoom.y = lerp(cam.zoom.y, goalzoom, dt * .5)


# <-- Player Movement Code -->

func movement(dt):
	# Gravity
	
	var airborn : bool
	if !is_on_floor():
		velocity.y += gravity
		airborn = true
	elif is_on_floor():
		jump_count = air_jumps
		airborn = false

	var curvel : float = get_velocity().x
	handle_jumping()
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	var change : float = 0
		
	var increase : float
	var decrease : float
	if airborn:
		increase = airvelincrease
		decrease = airveldecrease
	elif skating:
		speed = skate_speed
		increase = skatingincrease
		decrease = skatingdecrease
	else:
		speed = move_speed
		increase = velincrease
		decrease = veldecrease
	
	"""
	if inputAxis > 0:
		if curvel < 0:
			change = clamp(decrease * dt, 0, speed)
		else:
			change = clamp(increase * dt, 0, speed)
	elif inputAxis < 0:
		if curvel > 0:
			change = clamp(-decrease * dt, -speed, 0)
		else:
			change = clamp(-increase * dt, -speed, 0)
	else:
		if curvel > 0:
			change = clamp(-decrease * dt, -curvel, 0)
		else:
			change = clamp(decrease * dt, 0, -curvel)
	"""
	
	if inputAxis > 0:
		# moving right
		if curvel < 0:
			change = clamp(max(decrease, increase) * dt, 0, speed)
		else:
			change = clamp(increase * dt, 0, speed)
	elif inputAxis < 0:
		#moving left
		if curvel > 0:
			change = clamp(-max(decrease, increase) * dt, -speed, 0)
		else:
			change = clamp(-increase * dt, -speed, 0)
	else:
		#no input
		if curvel > 0:
			change = clamp(-decrease * dt, -curvel, 0)
		else:
			change = clamp(decrease * dt, 0, -curvel)
	
	curvel = clamp(curvel + change, -speed, speed)
	velocity = Vector2(curvel, velocity.y)
	move_and_slide()
	player_animations(inputAxis, velocity.x, speed)

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			jump()
		elif jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Handle Player Animations
func player_animations(axis, vel, max):
	
	if is_on_floor():
		if axis != 0:
			particle_trails.emitting = true
			if (vel / abs(vel)) == axis:
				# vel in move direction
				player_sprite.play("Walk", abs(vel) / max)
			else:
				#vel against move direction
				player_sprite.play("Turn")
		else:
			#idle
			particle_trails.emitting = false
			player_sprite.play("Idle")
	else:
		#jumping
		particle_trails.emitting = false
		player_sprite.play("Jump")
	
	if vel < 0: 
		player_sprite.flip_h = true
	elif vel > 0:
		player_sprite.flip_h = false

# Tween Animations
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	await get_tree().create_timer(0.3).timeout
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
func _on_collision_body_entered(_body):
	if _body.is_in_group("Traps"):
		AudioManager.death_sfx.play()
		death_particles.emitting = true
		death_tween()
