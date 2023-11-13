extends Node2D
@onready var move_speed
@onready var airborn

# Called when the node enters the scene tree for the first time.
func _ready():
	if not airborn:
		move_speed + move_speed * 1000.10# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
