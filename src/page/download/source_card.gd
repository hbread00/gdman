extends PanelContainer

signal download(engine_id: String)

var engine_id: String = ""
var is_stable: bool = false

@onready var name_label: Label = $MarginContainer/HBoxContainer/NameLabel
@onready var id_label: Label = $MarginContainer/HBoxContainer/IDLabel
@onready var unstable_icon: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/UnstableIcon
@onready var download_button: Button = $MarginContainer/HBoxContainer/DownloadButton

func _ready() -> void:
	unstable_icon.hide()
	if engine_id == "":
		queue_free()
		return
	var info: EngineManager.EngineInfo = EngineManager.id_to_engine_info(engine_id)
	name_label.text = info.name
	id_label.text = engine_id
	is_stable = info.flavor == EngineManager.EngineFlavor.STABLE
	if not is_stable:
		unstable_icon.show()
	download_button.tooltip_text = tr("SOURCE_CARD_DOWNLOAD_HINT") % engine_id
	Config.config_updated.connect(_config_update)
	_handle_component()

func switch_display(show_stable: bool, show_unstable: bool) -> void:
	visible = ((show_stable and is_stable)
		or (show_unstable and not is_stable))

func _config_update(config_name: String) -> void:
	match config_name:
		"language":
			_handle_component()
			download_button.tooltip_text = tr("SOURCE_CARD_DOWNLOAD_HINT") % engine_id

func _handle_component() -> void:
	App.fix_button_width(download_button)

func _on_download_button_pressed() -> void:
	download.emit(engine_id)
