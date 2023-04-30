extends MarginContainer

func _ready():
	hide()

func _process(_delta):
	if(Input.is_action_just_pressed("manifest")):
		visible = !visible
