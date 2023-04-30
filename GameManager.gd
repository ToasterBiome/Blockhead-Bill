extends Node2D

@onready var spawn_area = $"Box Spawn"

@onready var box_spawn_timer = $"Timers/Box Spawn Timer"
@onready var customer_spawn_timer = $"Timers/Customer Spawn Timer"
@onready var standing_areas = [
	$"Standing Areas/1",
	$"Standing Areas/2",
	$"Standing Areas/3",
	$"Standing Areas/4",
	$"Standing Areas/5"
	]
	
@onready var customers_waiting = []

var box_scene = preload("res://box.tscn")
var customer_scene = preload("res://customer.tscn")

var boxes_to_spawn = []

func _ready():
	generate_boxes(10)
	box_spawn_timer.connect("timeout", Callable(self, "spawn_box"))
	box_spawn_timer.start()
	customer_spawn_timer.connect("timeout", Callable(self, "spawn_customer"))
	
func generate_boxes(amount: int):
	for n in amount:
		var box: BoxData = BoxData.new(
			Global.box_colors.keys().pick_random(),
			Global.box_sprites.keys().pick_random(),
			Global.get_serial_number(8)
			)
		
		boxes_to_spawn.append(box)
	
func spawn_box():
	var box_to_spawn = boxes_to_spawn[0]
	boxes_to_spawn.erase(box_to_spawn)
	var box = box_scene.instantiate()
	box.position = spawn_area.position
	add_child(box)
	box.data = box_to_spawn
	if(boxes_to_spawn.size() == 0):
		box_spawn_timer.stop()
		customer_spawn_timer.start()
		
func get_clear_drop_area():
	if(customers_waiting.size() >= standing_areas.size()):
		return null
	return standing_areas[customers_waiting.size()]
		
func spawn_customer():
	if(Global.available_boxes.size() == 0):
		return
	var drop_area = get_clear_drop_area()
	if(!drop_area):
		return
	var customer = customer_scene.instantiate()
	customers_waiting.append(customer)
	customer.connect("on_customer_got_correct_package", Callable(self, "_on_customer_got_correct_package").bind(customer))
	customer.connect("on_customer_leave", Callable(self,"_on_customer_leave"))
	customer.move_to(drop_area.position)
	add_child(customer)
	
func _on_customer_got_correct_package(customer: Customer):
	customers_waiting.erase(customer)
	for other_customer in customers_waiting:
		var should_be_at = standing_areas[customers_waiting.find(other_customer)]
		if(other_customer.position != should_be_at.position):
			other_customer.move_to(should_be_at.position)
			
func _on_customer_leave():
	if(Global.available_boxes.size() == 0 && customers_waiting.size() == 0):
		print("you win!")
	
