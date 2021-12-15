extends TextureButton


func _on_SPButton_pressed():
	$AnimationPlayer.play("nyoom")
	$AudioStreamPlayer.play()
	pass # Replace with function body.
