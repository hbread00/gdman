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
	"emscripten": r"\)\s+(\d+\.\d+\.\d+)\s+\(",
	"cmake": r"cmake version (\d+\.\d+\.\d+)",
}

@onready var refresh_button: Button = $RefreshButton
@onready var mingw_path_line: LineEdit = $GridContainer/MingwContainer/MingwPathLine
@onready var mingw_file_dialog: FileDialog = $GridContainer/MingwContainer/MingwPathButton/MingwFileDialog
@onready var jdk_path_line: LineEdit = $GridContainer/JDKContainer/JDKPathLine
@onready var jdk_file_dialog: FileDialog = $GridContainer/JDKContainer/JDKPathButton/JDKFileDialog
@onready var android_sdk_path_line: LineEdit = $GridContainer/AndroidSDKContainer/AndroidSDKPathLine
@onready var android_sdk_file_dialog: FileDialog = $GridContainer/AndroidSDKContainer/AndroidSDKPathButton/AndroidSDKFileDialog

@onready var python_version_label: Label = $GridContainer/PythonVersionLabel
@onready var scons_version_label: Label = $GridContainer/SconsVersionLabel
@onready var dotnet_version_label: Label = $GridContainer/DotnetVersionLabel
@onready var mingw_version_label: Label = $GridContainer/MingwVersionLabel
@onready var vulkan_sdk_version_label: Label = $GridContainer/VulkanSDKVersionLabel
@onready var emscripten_version_label: Label = $GridContainer/EmscriptenVersionLabel
@onready var jdk_version_label: Label = $GridContainer/JDKVersionLabel

@onready var android_platform_tools_version_label: Label = $GridContainer/AndroidPlatformToolsVersionLabel
@onready var android_build_tools_version_label: Label = $GridContainer/AndroidBuildToolsVersionLabel
@onready var android_platform_version_label: Label = $GridContainer/AndroidPlatformVersionLabel
@onready var android_command_line_tools_version_label: Label = $GridContainer/AndroidCommandLineToolsVersionLabel
@onready var android_cmake_version_label: Label = $GridContainer/AndroidCmakeVersionLabel
@onready var android_ndk_version_label: Label = $GridContainer/AndroidNDKVersionLabel

func _ready() -> void:
	for key: String in version_regex.keys():
		regex[key] = RegEx.new()
		if regex[key].compile(version_regex[key]) != OK:
			regex.erase(key)
	refresh_button.disabled = true
	check_version_task_id = WorkerThreadPool.add_task(_check_version_task)
	
func _check_version_task() -> void:
	python_version_label.set_deferred("text",
		CompileManager.get_python_version())
	scons_version_label.set_deferred("text",
		CompileManager.get_scons_version())
	dotnet_version_label.set_deferred("text",
		CompileManager.get_dotnet_version())
	mingw_version_label.set_deferred("text",
		CompileManager.get_mingw_version(mingw_path_line.text))
	vulkan_sdk_version_label.set_deferred("text",
		CompileManager.get_vulkan_sdk_version())
	emscripten_version_label.set_deferred("text",
		CompileManager.get_emscripten_version())
	jdk_version_label.set_deferred("text",
		CompileManager.get_jdk_version(jdk_path_line.text))
	android_platform_tools_version_label.set_deferred("text",
		CompileManager.get_android_sdk_platform_tools_version(android_sdk_path_line.text))
	android_build_tools_version_label.set_deferred("text",
		CompileManager.get_android_sdk_build_tools_version(android_sdk_path_line.text))
	android_platform_version_label.set_deferred("text",
		CompileManager.get_android_sdk_platform_version(android_sdk_path_line.text))
	android_command_line_tools_version_label.set_deferred("text",
		CompileManager.get_android_sdk_command_line_tools_version(android_sdk_path_line.text))
	android_cmake_version_label.set_deferred("text",
		CompileManager.get_android_cmake_version(android_sdk_path_line.text))
	android_ndk_version_label.set_deferred("text",
		CompileManager.get_android_ndk_version(android_sdk_path_line.text))
	version_refreshed.emit.call_deferred()

func _on_refresh_button_pressed() -> void:
	refresh_button.disabled = true
	check_version_task_id = WorkerThreadPool.add_task(_check_version_task)

func _on_version_refreshed() -> void:
	WorkerThreadPool.wait_for_task_completion(check_version_task_id)
	refresh_button.set_deferred("disabled", false)

func _on_mingw_path_button_pressed() -> void:
	mingw_file_dialog.popup_centered()

func _on_jdk_path_button_pressed() -> void:
	jdk_file_dialog.popup_centered()

func _on_android_sdk_path_button_pressed() -> void:
	android_sdk_file_dialog.popup_centered()

func _on_mingw_file_dialog_dir_selected(dir: String) -> void:
	mingw_path_line.text = dir

func _on_jdk_file_dialog_dir_selected(dir: String) -> void:
	jdk_path_line.text = dir

func _on_android_sdk_file_dialog_dir_selected(dir: String) -> void:
	android_sdk_path_line.text = dir

func _on_min_gw_path_line_text_changed(new_text: String) -> void:
	Config.mingw_prefix = new_text

func _on_jdk_path_line_text_changed(new_text: String) -> void:
	Config.java_home = new_text

func _on_android_sdk_path_line_text_changed(new_text: String) -> void:
	Config.android_home = new_text
