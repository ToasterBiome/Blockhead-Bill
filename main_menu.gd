extends Control

@onready var exit_button: Button = $"CanvasLayer/HBoxContainer/Exit Button"
@onready var credits_button: Button = $"CanvasLayer/HBoxContainer/Credits Button"
@onready var start_button: Button = $"CanvasLayer/HBoxContainer/Start Button"

@onready var black_screen: ColorRect = $"CanvasLayer/Black Screen"
@onready var credits: ColorRect = $CanvasLayer/Credits
@onready var intro: ColorRect = $CanvasLayer/Intro

@onready var version: Label = $CanvasLayer/Version
var fade_tween: Tween

func _ready():
	exit_button.connect("pressed",Callable(self,"_on_exit_pressed"))
	credits_button.connect("pressed",Callable(self,"_on_credits_pressed"))
	start_button.connect("pressed",Callable(self,"_on_start_pressed"))
	version.text = "v" + str(Global.version)
	intro.modulate = Color.WHITE
	black_screen.modulate = Color.BLACK
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(black_screen,"modulate",Color(0,0,0,0),1.0)
	await get_tree().create_timer(3.0).timeout
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(intro,"modulate",Color(0,0,0,0),1.0)
	await get_tree().create_timer(1.0).timeout
	intro.mouse_filter = MOUSE_FILTER_IGNORE
	
func _on_exit_pressed():
	if(fade_tween):
		return
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(black_screen, "modulate", Color.BLACK, 1.0)
	await fade_tween.finished
	get_tree().quit()
	
func _on_credits_pressed():
	credits.visible = !credits.visible
	
func _on_start_pressed():
	if(fade_tween):
		return
	fade_tween = get_tree().create_tween()
	fade_tween.tween_property(black_screen, "modulate", Color.BLACK, 1.0)
	await fade_tween.finished
	get_tree().change_scene_to_file("res://main_game.tscn")
