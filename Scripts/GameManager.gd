# This script is an autoload, that can be accessed from any other script!

extends Node2D
@onready var readyI
@onready var ready2
@onready var ready3
@onready var airborn



var score : int = 0

# Adds 1 to score variable
func add_score():
	score += 1
	
func get_score():
	return score

# Loads next level
func load_next_level(next_scene : PackedScene):
	get_tree().change_scene_to_packed(next_scene)



