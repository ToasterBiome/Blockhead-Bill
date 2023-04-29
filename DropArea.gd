extends Area2D
class_name DropArea

var customer: Customer

func _ready():
	connect("body_entered",Callable(self,"_on_body_entered"))
	
func _on_body_entered(body: Node2D):
	body.position = position
	if(customer):
		customer.check_box(body)
	
