extends PanelContainer

const DOTNET: CompressedTexture2D = preload("uid://b5cuh2fee8rn5")

var engine_id: String = ""
var display_name: String = ""
var version: String = ""
var is_dotnet: bool = false
var dir_path: String = ""
var executable_path: String = ""

@onready var engine_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/EngineIcon
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/NameLabel
@onready var version_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VersionLabel
@onready var id_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/IDLabel
@onready var unstable_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/UnstableIcon
@onready var path_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/PathLabel

func _ready() -> void:
	unstable_icon.hide()
	if is_dotnet:
		engine_icon.texture = DOTNET
	name_label.text = display_name
	version_label.text = version
	id_label.text = engine_id
	path_label.text = dir_path


func _on_file_button_pressed() -> void:
	OS.shell_open(dir_path)


func _on_delete_button_pressed() -> void:
	OS.move_to_trash(dir_path)
	queue_free()


func _on_run_button_pressed() -> void:
	OS.shell_open(executable_path)
