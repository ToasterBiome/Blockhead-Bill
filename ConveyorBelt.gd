extends Area2D

var moving_objects: Array = []

var linear_velocity: Vector2 = Vector2(-256,0)

func _ready():
	connect("body_entered", Callable(self,"_on_area_entered"))
	connect("body_exited", Callable(self,"_on_area_exited"))
	
func _process(_delta):
	for n in moving_objects.size():
		moving_objects[n].set_linear_velocity(linear_velocity)
	
func _on_area_entered(body: Node2D):
	moving_objects.append(body)
	
func _on_area_exited(body: Node2D):
	moving_objects.erase(body)
	body.set_linear_velocity(Vector2.ZERO)
	
