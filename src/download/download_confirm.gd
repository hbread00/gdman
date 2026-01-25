extends ConfirmationDialog

const SOURCE_GODOT_INDEX: int = 1
const SOURCE_GITHUB_INDEX: int = 2

signal download(url: String, engine_id: String)

var last_engine_id: String = ""
var last_is_dotnet: bool = false
var source_godot_url: String = ""
var source_github_url: String = ""

@onready var source_option: OptionButton = $SourceContainer/SourceOption
@onready var unofficial_label: Label = $SourceContainer/UnofficialLabel
@onready var godot_ping_label: Label = $SourceContainer/ConnectContainer/GodotPingLabel
@onready var godot_ping_request: HTTPRequest = $SourceContainer/ConnectContainer/GodotPingLabel/GodotPingRequest
@onready var github_ping_label: Label = $SourceContainer/ConnectContainer/GithubPingLabel
@onready var github_ping_request: HTTPRequest = $SourceContainer/ConnectContainer/GithubPingLabel/GithubPingRequest

func display(engine_id: String, major_version: String, is_dotnet: bool) -> void:
	var is_new: bool = false
	if (last_engine_id != engine_id
		or last_is_dotnet != is_dotnet):
		is_new = true
		last_engine_id = engine_id
		last_is_dotnet = is_dotnet
	if is_new:
		title = "Download %s" % engine_id
		source_option.set_item_disabled(SOURCE_GODOT_INDEX, true)
		_set_ping_status(SOURCE_GODOT_INDEX, -1)
		var godot_data: Dictionary = DownloadSource.source_data.get("godot", {})
		if godot_data.has(major_version):
			for id: String in godot_data.get(major_version, []):
				if id == engine_id:
					source_option.set_item_disabled(SOURCE_GODOT_INDEX, false)
					source_godot_url = DownloadSource.get_source_godot_url(engine_id, is_dotnet, App.get_architecture())
					_ping_source(SOURCE_GODOT_INDEX)
					break
		source_option.set_item_disabled(SOURCE_GITHUB_INDEX, true)
		_set_ping_status(SOURCE_GITHUB_INDEX, -1)
		var github_data: Dictionary = DownloadSource.source_data.get("github", {})
		if github_data.has(major_version):
			for id: String in github_data.get(major_version, []):
				if id == engine_id:
					source_option.set_item_disabled(SOURCE_GITHUB_INDEX, false)
					source_github_url = DownloadSource.get_source_github_url(engine_id, is_dotnet, App.get_architecture())
					_ping_source(SOURCE_GITHUB_INDEX)
					break
	popup_centered()
	
func _ping_source(index: int) -> void:
	match index:
		SOURCE_GODOT_INDEX:
			_set_ping_status(SOURCE_GODOT_INDEX, 0)
			godot_ping_request.ping(source_godot_url)
		SOURCE_GITHUB_INDEX:
			_set_ping_status(SOURCE_GITHUB_INDEX, 0)
			github_ping_request.ping(source_github_url)


func _set_ping_status(index: int, delay_ms: int) -> void:
	var target_text: String = "X"
	var target_color: Color = Color.RED
	if delay_ms < 0:
		target_text = "X"
		target_color = Color.RED
	elif delay_ms == 0:
		target_text = "..."
		target_color = Color.WHITE
	elif delay_ms < 100:
		target_text = "%s" % delay_ms
		target_color = Color.GREEN
	elif delay_ms < 300:
		target_text = "%s" % delay_ms
		target_color = Color.YELLOW
	else:
		target_text = "%s" % delay_ms
		target_color = Color.ORANGE
	match index:
		SOURCE_GODOT_INDEX:
			godot_ping_label.text = target_text
			godot_ping_label.modulate = target_color
		SOURCE_GITHUB_INDEX:
			github_ping_label.text = target_text
			github_ping_label.modulate = target_color


func _on_godot_ping_request_ping_result(ping_time: int) -> void:
	_set_ping_status(SOURCE_GODOT_INDEX, ping_time)


func _on_github_ping_request_ping_result(ping_time: int) -> void:
	_set_ping_status(SOURCE_GITHUB_INDEX, ping_time)


func _on_confirmed() -> void:
	match source_option.selected:
		SOURCE_GODOT_INDEX:
			if source_godot_url != "":
				download.emit(source_godot_url, last_engine_id)
		SOURCE_GITHUB_INDEX:
			if source_github_url != "":
				download.emit(source_github_url, last_engine_id)
