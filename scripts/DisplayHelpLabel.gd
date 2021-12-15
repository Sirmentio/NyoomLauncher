extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func build_label(fs, ren):
	self.text = ""
	match fs:
		0:
			self.text += "Windowed mode shows SRB2Kart in a plain, regular window."
		1:
			self.text += "Fullscreen mode takes exclusive management over the screen for SRB2Kart."
		2:
			self.text += "Borderless fullscreen combines a borderless window and the full screen width. Good for multiple monitors."
	self.text += " "
	match ren:
		0:
			self.text += "Software mode is compatible with most older hardware, at the expense of extra visual flair."
		1:
			self.text += "OpenGL allows for 3D model rendering, at the expense of some bugs and quirks."
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
