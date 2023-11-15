# This script is an autoload, that can be accessed from any other script!

extends Node2D
@onready var readyI
@onready var ready2
@onready var ready3
@onready var airborn
@onready var jump_force : float = 600
@onready var skate_speed : float = 400
@onready var hurt_force : float = 350


var score : int = 0

# Adds 1 to score variable
func add_score():
	score += 1

# Loads next level
func load_next_level(next_scene : PackedScene):
	get_tree().change_scene_to_packed(next_scene)

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

