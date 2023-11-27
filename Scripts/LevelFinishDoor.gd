extends Area2D

# Define the next scene to load in the inspector
@export var next_scene : PackedScene
@onready var jump_force : float = 600
@onready var skate_speed : float = 400
@onready var hurt_force : float = 350


func jumpI():
	jump_force + jump_force * 0.10
func jumpII():
	jump_force + jump_force * 0.25
func jumpIII():
	jump_force + jump_force * 0.50
func jumpIV():
	jump_force + jump_force * 1.00
func jumpV():
	jump_force + jump_force * 2.50
func skateI():
	skate_speed + skate_speed * 0.10
func skateII():
	skate_speed + skate_speed * 0.25
func skateIII():
	skate_speed + skate_speed * 0.50
func skateIV():
	skate_speed + skate_speed * 1.00
func skateV():
	skate_speed + skate_speed * 2.50
func hurtI():
	hurt_force + hurt_force * 0.10
func hurtII():
	hurt_force + hurt_force * 0.25
func hurtIII():
	hurt_force + hurt_force * 0.50
func hurtIV():
	hurt_force + hurt_force * 1.00
func hurtV():
	hurt_force + hurt_force * 2.50

		
var cards = [
	jumpI(),
	jumpII(),
	jumpIII(),
	jumpIV(),
	jumpV(),
	skateI(),
	skateII(),
	skateIII(),
	skateIV(),
	skateV(),
	hurtI(),
	hurtII(),
	hurtIII(),
	hurtIV(),
	hurtV()]
var cardsize = cards.size() - 1

func rng():
	var index = randi_range(0, cardsize)
	cards[index].call()

# Load next level scene when player collide with level finish door.
func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "death_tween") # death_tween is called here just to give the feeling of player entering the door.
		AudioManager.level_complete_sfx.play()
		SceneTransition.load_scene(next_scene)
		rng()
