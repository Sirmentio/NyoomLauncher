extends WindowDialog

onready var _request = get_node("HTTPRequest")
var setup_step = 0

onready var Progress = $ProgressBar
onready var ProgressLabel = $ProgressBar/Label

signal finished_everything(location)

# Called when the node enters the scene tree for the first time.
func _ready():
	_request.connect("request_completed", self, "_on_download_complete")
	$LocationLineEdit.text = OS.get_user_data_dir()+"/srb2kart"
	$FileDialog.current_dir = OS.get_user_data_dir()+"/srb2kart"
	pass # Replace with function body.

func _on_LocBrowseButton_pressed():
	var file = File.new()
	if file.file_exists($LocationLineEdit.text):
		$FileDialog.current_path = $LocationLineEdit.text
	$FileDialog.popup()


func _on_FileDialog_dir_selected(dir):
	$LocationLineEdit.text = dir

# This was a pain in the ass to make.
# Not only is it a game of hot potato between the HTTP request node but also having to account
# for if steps are already completed, here we are. It's all segmented into two types of steps.
# This... HoooOOOOh, no wonder other launchers dont bother.

func download(loc, moe, step):
	print("Starting download step %s with Moe being %s at location %s" % [step, moe, loc])
	# Make a temp directory, if you havent already.
	
	var dir = Directory.new()
	dir.open(loc)
	if dir.dir_exists(loc) == false:
		dir.make_dir_recursive(loc)
	dir.change_dir(loc)
	# Check if srb2kart.exe is already present
	if !dir.file_exists(dir.get_current_dir()+"/srb2kart.exe"):
		# The function needs to be run in steps so that things can be done reliably, in order.
		if step == 0:
			# STEP ONE. DOWNLOAD SRB2KART
			ProgressLabel.text = "Downloading SRB2Kart installer..."
			Progress.value = 1
			# Download the exe if not already downloaded
			if !dir.file_exists(dir.get_current_dir()+"/srb2kart-installer.exe"):
				if OS.get_name() == "Windows":
					_request.set_download_file(dir.get_current_dir()+"/"+"srb2kart-installer.exe")
					_request.request("https://github.com/STJr/Kart-Public/releases/download/v1.3/srb2kart-v13-Installer.exe")
					return
		if step == 1:
			# STEP TWO. RUN THE INSTALLER
			ProgressLabel.text = "Done. Running installer. Make sure the directory is the same!"
			Progress.value = 2
			# Take a second so that blocking doesnt interrupt the gui updating.
			yield(get_tree().create_timer(1.0), "timeout")
			# Run the installer, block any further execution until it's done.
			OS.execute(dir.get_current_dir()+"/"+"srb2kart-installer.exe", [], true)
			if !dir.file_exists(dir.get_current_dir()+"/srb2kart.exe"):
				ProgressLabel.text = "Installation failed. Did you install it to the right place?"
				return
			# We won't need this anymore.
			dir.remove("./srb2kart-installer.exe")
	# STEP THREE. Install Moe... If selected
	if !dir.file_exists(dir.get_current_dir()+"/srb2kart-moe.exe") and moe == true and step == 1:
			ProgressLabel.text = "Downloading SRB2Kart Moe✨"
			Progress.value = 3
			# Download the exe if not already downloaded
			print(dir.get_current_dir()+"/srb2kart-moe.exe")
			if !dir.file_exists(dir.get_current_dir()+"/srb2kart-moe.exe"):
				if OS.get_name() == "Windows":
					_request.set_download_file(dir.get_current_dir()+"/"+"srb2kart-moe.exe")
					_request.request("https://kart.moe/moe-mansion/32-bit/srb2kart-moe.exe")
					return
	else:
		# SRB2Kart standalone is done
		Progress.value = 4
		ProgressLabel.text = "Done."
		emit_signal("finished_everything", $LocationLineEdit.text+"/srb2kart.exe")
		$DownloadButton.disabled = false
	return

func _on_download_complete(result, response_code, headers, body):
	print("Request completed ", result, ", ", response_code)
	if result != 0:
		ProgressLabel.text = "Download failed on setup step " + setup_step + "..."
		$DownloadButton.disabled = false
		return # Do nothing else.
	# If the setup step was 0, and the installer downloaded without any fault, then proceed
	if setup_step == 0 and result == 0:
		setup_step = 1
		download($LocationLineEdit.text, $MoeCheck.pressed, setup_step)
		return
	if setup_step == 1 and result == 0:
		# SRB2Kart Moe is done
		Progress.value = 4
		ProgressLabel.text = "Done."
		emit_signal("finished_everything", $LocationLineEdit.text+"/srb2kart-moe.exe")
		$DownloadButton.disabled = false

func _on_DownloadButton_pressed():
	$DownloadButton.disabled = true
	var dir = Directory.new()
	dir.open($LocationLineEdit.text)
	dir.change_dir($LocationLineEdit.text)
	setup_step = 0
	if !dir.file_exists(dir.get_current_dir()+"/srb2kart.exe") and !$MoeCheck.pressed:
		download($LocationLineEdit.text, $MoeCheck.pressed, setup_step)
		return
	else:
		ProgressLabel.text = "SRB2Kart is already downloaded!"
		print(dir.get_current_dir()+"/srb2kart.exe")
	
	if !dir.file_exists(dir.get_current_dir()+"/srb2kart-moe.exe") and $MoeCheck.pressed:
		download($LocationLineEdit.text, $MoeCheck.pressed, setup_step)
		return
	else:
		ProgressLabel.text = "SRB2Kart Moe is already downloaded!"
		print(dir.get_current_dir()+"/srb2kart-moe.exe")
	$DownloadButton.disabled = false
