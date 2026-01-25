extends PanelContainer

signal download(engine_id: String)

var engine_id: String = ""
var is_stable: bool = false

@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var unstable_icon: TextureRect = $HBoxContainer/UnstableIcon

func _ready() -> void:
	if engine_id == "":
		return
	name_label.text = WorkEngine.id_to_display_name(engine_id)

func _on_download_button_pressed() -> void:
	download.emit(engine_id)
