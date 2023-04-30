extends CharacterBody2D

var walk_speed: float = 256
@onready var sprite: AnimatedSprite2D = $Sprite2D
var held_item: RigidBody2D
var boxes_around: Array[RigidBody2D]
@onready var grabArea: Area2D = $Area2D

func _ready():
	Global.player = self
	grabArea.connect("body_entered", Callable(self, "_on_area_entered"))
	grabArea.connect("body_exited", Callable(self, "_on_area_exited"))

func _process(_delta):
	z_index = int(position.y)
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
	if(velocity != Vector2.ZERO && !("walk" in sprite.animation)):
		sprite.animation = "walk"
	if(velocity == Vector2.ZERO && !("idle" in sprite.animation)):
		sprite.animation = "idle"
	if(held_item && !("_hold" in sprite.animation)):
		sprite.animation += "_hold"
	sprite.play()
	if(velocity.x != 0):
		sprite.flip_h = (velocity.x > 0)
		if(held_item):
			held_item.position = Vector2(sign(velocity.x) * 64, 0)

	move_and_slide()
	
	if(Input.is_action_just_pressed("mouse_left")):
		if(held_item == null):
			pickup_item()
		else:
			drop_item()
			
	
	
func pickup_item():
	if(boxes_around.size() == 0):
		return
	var mouse_position = get_global_mouse_position()
	var best_box = null
	var closest_dist: float = 99999
	for box in boxes_around:
		var dist = box.position.distance_to(mouse_position)
		if(dist < closest_dist):
			closest_dist = dist
			best_box = box
	if(!best_box):
		return
	held_item = best_box
	held_item.get_parent().remove_child(held_item)
	add_child(held_item)
	held_item.position = Vector2(sign(float(sprite.flip_h) - 0.5) * 64, 0)
	held_item.on_pickup()
	boxes_around.erase(held_item)
	held_item.deselect()
	
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
	if !(body in boxes_around):
		boxes_around.append(body)
		body.select()
	
func _on_area_exited(body: Node2D):
	boxes_around.erase(body)
	body.deselect()
	
