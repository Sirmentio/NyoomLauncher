extends TextEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var commands: Array = ["file"]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Strings
	add_color_region("#", "", Color(0.6, 0.6, 0.6, 1.0), true)
	
	# Strings
	add_color_region("\"", "\"", Color(1.0, 0.6, 1.0, 1.0), true)
	
	# Commandline parameters
	add_color_region("-", " ", Color(0.6, 0.6, 1.0, 1.0), true)

	# Autorun scripts
	add_color_region("+", " ", Color(0.6, 1.0, 0.6, 1.0), true)
	pass # Replace with function body.


func get_parameters():
	return get_text().split("\n")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
