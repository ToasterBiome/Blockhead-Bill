extends RigidBody2D
class_name Pickupable

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var held: bool = false
var color: Color = Color.WHITE
var size: String = "normal"
var serial_number: String = "asdancjqwenwe"
var claimed_by: Customer

func _ready():
	sprite.texture = Global.box_sprites[size]
	sprite.modulate = color
	serial_number = Global.get_serial_number(8)
	print(serial_number)
	Global.boxes.append(self)
	
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
