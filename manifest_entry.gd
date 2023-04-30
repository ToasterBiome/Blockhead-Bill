extends RichTextLabel
class_name ManifestEntry

var box: BoxData

func set_box(box: BoxData):
	self.box = box
	text = ""
	append_text("[center]")
	append_text("[shake rate=2 level=2]")
	push_color(Color.BLACK)
	add_text("%s, %s, %s" % [box.serial_number, Global.box_colors[box.color].to_upper(), box.size.to_upper()])
	pop()
	pop()
	pop()
