extends Node

var player: CharacterBody2D

var box_sprites: Dictionary = {
	"normal": preload("res://sprites/box1.png"),
	"long": preload("res://sprites/box2.png"),
	"tall": preload("res://sprites/box3.png"),
	"fucked": preload("res://sprites/box4.png"),
	"small": preload("res://sprites/box5.png"),
	"idk": preload("res://sprites/box6.png"),
	"v. tall": preload("res://sprites/box7.png"),
	}
	
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

var random_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678"

var boxes = []
var available_boxes = []

func get_serial_number(length: int):
	var result = ""
	for n in length:
		result += random_characters[randi() % random_characters.length()]
	return result
