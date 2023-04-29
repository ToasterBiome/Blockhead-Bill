extends CharacterBody2D

var walk_speed: float = 256
@onready var sprite: AnimatedSprite2D = $Sprite2D
var held_item: RigidBody2D
var touched_box: RigidBody2D
@onready var grabArea: Area2D = $Area2D

func _ready():
	Global.player = self
	grabArea.connect("body_entered", Callable(self, "_on_area_entered"))
	grabArea.connect("body_exited", Callable(self, "_on_area_exited"))

func _process(_delta):
	velocity = Vector2.ZERO
	if(Input.get_action_strength("left")):
		velocity += Vector2.LEFT
	if(Input.get_action_strength("right")):
		velocity += Vector2.RIGHT
	if(Input.get_action_strength("up")):
		velocity += Vector2.UP
	if(Input.get_action_strength("down")):
		velocity += Vector2.DOWN
	velocity = velocity.normalized()
	velocity = velocity * walk_speed
	if(velocity != Vector2.ZERO && sprite.animation != "walk"):
		sprite.animation = "walk"
		sprite.play()
	if(velocity == Vector2.ZERO && sprite.animation != "idle"):
		sprite.animation = "idle"
		sprite.play()
	if(velocity.x != 0):
		sprite.flip_h = (velocity.x > 0)

	move_and_slide()
	
	if(Input.is_action_just_pressed("mouse_left")):
		if(held_item == null && touched_box != null):
			pickup_item(touched_box)
		else:
			drop_item()
			
	
	
func pickup_item(item: RigidBody2D):
	held_item = item
	held_item.get_parent().remove_child(held_item)
	add_child(held_item)
	held_item.on_pickup()
	touched_box = null
	
func drop_item():
	if(held_item == null):
		return
	remove_child(held_item)
	get_tree().get_root().add_child(held_item)
	var mouse_pos = get_global_mouse_position()
	var direction: Vector2 = position.direction_to(mouse_pos).snapped(Vector2.ONE)
	sprite.flip_h = (direction.x > 0)
	held_item.on_drop(global_position + (direction * 96))
	held_item = null
	
func _on_area_entered(body: Node2D):
	if(touched_box != null):
		touched_box.modulate = Color.WHITE
	print("touched: " + str(body.name))
	touched_box = body
	touched_box.modulate = Color.GREEN
	pass
	
func _on_area_exited(body: Node2D):
	if(body == touched_box):
		touched_box.modulate = Color.WHITE
		touched_box = null
	
