extends PanelContainer

const PROJECT_TAG: PackedScene = preload("res://src/project/project_tag.tscn")

var is_favorite: bool = false
var project_icon_path: String = ""
var project_name: String = ""
var project_path: String = ""
var project_version: String = ""
var project_tags: Array[String] = []
var last_edited_time: int = 0
var prefer_engine_id: String = ""

@onready var project_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/ProjectIcon
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var version_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VersionLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/TimeLabel
@onready var path_label: Label = $MarginContainer/VBoxContainer/HBoxContainer2/PanelContainer/MarginContainer/PathLabel
@onready var tag_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer3/ScrollContainer/TagContainer
@onready var engine_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/EngineOption

func _ready() -> void:
	if project_icon_path != "":
		var img: Image = Image.new()
		if img.load(project_icon_path) == OK:
			project_icon.texture = ImageTexture.create_from_image(img)
	name_label.text = project_name
	for tag_text: String in project_tags:
		var tag: Control = PROJECT_TAG.instantiate()
		tag.text = tag_text
		tag_container.add_child(tag)
	path_label.text = project_path
	version_label.text = project_version
	var time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(last_edited_time)
	time_label.text = "%d/%d/%d-%0d:%0d:%0d" % [
		time_dict.get("year", 1970),
		time_dict.get("month", 1),
		time_dict.get("day", 1),
		time_dict.get("hour", 0),
		time_dict.get("minute", 0),
		time_dict.get("second", 0),
	]
	engine_option.select_id(prefer_engine_id)

func _on_path_button_pressed() -> void:
	OS.shell_open(project_path)


func _on_engine_button_pressed() -> void:
	pass # Replace with function body.
