extends ConfirmationDialog

const SOURCE_GODOT_INDEX: int = 1
const SOURCE_GITHUB_INDEX: int = 2

signal download(url: String, engine_id: String)

var last_engine_id: String = ""
var source_godot_url: String = ""
var source_github_url: String = ""

@onready var source_option: OptionButton = $SourceContainer/SourceOption
@onready var godot_ping_display: HBoxContainer = $SourceContainer/GodotPingDisplay
@onready var github_ping_display: HBoxContainer = $SourceContainer/GithubPingDisplay

func display(engine_id: String) -> void:
	if last_engine_id != engine_id:
		last_engine_id = engine_id
		title = "Download %s" % engine_id
		_handle_source_godot(engine_id)
		_handle_source_github(engine_id)
	popup_centered()

func _handle_source_godot(engine_id: String) -> void:
	source_option.set_item_disabled(SOURCE_GODOT_INDEX, true)
	if DownloadSource.has_source(engine_id, "godot"):
		source_option.set_item_disabled(SOURCE_GODOT_INDEX, false)
		source_godot_url = DownloadSource.get_source_godot_url(engine_id, App.get_architecture())
		godot_ping_display.ping(source_godot_url)
	source_option.set_item_disabled(SOURCE_GITHUB_INDEX, true)

func _handle_source_github(engine_id: String) -> void:
	source_option.set_item_disabled(SOURCE_GITHUB_INDEX, true)
	if DownloadSource.has_source(engine_id, "github"):
		source_option.set_item_disabled(SOURCE_GITHUB_INDEX, false)
		source_github_url = DownloadSource.get_source_github_url(engine_id, App.get_architecture())
		github_ping_display.ping(source_github_url)


func _on_confirmed() -> void:
	match source_option.selected:
		SOURCE_GODOT_INDEX:
			if source_godot_url != "":
				download.emit(source_godot_url, last_engine_id)
		SOURCE_GITHUB_INDEX:
			if source_github_url != "":
				download.emit(source_github_url, last_engine_id)
