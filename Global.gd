extends Node

var player: CharacterBody2D

var box_sprites: Dictionary = {
	"normal": preload("res://sprites/box1.png"),
	"long": preload("res://sprites/box2.png"),
	"tall": preload("res://sprites/box3.png"),
	"fucked up": preload("res://sprites/box4.png"),
	"small": preload("res://sprites/box5.png"),
	"idk it looks the same": preload("res://sprites/box6.png"),
	"really tall": preload("res://sprites/box7.png"),
	}
	
var box_colors = [
	Color.RED,
	Color.GREEN,
	Color.YELLOW,
	Color.SADDLE_BROWN
]

var random_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345678"

var boxes = []

func get_serial_number(length: int):
	var result = ""
	for n in length:
		result += random_characters[randi() % random_characters.length()]
	return result
