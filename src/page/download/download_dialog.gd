extends ConfirmationDialog

const GODOT_SOURCE_INDEX: int = 0
const GITHUB_SOURCE_INDEX: int = 1

signal download(url: String, engine_id: String)

var last_engine_id: String = ""

@onready var dotnet_check: CheckBox = $VBoxContainer/HBoxContainer/DotnetCheck
@onready var source_option: OptionButton = $VBoxContainer/HBoxContainer/SourceOption
@onready var url_line: LineEdit = $VBoxContainer/UrlLine

func display(engine_id: String) -> void:
	if last_engine_id == engine_id:
		# 相同版本复用上次测速和来源选择结果
		popup_centered()
		return
	last_engine_id = engine_id
	title = tr("DOWNLOAD_DIALOG_TITLE") % engine_id
	dotnet_check.button_pressed = false
	get_ok_button().disabled = true
	url_line.text = ""
	url_line.tooltip_text = ""
	popup_centered()

func _on_dotnet_check_toggled(_toggled_on: bool) -> void:
	var engine_id: String = last_engine_id
	if dotnet_check.button_pressed:
		engine_id += "-dotnet"
	source_option.set_item_disabled(GODOT_SOURCE_INDEX, DownloadManager.get_download_url(engine_id, "godot") == "")
	source_option.set_item_disabled(GITHUB_SOURCE_INDEX, DownloadManager.get_download_url(engine_id, "github") == "")
	source_option.select(-1)
	url_line.text = ""
	url_line.tooltip_text = url_line.text
	get_ok_button().disabled = not App.is_valid_url(url_line.text)


func _on_source_option_item_selected(index: int) -> void:
	var engine_id: String = last_engine_id
	if dotnet_check.button_pressed:
		engine_id += "-dotnet"
	match index:
		GODOT_SOURCE_INDEX:
			url_line.text = DownloadManager.get_download_url(engine_id, "godot")
		GITHUB_SOURCE_INDEX:
			url_line.text = DownloadManager.get_download_url(engine_id, "github")
		_:
			url_line.text = ""
	url_line.tooltip_text = url_line.text
	get_ok_button().disabled = not App.is_valid_url(url_line.text)

func _on_confirmed() -> void:
	var id: String = last_engine_id
	if dotnet_check.button_pressed:
		id += "-dotnet"
	download.emit(url_line.text, id)
