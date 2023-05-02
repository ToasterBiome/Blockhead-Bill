extends Node

var version = 0.7
var box_sprites: Dictionary = {
	"normal": preload("res://sprites/box1.png"),
	"long": preload("res://sprites/box2.png"),
	"tall": preload("res://sprites/box3.png"),
	"fucked": preload("res://sprites/box4.png"),
	"small": preload("res://sprites/box5.png"),
	"thin": preload("res://sprites/box6.png"),
	"L": preload("res://sprites/box7.png"),
	"slanted": preload("res://sprites/box8.png")
	}
	
var box_stickers = [
	preload("res://sprites/label1.png"),
	preload("res://sprites/label2.png"),
	preload("res://sprites/label3.png"),
	preload("res://sprites/label4.png"),
	preload("res://sprites/label5.png"),
	preload("res://sprites/label6.png"),
]
	
var box_colors = {
	Color.RED: "red",
	Color.GREEN: "green",
	Color.YELLOW: "yellow",
	Color.SADDLE_BROWN: "brown"
}

var customer_list = [
	preload("res://customers/astronaut.tres"),
	preload("res://customers/burglar.tres"),
	preload("res://customers/cowboy.tres"),
	preload("res://customers/robot.tres"),
	preload("res://customers/wizard.tres")
]

var levels = [
	preload("res://levels/T.tres"),
	preload("res://levels/1.tres"),
	preload("res://levels/2.tres"),
	preload("res://levels/3.tres"),
	preload("res://levels/4.tres"),
	preload("res://levels/5.tres")
]

var level = 1

var random_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678"

var boxes = []
var available_boxes = []

var selected_customers = []

func get_serial_number(length: int):
	var result = ""
	for n in length:
		result += random_characters[randi() % random_characters.length()]
	return result
