extends Area2D
class_name Customer

@onready var speech_bubble: Node2D = $"Speech Bubble"
@onready var speech_text: RichTextLabel = $"Speech Bubble/Text"

var move_speed: float = 96
var moving: bool = false

var destination_position: Vector2

var drop_area: DropArea: set = _set_drop_area

var text_tween: Tween

var wanted_package: Pickupable

var got_package = false

signal on_move_complete

func _ready():
	speech_bubble.hide()
	wanted_package = Global.boxes.pick_random()

func _process(delta):
	if(moving):
		global_position = global_position.move_toward(destination_position, delta * move_speed)
		if(global_position == destination_position):
			moving = false
			destination_position = Vector2.ZERO
			emit_signal("on_move_complete")

func move_to(destination: Vector2):
	destination_position = destination
	moving = true
	
func _set_drop_area(value: DropArea):
	drop_area = value
	move_to(drop_area.position - Vector2(128,0))
	await on_move_complete
	speech_bubble.show()
	set_text(wanted_package.size)
	
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
	wanted_package.get_parent().remove_child(wanted_package)
	add_child(wanted_package)
	wanted_package.position = Vector2.ZERO
	move_to(Vector2.ZERO)
	await on_move_complete
	Global.boxes.erase(wanted_package)
	queue_free()
	
func check_box(box: Node2D):
	if(box == wanted_package):
		set_text("ok this is my package")
		call_deferred("get_package_and_leave")
		return true
	set_text("this isn't my package binch")
	return false
	
