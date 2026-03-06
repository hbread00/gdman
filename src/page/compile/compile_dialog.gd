extends ConfirmationDialog

@onready var platform_option: OptionButton = $VBoxContainer/GridContainer/PlatformOption
@onready var architecture_option: OptionButton = $VBoxContainer/GridContainer/ArchitectureOption
@onready var command_line: LineEdit = $VBoxContainer/HBoxContainer/CommandLine

var file_path: String = ""

var platform_param: String = ""
var architecture_param: String = ""

func display(code_file_name: String, code_file_path: String) -> void:
	title = tr("COMPILE_TARGET") % code_file_name
	file_path = code_file_path
	platform_option.select(0)
	architecture_option.select(0)
	_update_command()
	popup_centered()

func _update_command() -> void:
	var command: String = ("scons" + platform_param + architecture_param).strip_edges()
	command_line.text = command
	command_line.tooltip_text = command

func _on_platform_option_item_selected(index: int) -> void:
	match index:
		0:
			platform_param = ""
		1:
			platform_param = " platform=windows"
		2:
			platform_param = " platform=linuxbsd"
		3:
			platform_param = " platform=macos"
		4:
			platform_param = " platform=android"
		5:
			platform_param = " platform=ios"
		6:
			platform_param = " platform=visionos"
		7:
			platform_param = " platform=web"
		_:
			platform_param = ""
	_update_command()


func _on_architecture_option_item_selected(index: int) -> void:
	match index:
		0:
			architecture_param = ""
		1:
			architecture_param = " arch=x86_32"
		2:
			architecture_param = " arch=x86_64"
		3:
			architecture_param = " arch=arm32"
		4:
			architecture_param = " arch=arm64"
		5:
			architecture_param = " arch=rv64"
		6:
			architecture_param = " arch=ppc64"
		7:
			architecture_param = " arch=wasm32"
		8:
			architecture_param = " arch=wasm64"
		9:
			architecture_param = " arch=loongarch64"
		_:
			architecture_param = ""
	_update_command()


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(command_line.text)


func _on_confirmed() -> void:
	DisplayServer.clipboard_set(command_line.text)
	match OS.get_name():
		"Windows":
			OS.create_process("powershell", ["-NoExit", "Set-Location -LiteralPath '%s'" % file_path], true)
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			OS.create_process("bash", ["-c", "cd \"%s\"; exec bash" % file_path], true)
		"MacOS":
			OS.create_process("zsh", ["-c", "cd \"%s\"; exec bash" % file_path], true)
