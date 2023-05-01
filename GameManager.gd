extends Node2D
class_name GameManager

@onready var spawn_area: Area2D = $"Box Spawn"
@onready var customer_spawn_area = $"Door Spawn"

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

var write_ups: int = 0

@onready var manifest_container = $"GUI/Manifest/Contents/Vertical Container"
var manifest_entry = preload("res://manifest_entry.tscn")

var customers_around = 0

var time_left = 120 #in seconds

@onready var day_text = $"GUI/Day Label"
@onready var time_text = $"GUI/Timer Label"
@onready var black_screen = $"GUI/Black Screen"
@onready var continue_text = $"GUI/Black Screen/Continue Text"
@onready var lose_text = $"GUI/Black Screen/Game Over Text"
@onready var win_menu_button: Button = $"GUI/Black Screen/HBoxContainer/Win Main Menu"
@onready var win_next_level_button: Button = $"GUI/Black Screen/HBoxContainer/Win Next Level"
@onready var solo_menu_button: Button = $"GUI/Black Screen/Solo Main Menu"
@onready var fade_screen: ColorRect = $"GUI/Fade Screen"

var fade_tween: Tween

enum GameState {
	GAME_START,
	GAME_PLAYING,
	GAME_OVER,
	GAME_CONTINUE,
	GAME_WIN
}

var game_state: GameState = GameState.GAME_START: set = set_game_state
signal on_game_state_changed(new_state)
var can_spawn_box = true

func _ready():
	generate_boxes(Global.levels[Global.level - 1].packages)
	time_left = Global.levels[Global.level - 1].seconds
	day_text.text = "Day " + str(Global.level)
	make_manifest()
	box_spawn_timer.connect("timeout", Callable(self, "spawn_box"))
	box_spawn_timer.start()
	customer_spawn_timer.connect("timeout", Callable(self, "spawn_customer"))
	customer_spawn_timer.start()
	_update_time()
	clock_timer.connect("timeout", Callable(self, "_on_clock_changed"))
	clock_timer.start()
	game_state = GameState.GAME_PLAYING
	
	win_menu_button.connect("pressed",Callable(self,"_go_to_scene").bind("res://main_menu.tscn"))
	solo_menu_button.connect("pressed",Callable(self,"_go_to_scene").bind("res://main_menu.tscn"))
	win_next_level_button.connect("pressed",Callable(self,"_next_level"))
	spawn_area.connect("body_exited",Callable(self,"_on_box_clear_conveyer"))
	
	fade_screen.modulate = Color.BLACK
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(fade_screen,"modulate",Color(0,0,0,0),1.0)
	
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
	if(!can_spawn_box):
		return
	can_spawn_box = false
	var box_to_spawn = boxes_to_spawn[0]
	boxes_to_spawn.erase(box_to_spawn)
	var box = box_scene.instantiate()
	box.position = spawn_area.position
	add_child(box)
	box.data = box_to_spawn
	if(boxes_to_spawn.size() == 0):
		box_spawn_timer.stop()
		
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
	customer.connect("on_customer_got_incorrect_package", Callable(self, "_on_customer_got_incorrect_package").bind(customer))
	customer.connect("on_customer_leave", Callable(self,"_on_customer_leave"))
	add_child(customer)
	customer.position = customer_spawn_area.position
	customer.move_to(drop_area.position)
	customers_around += 1
	
func _on_customer_got_correct_package(customer: Customer):
	move_customers_up(customer)
			
func _on_customer_got_incorrect_package(customer: Customer):
	move_customers_up(customer)
	write_ups += 1
	if(write_ups > 3):
		_game_over("You were fired for being written up too many times.")
			
func move_customers_up(customer_to_remove: Customer):
	print("moving")
	customers_waiting.erase(customer_to_remove)
	for other_customer in customers_waiting:
		var should_be_at = standing_areas[customers_waiting.find(other_customer)]
		if(other_customer.position != should_be_at.position):
			other_customer.move_to(should_be_at.position)
			
func _on_customer_leave():
	customers_around -= 1
	if(Global.available_boxes.size() == 0 && customers_around == 0):
		_win()
		
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
		_game_over("You were fired for getting 23 seconds of overtime.")
		
func _game_over(reason: String):
	clock_timer.stop()
	game_state = GameState.GAME_OVER
	solo_menu_button.show()
	black_screen.show()
	black_screen.modulate = Color(0,0,0,0)
	continue_text.hide()
	lose_text.show()
	lose_text.clear()
	lose_text.append_text("[center]")
	lose_text.push_color(Color("#FF0000"))
	lose_text.add_text(reason)
	lose_text.pop()
	lose_text.pop()
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.tween_property(black_screen,"modulate",Color.WHITE,1.0)
	
func _win():
	clock_timer.stop()
	if(Global.level >= Global.levels.size() - 1):
		game_state = GameState.GAME_WIN
		solo_menu_button.show()
		continue_text.clear()
		continue_text.append_text("[center]")
		continue_text.push_color(Color("#FFEDFA"))
		continue_text.add_text("You've earned a pizza party, good work! Thank you for playing.")
		continue_text.pop()
		continue_text.pop()
	else:
		game_state = GameState.GAME_CONTINUE
		win_menu_button.show()
		win_next_level_button.show()
	black_screen.show()
	black_screen.modulate = Color(0,0,0,0)
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.tween_property(black_screen,"modulate",Color.WHITE,1.0)
	
func _go_to_scene(scene):
	if(fade_tween):
		return
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(fade_screen,"modulate",Color.BLACK,1.0)
	await fade_tween.finished
	get_tree().change_scene_to_file(scene)
	
func _next_level():
	Global.level += 1
	_go_to_scene("res://main_game.tscn")
	
func _on_box_clear_conveyer(_body: Node2D):
	print("passed")
	can_spawn_box = true
