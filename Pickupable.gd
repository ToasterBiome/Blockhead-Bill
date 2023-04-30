extends RigidBody2D
class_name Pickupable

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var held: bool = false

var claimed_by: Customer
var data: BoxData = null : set = _set_box_data

func _ready():
	sprite.material = sprite.material.duplicate()
	Global.boxes.append(self)
	Global.available_boxes.append(self)
	
func on_pickup():
	held = true
	collider.disabled = true
	freeze = true
	#position = Vector2(0,-64)
	modulate = Color.WHITE
	
func on_drop(drop_position: Vector2):
	held = false
	collider.disabled = false
	freeze = false
	position = drop_position
	modulate = Color.WHITE
	
func _set_box_data(value):
	data = value
	sprite.texture = Global.box_sprites[data.size]
	sprite.modulate = data.color
	
func select():
	sprite.material.set("shader_parameter/line_color", Color.GREEN)

func deselect():
	sprite.material.set("shader_parameter/line_color", Color(1,1,1,0))
