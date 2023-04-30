extends Area2D
class_name Customer

@onready var speech_bubble: Node2D = $"Speech Bubble"
@onready var speech_text: RichTextLabel = $"Speech Bubble/Text"
@onready var pickup_area: Area2D = $"Pickup Zone"

var move_speed: float = 96
var moving: bool = false

var destination_position: Vector2

var text_tween: Tween

var wanted_package: Pickupable

var got_package = false

signal on_move_complete

var package_description: String = "asdasdasdasd"

signal on_customer_got_correct_package
signal on_customer_leave

func _ready():
	speech_bubble.hide()
	wanted_package = Global.available_boxes.pick_random()
	Global.available_boxes.erase(wanted_package)
	_set_description()
	pickup_area.connect("body_entered", Callable(self,"check_box"))
	pickup_area.connect("body_exited", Callable(self,"clear_box"))
	await on_move_complete
	speech_bubble.show()
	set_text(package_description)

func _process(delta):
	z_index = int(position.y)
	if(moving):
		global_position = global_position.move_toward(destination_position, delta * move_speed)
		if(global_position == destination_position):
			moving = false
			destination_position = Vector2.ZERO
			emit_signal("on_move_complete")
			
func _set_description():
	match(randi_range(1,2)):
		1: #COLOR
			var color_string = Global.box_colors[wanted_package.data.color]
			package_description = "I'm here for the %s package." % color_string
		2: #SIZE
			package_description = "I'm here for the %s package." % wanted_package.data.size
		3: #SERIAL NUMBER
			package_description = "I'm here for package %s." % wanted_package.data.serial_number

func move_to(destination: Vector2):
	destination_position = destination
	moving = true
	
func set_text(text: String):
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
	
func get_package_and_leave():
	if(got_package):
		return
	got_package = true
	emit_signal("on_customer_got_correct_package")
	set_text("ok this is my package")
	speech_bubble.show()
	wanted_package.get_parent().remove_child(wanted_package)
	add_child(wanted_package)
	wanted_package.position = Vector2.ZERO
	wanted_package.collider.disabled = true
	move_to(Vector2.ZERO)
	await on_move_complete
	Global.boxes.erase(wanted_package)
	emit_signal("on_customer_leave")
	queue_free()
	
func check_box(box: Node2D):
	print("WHAT: " + box.name)
	if(box == wanted_package):
		call_deferred("get_package_and_leave")
	set_text("this isn't my package binch")
	
func clear_box(_box: Node2D):
	if(got_package):
		set_text("Thanks.")
		await get_tree().create_timer(1.5).timeout
		speech_bubble.hide()
	else:
		set_text(package_description)
	
