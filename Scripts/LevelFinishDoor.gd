extends Area2D

# Define the next scene to load in the inspector
@export var next_scene : PackedScene
@onready var readyI
@onready var ready2
@onready var ready3
@onready var airborn
@onready var jump_force
@onready var skate_speed
@onready var move_speed

var rand = ["readyI", "ready2", "ready3"]
var rand2 = rand.size()

func rng():
	for rand in rand2:
		randomize()
		if "readyI"in rand:
			_ready()
		if "ready2" in rand:
			_ready2()
		if "ready3" in rand:
			_ready3()

func _ready():
	if not airborn:
		jump_force + jump_force * 0.10

func _ready2():
	if not airborn:
		skate_speed + skate_speed * 0.10

func _ready3():
	if not airborn:
		move_speed + move_speed * 0.10

# Load next level scene when player collide with level finish door.
func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "death_tween") # death_tween is called here just to give the feeling of player entering the door.
		AudioManager.level_complete_sfx.play()
		SceneTransition.load_scene(next_scene)
		rng()
		

