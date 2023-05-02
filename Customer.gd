extends Node2D
class_name Customer

@onready var speech_bubble: Node2D = $"Speech Bubble"
@onready var speech_text: RichTextLabel = $"Speech Bubble/Text"
@onready var pickup_area: Area2D = $"Pickup Zone"
@onready var sprite: AnimatedSprite2D = $"Customer Sprite"

var move_speed: float = 96
var moving: bool = false

var destination_position: Vector2

var text_tween: Tween
@onready var text_timer: Timer = $"Text Timer"

var wanted_package: Pickupable

var interaction_done = false
var mad = false

signal on_move_complete

var package_description: String = "asdasdasdasd"

var data: CustomerData

signal on_customer_got_correct_package
signal on_customer_got_incorrect_package
signal on_customer_leave

var strikes: int = 0

var selected: bool = false
var can_interact: bool = false

func _ready():
	speech_bubble.hide()
	wanted_package = Global.available_boxes.pick_random()
	Global.available_boxes.erase(wanted_package)
	_set_description()
	set_data(Global.customer_list.pick_random())
	pickup_area.connect("mouse_entered", Callable(self, "_on_hover").bind(true))
	pickup_area.connect("mouse_exited", Callable(self, "_on_hover").bind(false))
	sprite.material = sprite.material.duplicate()
	await on_move_complete
	can_interact = true
	speech_bubble.show()
	set_text(package_description)
	

func _process(delta):
	z_index = int(position.y)
	if(moving):
		global_position = global_position.move_toward(destination_position, delta * move_speed)
		var velocity: Vector2 = destination_position - global_position
		sprite.flip_h = (velocity.x < 0)
		if(global_position == destination_position):
			moving = false
			destination_position = Vector2.ZERO
			emit_signal("on_move_complete")
			
func _set_description():
	match(randi_range(1,10)):
		1,2,3,4: #COLOR
			var color_string = Global.box_colors[wanted_package.data.color]
			package_description = "I'm here for the %s box." % color_string
		5,6,7,8,9: #SIZE
			package_description = "I'm here for the %s box." % wanted_package.data.size
		10: #SERIAL NUMBER
			package_description = "I'm here for box %s." % wanted_package.data.serial_number

func move_to(destination: Vector2):
	destination_position = destination
	moving = true
	if(interaction_done && !mad):
		sprite.animation = "happy"
	else:
		sprite.animation = "idle"
	sprite.play()
	await on_move_complete
	sprite.animation = "talk"
	sprite.play()
	
func set_text(text: String, timed: bool = false):
	speech_text.clear()
	speech_text.append_text("[center]")
	speech_text.append_text("[shake rate=8 level=8]")
	speech_text.push_color(Color.BLACK)
	speech_text.add_text(text)
	speech_text.pop()
	speech_text.pop()
	speech_text.pop()
	speech_text.visible_ratio = 0
	if(text_tween):
		text_tween.kill()
	text_tween = get_tree().create_tween()
	text_tween.tween_property(speech_text, "visible_ratio", 1, 0.5)
	if(timed):
		if(!text_timer.is_stopped()):
			text_timer.stop()
		text_timer.start(1.5)
		clear_text()

func clear_text():
	await text_timer.timeout
	speech_bubble.hide()
	
func get_package_and_leave():
	if(interaction_done):
		return
	interaction_done = true
	emit_signal("on_customer_got_correct_package")
	speech_bubble.show()
	set_text("ok this is my package")
	wanted_package.get_parent().remove_child(wanted_package)
	add_child(wanted_package)
	wanted_package.position = Vector2(64,-16)
	wanted_package.open(data.item_sprite)
	wanted_package.collider.disabled = true
	leave()
	
func leave_angry():
	if(interaction_done):
		return
	interaction_done = true
	emit_signal("on_customer_got_incorrect_package")
	wanted_package.poof()
	await get_tree().create_timer(2.0).timeout
	wanted_package.get_parent().remove_child(wanted_package) #move the package to the shadow realm
	leave()
	
func leave():
	move_to(Vector2(96,256))
	await on_move_complete
	Global.boxes.erase(wanted_package)
	emit_signal("on_customer_leave")
	queue_free()
	
func check_box(box: Node2D):
	if(interaction_done):
		return
	print(box.name)
	if(box == wanted_package):
		call_deferred("get_package_and_leave")
		set_text("Thanks.", true)
		return true
	else:
		strikes += 1
		if(strikes < 3):
			set_text("this isn't my package. " + package_description)
		else:
			set_text("for the last time, this isn't my package! " + package_description)
		if(strikes > 3):
			call_deferred("leave_angry")
			mad = true
			set_text("Fucking idiot.", true)
		return false
		
func set_data(data: CustomerData):
	self.data = data
	sprite.sprite_frames = data.animations
	
func _on_hover(over: bool):
	selected = over
	if(selected):
		sprite.material.set("shader_parameter/line_color", Color.WHITE)
		Global.selected_customers.append(self)
	else:
		sprite.material.set("shader_parameter/line_color", Color(1,1,1,0))
		Global.selected_customers.erase(self)
	pass
	
	
