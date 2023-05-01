extends Control

@onready var start_button: Button = $"CanvasLayer/Start Button"

@onready var black_screen: ColorRect = $CanvasLayer/ColorRect
var fade_tween: Tween

func _ready():
	start_button.connect("pressed",Callable(self,"_on_start_pressed"))
	black_screen.modulate = Color.BLACK
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(black_screen,"modulate",Color(0,0,0,0),1.0)
	
func _on_start_pressed():
	if(fade_tween):
		return
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(black_screen, "modulate", Color.BLACK, 1.0)
	await fade_tween.finished
	get_tree().change_scene_to_file("res://main_game.tscn")
