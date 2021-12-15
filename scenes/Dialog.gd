extends WindowDialog

func error(string: String):
	window_title = ":oh:"
	$ErrorSound.play()
	$Label.text = "An error occured."
	$ErrorLabel.show()
	$ErrorLabel.text = string
	popup()

func info(string: String):
	window_title = "Hold up."
	$Label.text = string
	$ErrorLabel.hide()
	popup()
	


func _on_Button_pressed():
	hide()
