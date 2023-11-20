extends Area2D

# Define the next scene to load in the inspector
@export var next_scene : PackedScene
@onready var jump_force : float = 600
@onready var skate_speed : float = 400
@onready var hurt_force : float = 350

var cards = [
	func():
		jump_force + jump_force * 0.10,

	func():
		skate_speed + skate_speed * 0.10,
	
	func():
		hurt_force + hurt_force * 0.10]
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
