extends Node2D
@onready var jump_force
@onready var airborn

# Called when the node enters the scene tree for the first time.
var readyI = func _ready():
	if not airborn:
		jump_force + jump_force * 0.10# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
