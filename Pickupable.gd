extends RigidBody2D
class_name Pickupable

@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var sticker: Sprite2D = $Sticker
@onready var poof_particles: GPUParticles2D = $Poof

var held: bool = false

var claimed_by: Customer
var data: BoxData = null : set = _set_box_data

func _ready():
	sprite.material = sprite.material.duplicate()
	Global.boxes.append(self)
	Global.available_boxes.append(self)
	if(randi_range(0,3) > 1):
		sticker.texture = Global.box_stickers.pick_random()
		sticker.rotation = randi_range(1,360)
		sticker.position = Vector2(randi_range(-4,4),randi_range(-4,4))
	
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
	
func open(new_tex: Texture):
	sticker.hide()
	sprite.modulate = Color.WHITE
	sprite.texture = new_tex
	poof_particles.emitting = true
	
func poof():
	sticker.hide()
	sprite.texture = null
	poof_particles.emitting = true
