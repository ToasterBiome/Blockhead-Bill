extends RigidBody2D

@onready var collider: CollisionShape2D = $CollisionShape2D

var held = false
		
			
func on_pickup():
	held = true
	collider.disabled = true
	freeze = true
	position = Vector2(0,-64)
	modulate = Color.WHITE
	
func on_drop(drop_position: Vector2):
	held = false
	collider.disabled = false
	freeze = false
	position = drop_position
	modulate = Color.WHITE
