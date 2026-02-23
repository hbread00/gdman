extends VBoxContainer

signal version_refreshed()

var check_version_task_id: int = -1


var regex: Dictionary[String, RegEx] = {}
var version_regex: Dictionary[String, String] = {
	"python": r"(\d+\.\d+\.\d+)",
	"scons": r"v(\d+\.\d+\.\d+)",
	"dotnet": r"(\d+\.\d+\.\d+)",
	"mingw": r"version\s+(\d+\.\d+\.\d+)",
	"vulkan_sdk": "",
	"jdk": r"(\d+\.\d+\.\d+)",
	"android_sdk": "",
	"emscripten": r"\)\s+(\d+\.\d+\.\d+)\s+\(",
}

@onready var refresh_button: Button = $CompileContainer/RefreshButton
@onready var min_gw_file_dialog: FileDialog = $CompileContainer/MinGWContainer/MinGWPathButton/MinGWFileDialog
@onready var min_gw_path_line: LineEdit = $CompileContainer/MinGWContainer/MinGWPathLine
@onready var jdk_file_dialog: FileDialog = $CompileContainer/JDKContainer/JDKPathButton/JDKFileDialog
@onready var jdk_path_line: LineEdit = $CompileContainer/JDKContainer/JDKPathLine
@onready var android_sdk_file_dialog: FileDialog = $CompileContainer/AndroidSDKContainer/AndroidSDKPathButton/AndroidSDKFileDialog
@onready var android_sdk_path_line: LineEdit = $CompileContainer/AndroidSDKContainer/AndroidSDKPathLine

@onready var python_version_label: Label = $CompileContainer/PythonVersionLabel
@onready var scons_version_label: Label = $CompileContainer/SconsVersionLabel
@onready var dotnet_version_label: Label = $CompileContainer/DotnetVersionLabel
@onready var min_gw_version_label: Label = $CompileContainer/MinGWVersionLabel
@onready var vulkan_sdk_version_label: Label = $CompileContainer/VulkanSDKVersionLabel
@onready var jdk_version_label: Label = $CompileContainer/JDKVersionLabel
@onready var android_sdk_version_label: Label = $CompileContainer/AndroidSDKVersionLabel
@onready var emscripten_version_label: Label = $CompileContainer/EmscriptenVersionLabel

@onready var scons_option: OptionButton = $CompileContainer/SconsOption

func _ready() -> void:
	for key: String in version_regex.keys():
		regex[key] = RegEx.new()
		if regex[key].compile(version_regex[key]) != OK:
			regex.erase(key)
	_refresh_version()

func _refresh_version() -> void:
	refresh_button.disabled = true
	python_version_label.text = "?"
	scons_version_label.text = "?"
	dotnet_version_label.text = "?"
	min_gw_version_label.text = "?"
	vulkan_sdk_version_label.text = "?"
	jdk_version_label.text = "?"
	android_sdk_version_label.text = "?"
	emscripten_version_label.text = "?"
	check_version_task_id = WorkerThreadPool.add_task(_check_version_task)
	
func _check_version_task() -> void:
	# Python：python3 --version
	python_version_label.set_deferred("text", _extract_version("python", ["--version"], "python"))
	# Scons：scons --version
	match scons_option.get_selected_id():
		1:
			scons_version_label.set_deferred("text",
				_extract_version("uvx", ["scons", "--version"], "scons"))
		_:
			scons_version_label.set_deferred("text",
				_extract_version("scons", ["--version"], "scons"))
	# Dotnet：dotnet --version
	dotnet_version_label.set_deferred("text",
		_extract_version("dotnet", ["--version"], "dotnet"))
	# MinGW：g++ --version
	min_gw_version_label.set_deferred("text",
		_extract_version("g++", ["--version"], "mingw"))
	# Vulkan SDK：pass
	# JDK：javac -version
	jdk_version_label.set_deferred("text",
		_extract_version("javac", ["-version"], "jdk"))
	# Android SDK：pass
	# Emscripten：emcc --version
	emscripten_version_label.set_deferred("text",
		_extract_version("emcc", ["--version"], "emscripten"))
	version_refreshed.emit.call_deferred()

func _extract_version(path: String, args: PackedStringArray, regex_key: String) -> String:
	if not regex.has(regex_key):
		return "?"
	var output: Array[String] = []
	if (OS.execute(path, args, output) != OK
		or output.size() == 0):
		return "?"
	var result: RegExMatch = regex[regex_key].search(output[0])
	if result == null:
		return "?"
	return result.get_string(1)


func _on_refresh_button_pressed() -> void:
	_refresh_version()

func _on_version_refreshed() -> void:
	WorkerThreadPool.wait_for_task_completion(check_version_task_id)
	refresh_button.set_deferred("disabled", false)

func _on_min_gw_path_button_pressed() -> void:
	min_gw_file_dialog.popup_centered()

func _on_jdk_path_button_pressed() -> void:
	jdk_file_dialog.popup_centered()

func _on_android_sdk_path_button_pressed() -> void:
	android_sdk_file_dialog.popup_centered()


func _on_min_gw_file_dialog_dir_selected(dir: String) -> void:
	min_gw_path_line.text = dir

func _on_jdk_file_dialog_dir_selected(dir: String) -> void:
	jdk_path_line.text = dir

func _on_android_sdk_file_dialog_dir_selected(dir: String) -> void:
	android_sdk_path_line.text = dir
