extends Node2D
class_name GameManager

@onready var spawn_area = $"Box Spawn"

@onready var box_spawn_timer = $"Timers/Box Spawn Timer"
@onready var customer_spawn_timer = $"Timers/Customer Spawn Timer"
@onready var clock_timer = $"Timers/Clock Timer"

@onready var standing_areas = [
	$"Standing Areas/1",
	$"Standing Areas/2",
	$"Standing Areas/3",
	$"Standing Areas/4",
	$"Standing Areas/5"
	]
	
var customers_waiting = []

var box_scene = preload("res://box.tscn")
var customer_scene = preload("res://customer.tscn")

var boxes_to_spawn = []

@onready var manifest_container = $"GUI/Manifest/Contents/Vertical Container"
var manifest_entry = preload("res://manifest_entry.tscn")

var customers_around = 0

var time_left = 120 #in seconds

@onready var day_text = $"GUI/Day Label"
@onready var time_text = $"GUI/Timer Label"
@onready var black_screen = $"GUI/Black Screen"
@onready var continue_text = $"GUI/Black Screen/Continue Text"
@onready var lose_text = $"GUI/Black Screen/Game Over Text"

enum GameState {
	GAME_START,
	GAME_PLAYING,
	GAME_OVER,
	GAME_CONTINUE,
	GAME_WIN
}

var game_state: GameState = GameState.GAME_START: set = set_game_state
signal on_game_state_changed(new_state)

func _ready():
	generate_boxes(5)
	make_manifest()
	box_spawn_timer.connect("timeout", Callable(self, "spawn_box"))
	box_spawn_timer.start()
	customer_spawn_timer.connect("timeout", Callable(self, "spawn_customer"))
	_update_time()
	clock_timer.connect("timeout", Callable(self, "_on_clock_changed"))
	clock_timer.start()
	game_state = GameState.GAME_PLAYING
	
func generate_boxes(amount: int):
	for n in amount:
		var box: BoxData = BoxData.new(
			Global.box_colors.keys().pick_random(),
			Global.box_sprites.keys().pick_random(),
			Global.get_serial_number(8)
			)
		boxes_to_spawn.append(box)
		
func make_manifest():
	for box in boxes_to_spawn:
		var entry: ManifestEntry = manifest_entry.instantiate()
		entry.set_box(box)
		manifest_container.add_child(entry)
	pass
	
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
	add_child(customer)
	customer.move_to(drop_area.position)
	customers_around += 1
	
func _on_customer_got_correct_package(customer: Customer):
	customers_waiting.erase(customer)
	for other_customer in customers_waiting:
		var should_be_at = standing_areas[customers_waiting.find(other_customer)]
		if(other_customer.position != should_be_at.position):
			other_customer.move_to(should_be_at.position)
			
func _on_customer_leave():
	customers_around -= 1
	if(Global.available_boxes.size() == 0 && customers_around == 0):
		game_state = GameState.GAME_CONTINUE
		black_screen.show()
		
func set_game_state(value: GameState):
	game_state = value
	emit_signal("on_game_state_changed", game_state)
	
func _on_clock_changed():
	time_left -= 1
	_update_time()
	
func _update_time():
	var seconds = fmod(time_left, 60.0)
	var minutes = int(time_left / 60.0) % 60
	var formatted_string: String = "%01d:%02d" % [minutes, seconds]
	time_text.text = formatted_string + " until overtime"
	if(time_left <= 0):
		clock_timer.stop()
		game_state = GameState.GAME_OVER
		black_screen.show()
		continue_text.hide()
		lose_text.show()
