extends Control

onready var ServerLineEdit = get_node("Panel/TabContainer/Multiplayer/Panel/ServerLineEdit")
onready var ServerList = get_node("Panel/TabContainer/Multiplayer/Panel/ServerList")
onready var AddonList = get_node("Panel/TabContainer/Addons/AddonPanel/AddonList")
onready var DirectConnectCheck = get_node("Panel/TabContainer/Multiplayer/Panel/DCCheck")
onready var ExecLineEdit = get_node("Panel/TabContainer/Settings/ExecPanel/ExecLineEdit")
onready var FullscreenOptions = get_node("Panel/TabContainer/Settings/DisplayPanel/FullscreenOptions")
# 0 - Windowed (Default)
# 1 - Fullscreen
# 2 - Borderless
onready var RenderOptions = get_node("Panel/TabContainer/Settings/DisplayPanel/RenderOptions")
# 0 - Software (Default)
# 1 - OpenGL
onready var CustomParameters = get_node("Panel/TabContainer/Settings/OtherPanel/ParameterTextEdit")


# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "X11":
		$ExecDialog.set_filters(PoolStringArray([]))
		$ExecDialog.set_current_file("srb2kart")
		$ExecDialog.set_current_path("/srb2kart")
		
	load_data()
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("addonlists")
	pass # Replace with function body.

func load_data():
	var file = File.new()
	file.open("user://nyoom.cfg", File.READ)
	if file.file_exists("user://nyoom.cfg"):
		file.open("user://nyoom.cfg", File.READ)
		var data = file.get_var(true)
		if data.has("Server"):
			ServerLineEdit.text = data["Server"]
		if data.has("ServerList"):
			ServerList.items = data["ServerList"]
		if data.has("AddonList"):
			AddonList.items = data["AddonList"]
		if data.has("Executable"):
			ExecLineEdit.text = data["Executable"]
		if data.has("DirectConnect"):
			DirectConnectCheck.pressed = data["DirectConnect"]
		if data.has("Nickname"):
			$Panel/TabContainer/Multiplayer/Panel/NicknameLineEdit.text = data["Nickname"]
		if data.has("FullscreenMode"):
			FullscreenOptions.selected = data["FullscreenMode"]
		if data.has("RenderMode"):
			RenderOptions.selected = data["RenderMode"]
		if data.has("CustomParameters"):
			CustomParameters.text = data["CustomParameters"]
		file.close()

func save_data():
	var file = File.new()
	file.open("user://nyoom.cfg", File.WRITE)
	var data = {}
	data["Server"] = ServerLineEdit.text
	data["ServerList"] = ServerList.items
	data["AddonList"] = AddonList.items
	data["Executable"] = ExecLineEdit.text
	data["DirectConnect"] = DirectConnectCheck.pressed
	data["Nickname"] = $Panel/TabContainer/Multiplayer/Panel/NicknameLineEdit.text
	data["FullscreenMode"] = $Panel/TabContainer/Settings/DisplayPanel/FullscreenOptions.selected
	data["RenderMode"] = $Panel/TabContainer/Settings/DisplayPanel/RenderOptions.selected
	data["CustomParameters"] = CustomParameters.text
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
	if $Panel/TabContainer/Multiplayer/Panel/NicknameLineEdit.text != "":
		args.append("+name")
		args.append($Panel/TabContainer/Multiplayer/Panel/NicknameLineEdit.text)
	match $Panel/TabContainer/Settings/DisplayPanel/RenderOptions.selected:
		0:
			args.append("-software")
		1:
			args.append("-opengl")
	match $Panel/TabContainer/Settings/DisplayPanel/FullscreenOptions.selected:
		0:
			args.append("-win")
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
	if CustomParameters.text != "":
		for line in CustomParameters.get_parameters():
			if !line.begins_with("#"):
				args.append(line)
	if !AddonList.items.empty():
		args.append("-file")
		for addon in AddonList.get_item_count():
			print(AddonList.get_item_text(addon))
			args.append(AddonList.get_item_text(addon))
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


func _on_AddonAddButton_pressed():
	if OS.get_name() == "X11": # linux's content folder is separate from the executable, so lest search for that.
		# start in ~/.srb2kart or HOME if it doesnt exist
		$AddonDialog.current_path = OS.get_environment("HOME")+"/" 
		$AddonDialog.current_path = OS.get_environment("HOME")+"/.srb2kart/"
		# search home if set
		if CustomParameters.text != "":
			for line in CustomParameters.get_parameters():
				if line.begins_with("-home"):
					$AddonDialog.current_path = line.right(6)+"/.srb2kart/"
	else:
		$AddonDialog.current_path = ExecLineEdit.text
	$AddonDialog.current_file = ""
	$AddonDialog.popup()
	pass # Replace with function body.


func _on_AddonDialog_files_selected(paths):
	for addon in paths:
		print(addon)
		AddonList.add_item(addon)
	pass # Replace with function body.


func _on_AddonRemoveButton_pressed():
	if AddonList.is_anything_selected():
		AddonList.remove_item(AddonList.get_selected_items()[0])


func _on_AddonListDialog_file_selected(path):
	var file = File.new()
	# Store the addon list in a human readable plaintext format. Iterates through the list of
	# addons to do this, rather than solely rely on saving the list variable.
	if $AddonListDialog.mode == $AddonListDialog.MODE_SAVE_FILE:
		file.open(path, File.WRITE)
		print(AddonList.items)
		for addon in AddonList.get_item_count():
			file.store_line(AddonList.get_item_text(addon))
	elif $AddonListDialog.mode == $AddonListDialog.MODE_OPEN_FILE:
		file.open(path, File.READ)
		# Clear the addon list currently present
		AddonList.clear()
		while not file.eof_reached(): # iterate through all lines until the end of file is reached
			AddonList.add_item(file.get_line())


func _on_AddonSaveBtn_pressed():
	$AddonListDialog.current_dir = OS.get_user_data_dir()+"/addonlists"
	$AddonListDialog.mode = $AddonListDialog.MODE_SAVE_FILE
	$AddonListDialog.window_title = "Save Addon List"
	$AddonListDialog.popup()
	pass # Replace with function body.


func _on_AddonLoadBtn_pressed():
	$AddonListDialog.current_dir = OS.get_user_data_dir()+"/addonlists"
	$AddonListDialog.mode = $AddonListDialog.MODE_OPEN_FILE
	$AddonListDialog.window_title = "Load Addon List"
	$AddonListDialog.popup()
	pass # Replace with function body.
