extends Node2D

@onready var drop_areas: Array = [$DropArea,$DropArea2,$DropArea3]

@onready var spawn_area = $"Box Spawn"

@onready var box_spawn_timer = $"Timers/Box Spawn Timer"

var box_scene = preload("res://box.tscn")
var customer_scene = preload("res://customer.tscn")

var boxes_to_spawn = 10

func _ready():
	box_spawn_timer.connect("timeout", Callable(self, "spawn_box"))
	box_spawn_timer.start()

func generate_packages():
	pass
	
func generate_manifest():
	pass
	
func spawn_box():
	boxes_to_spawn -= 1
	var box = box_scene.instantiate()
	box.size = Global.box_sprites.keys().pick_random()
	box.color = Global.box_colors.pick_random()
	box.position = spawn_area.position
	add_child(box)
	if(boxes_to_spawn == 0):
		box_spawn_timer.stop()
		spawn_customer()
		
func spawn_customer():
	var customer = customer_scene.instantiate()
	customer.drop_area = drop_areas.pick_random()
	customer.drop_area.customer = customer
	add_child(customer)
	
	

