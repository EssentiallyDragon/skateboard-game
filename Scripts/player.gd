extends CharacterBody2D

# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 250
@export var skate_speed : float = 400
@export var jump_force : float = 650
@export var switch_force : float = 200
@export var hurt_force : float = 350
@export var gravity : float = 30
@export var air_jumps : int = 0
@export var veldecrease : float = 1200
@export var velincrease : float = 700
@export var airveldecrease : float = 0
@export var airvelincrease : float = 50
@export var skatingincrease : float = 300
@export var skatingdecrease : float = 50
@export var switchdelay : float = .5
@export var maxhealth : float = 100
@export var health : float = maxhealth
@export var iframes : float = 1
@export var damage : float = 10
var switchdebounce : bool = false
var jump_count : int = 1




var skating: bool = false

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)

var speed : float

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var hurt_particles = $HurtParticles
@onready var death_particles = $DeathParticles
@onready var switch_particles = $switchparticles
@onready var next_scene = PackedScene

# --------- BUILT-IN FUNCTIONS ---------- #

var undebounce = func():
	OS.delay_msec(500)
	switchdebounce = false

func _input(event):
	if Input.is_action_just_pressed("Switch Mode"):
		if switchdebounce:
			return
		switchdebounce = true
		
		switch_particles.emitting = true
		if is_on_floor():
			velocity.y = -switch_force
		skating = not skating
		Thread.new().start(undebounce) 

var savedhealth = health
var iframeson = false
func _process(dt):
	#print(savedhealth)
	#print(health)
	if savedhealth != health:
		if iframeson:
			health = savedhealth
			return
			
		iframeson = true
		# get i frames for a bit?
		var clampedhealth = clamp(health, 0, maxhealth)
		savedhealth = clampedhealth
		health = clampedhealth
		
		print("owie")
		velocity.y = -hurt_force
		# color
		player_sprite.modulate = Color.LIGHT_CORAL
		var tween = create_tween()
		tween.tween_property(player_sprite, "modulate", Color.WHITE, .2)
		hurt_particles.emitting = true
		
		await get_tree().create_timer(iframes).timeout
		iframeson = false
		
		#unused flash effects
		for x in 0:
			player_sprite.visible = false
			await get_tree().create_timer(.05).timeout
			player_sprite.visible = true
			await get_tree().create_timer(.05).timeout
		
		# flash the player a few times

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
	if skating:
		if is_on_floor():
			if axis != 0:
				if (vel / abs(vel)) == axis:
					# vel in move direction
					player_sprite.play("skatingslide", abs(vel) / max)
				else:
					#vel against move direction
					player_sprite.play("skatingslide")
			else:
				#idle
				if abs(vel) >= 10:
					player_sprite.play("skatingslide")
				else:
					player_sprite.play("skatingidle")
		else:
			#jumping
			player_sprite.play("skatingslide")
	else:
		if is_on_floor():
			if axis != 0:
				if (vel / abs(vel)) == axis:
					# vel in move direction
					player_sprite.play("Walk", abs(vel) / max)
				else:
					#vel against move direction
					player_sprite.play("Turn")
			else:
				#idle
				player_sprite.play("Idle")
		else:
			#jumping
			player_sprite.play("Jump")
	
	if abs(vel) >= 10 and is_on_floor():
		particle_trails.emitting = true
	else:
		particle_trails.emitting = false
	
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

@export var mob_scene: PackedScene
func game_over():
	$MobTimer.stop()

func new_game():
	$Player.start($StartPosition.position)
	$StartTimer.start()
func _on_start_timer_timeout():
	$MobTimer.start()
func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(390.0, 175.0),0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

# card system
func jumpI():
	jump_force += 20
func jumpII():
	jump_force += 50
func jumpIII():
	jump_force += 100
func jumpIV():
	jump_force += 175
func jumpV():
	jump_force += 250
func speedI():
	move_speed += 25
	skate_speed += 40
func speedII():
	move_speed += 40
	skate_speed += 70
func speedIII():
	move_speed += 60
	skate_speed += 100
func speedIV():
	move_speed += 80
	skate_speed += 150
func speedV():
	move_speed += 100
	skate_speed += 200
func damageI():
	damage += 1
func damageII():
	damage += 2
func damageIII():
	damage += 5
func damageIV():
	damage += 8
func damageV():
	damage += 15
func plusJump():
	air_jumps += 1
func plusHealth():
	maxhealth += 50
func plusVel():
	velincrease += 50


var cards = [
	jumpI,
	jumpII,
	jumpIII,
	jumpIV,
	jumpV,
	speedI,
	speedII,
	speedIII,
	speedIV,
	speedV,
	damageI,
	damageII,
	damageIII,
	damageIV,
	damageV,
	plusJump,
	plusHealth,
	plusVel]
var cardsize = cards.size() - 1

func rng():
	var index = randi_range(0, cardsize)
	cards[index].call()
	print(index)

func cardsfunc():
	while true:
		await get_tree().create_timer(100000).timeout
		rng()
		print(jump_force)

func _ready():
	cardsfunc()
