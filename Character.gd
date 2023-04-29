extends CharacterBody2D

var walk_speed: float = 256
@onready var sprite: AnimatedSprite2D = $Sprite2D
var held_item: RigidBody2D

func _init():
	Global.player = self

func _process(delta):
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
		print("setting")
	if(velocity == Vector2.ZERO && sprite.animation != "idle"):
		sprite.animation = "idle"
		sprite.play()
	if(velocity.x != 0):
		sprite.flip_h = (velocity.x > 0)

	move_and_slide()
	
	if(Input.is_action_just_pressed("mouse_left")):
		if(Global.hovered_item != null):
			var dist = Global.hovered_item.global_position.distance_to(global_position)
			if(dist <= 96):
				pickup_item(Global.hovered_item)
		else:
			drop_item()
	
func pickup_item(item: RigidBody2D):
	held_item = item
	held_item.get_parent().remove_child(held_item)
	add_child(held_item)
	held_item.on_pickup()
	Global.hovered_item = null
	
func drop_item():
	if(held_item == null):
		return
	remove_child(held_item)
	get_tree().get_root().add_child(held_item)
	var mouse_pos = get_global_mouse_position()
	var direction: Vector2 = position.direction_to(mouse_pos).snapped(Vector2.ONE)
	held_item.on_drop(global_position + (direction * 64))
	held_item = null
	
