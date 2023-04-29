extends RigidBody2D

@onready var collider: CollisionShape2D = $CollisionShape2D

var held = false

func _init():
	connect("mouse_entered",Callable(self, "_on_mouse_over").bind(true))
	connect("mouse_exited",Callable(self, "_on_mouse_over").bind(false))
	
func _on_mouse_over(over: bool):
	if(held):
		return
	if(Global.player.held_item != null):
		return
	if(over):
		modulate = Color(1,1,1,0.8)
		Global.hovered_item = self
	else:
		modulate = Color.WHITE
		if(Global.hovered_item == self):
			Global.hovered_item = null
		
			
func on_pickup():
	held = true
	collider.disabled = true
	freeze = true
	position = Vector2(0,-48)
	modulate = Color.WHITE
	
func on_drop(drop_position: Vector2):
	held = false
	collider.disabled = false
	freeze = false
	position = drop_position
	modulate = Color.WHITE
