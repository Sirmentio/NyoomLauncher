extends Control

onready var ServerLineEdit = get_node("Panel/TabContainer/Nyoom/Panel/ServerLineEdit")
onready var ServerList = get_node("Panel/TabContainer/Nyoom/Panel/ServerList")
onready var DirectConnectCheck = get_node("Panel/TabContainer/Nyoom/Panel/DCCheck")
onready var ExecLineEdit = get_node("Panel/TabContainer/Settings/ExecPanel/ExecLineEdit")
onready var FullscreenOptions = get_node("Panel/TabContainer/Settings/DisplayPanel/FullscreenOptions")
# 0 - Windowed (Default)
# 1 - Fullscreen
# 2 - Borderless
onready var RenderOptions = get_node("Panel/TabContainer/Settings/DisplayPanel/RenderOptions")
# 0 - Software (Default)
# 1 - OpenGL

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "X11":
		$ExecDialog.set_filters(PoolStringArray([]))
		$ExecDialog.set_current_file("srb2kart")
		$ExecDialog.set_current_path("/srb2kart")
		
	load_data()
	pass # Replace with function body.

func load_data():
	var file = File.new()
	file.open("user://nyoom.cfg", File.READ)
	if file.file_exists("user://nyoom.cfg"):
		file.open("user://nyoom.cfg", File.READ)
		var data = file.get_var()
		if data.has("Server"):
			ServerLineEdit.text = data["Server"]
		if data.has("ServerList"):
			ServerList.items = data["ServerList"]
		if data.has("Executable"):
			ExecLineEdit.text = data["Executable"]
		if data.has("DirectConnect"):
			DirectConnectCheck.pressed = data["DirectConnect"]
		if data.has("Nickname"):
			$Panel/TabContainer/Nyoom/Panel/NicknameLineEdit.text = data["Nickname"]
		if data.has("FullscreenMode"):
			FullscreenOptions.selected = data["FullscreenMode"]
		if data.has("RenderMode"):
			RenderOptions.selected = data["RenderMode"]
		if data.has("SkipIntro"):
			$Panel/TabContainer/Settings/OtherPanel/IntroCheck.pressed = data["SkipIntro"]
		if data.has("HomeCheck"):
			$Panel/TabContainer/Settings/OtherPanel/HomeCheck.pressed = data["HomeCheck"]
		if data.has("Home"):
			$Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.text = data["Home"]
		file.close()

func save_data():
	var file = File.new()
	file.open("user://nyoom.cfg", File.WRITE)
	var data = {}
	data["Server"] = ServerLineEdit.text
	data["ServerList"] = ServerList.items
	data["Executable"] = ExecLineEdit.text
	data["DirectConnect"] = DirectConnectCheck.pressed
	data["Nickname"] = $Panel/TabContainer/Nyoom/Panel/NicknameLineEdit.text
	data["FullscreenMode"] = $Panel/TabContainer/Settings/DisplayPanel/FullscreenOptions.selected
	data["RenderMode"] = $Panel/TabContainer/Settings/DisplayPanel/RenderOptions.selected
	data["SkipIntro"] = $Panel/TabContainer/Settings/OtherPanel/IntroCheck.pressed
	data["HomeCheck"] = $Panel/TabContainer/Settings/OtherPanel/HomeCheck.pressed
	data["Home"] = $Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.text
	file.store_var(data)
	file.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LaunchButton_pressed():
	var file = File.new()
	if !file.file_exists(ExecLineEdit.text):
		$ExecDialog.popup()
		if ExecLineEdit.text == "":
			$Dialog.info("Executable not configured. Please select your SRB2Kart executable.")
		else:
			$Dialog.error("The designated executable couldn't be found. Please select a valid SRB2Kart executable. ")
		return
	start_game()


func start_game():
	var args = PoolStringArray([])
	if ServerLineEdit.text != "" and DirectConnectCheck.pressed:
		args.append("-connect")
		args.append(ServerLineEdit.text)
	if $Panel/TabContainer/Nyoom/Panel/NicknameLineEdit.text != "":
		args.append("+name")
		args.append($Panel/TabContainer/Nyoom/Panel/NicknameLineEdit.text)
	match $Panel/TabContainer/Settings/DisplayPanel/RenderOptions.selected:
		0:
			args.append("-software")
		1:
			args.append("-opengl")
	match $Panel/TabContainer/Settings/DisplayPanel/FullscreenOptions.selected:
		0:
			args.append("-win")
			args.append("-width")
			args.append("1280")
			args.append("-height")
			args.append("800")
		1:
			args.append("+fullscreen 1")
			args.append("-width")
			args.append(OS.get_screen_size().x)
			args.append("-height")
			args.append(OS.get_screen_size().y)
		2:
			args.append("-win")
			args.append("-borderless")
			args.append("-width")
			args.append(OS.get_screen_size().x)
			args.append("-height")
			args.append(OS.get_screen_size().y)
	if $Panel/TabContainer/Settings/OtherPanel/IntroCheck.pressed:
		args.append("-skipintro")
	if $Panel/TabContainer/Settings/OtherPanel/HomeCheck.pressed and $Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.text != "":
			args.append("-home")
			args.append($Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.text)
	print(ExecLineEdit.text + String(args))
	OS.execute(ExecLineEdit.text, args, false)

func _on_ExitButton_pressed():
	save_data()
	get_tree().quit()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_data()
		get_tree().quit()

func _on_ExecDialog_file_selected(path):
	ExecLineEdit.text = path


func _on_ExecBrowseButton_pressed():
	var file = File.new()
	if file.file_exists(ExecLineEdit.text):
		$ExecDialog.current_path = ExecLineEdit.text
	$ExecDialog.popup()


func _on_AddButton_pressed():
	ServerList.add_item(ServerLineEdit.text)


func _on_RemoveButton_pressed():
	if ServerList.is_anything_selected():
		ServerList.remove_item(ServerList.get_selected_items()[0])


func _on_ServerList_item_selected(index):
	ServerLineEdit.text = String(ServerList.items[index*3])


func _on_Button_pressed():
	OS.shell_open(str("file://", OS.get_user_data_dir()))
	pass # Replace with function body.


func _on_DisplaySettings_changed(index):
	$Panel/TabContainer/Settings/DisplayPanel/DisplayHelpLabel.build_label(
		FullscreenOptions.selected,
		RenderOptions.selected
	)


func _on_DownloadButton_pressed():
	$DownloadDialog.show()



func _on_DownloadDialog_finished_everything(location):
	ExecLineEdit.text = location


func _on_HomeCheck_toggled(button_pressed):
	if button_pressed == true:
		$Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.set_editable(true)
		$Panel/TabContainer/Settings/OtherPanel/HomeLineEdit/HomeBrowseButton.set_disabled(false)
	else:
		$Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.set_editable(false)
		$Panel/TabContainer/Settings/OtherPanel/HomeLineEdit/HomeBrowseButton.set_disabled(true)

func _on_HomeBrowseButton_pressed():
	$HomeDialog.popup()

func _on_HomeDialog_dir_selected(dir):
	$Panel/TabContainer/Settings/OtherPanel/HomeLineEdit.set_text(dir)
