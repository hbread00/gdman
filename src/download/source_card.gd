extends PanelContainer

const DOTNET: CompressedTexture2D = preload("uid://b5cuh2fee8rn5")

signal download(engine_id: String)

var engine_id: String = ""
var is_stable: bool = false
var is_dotnet: bool = false

@onready var source_icon: TextureRect = $HBoxContainer/SourceIcon
@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var unstable_icon: TextureRect = $HBoxContainer/UnstableIcon

func _ready() -> void:
	unstable_icon.hide()
	if engine_id == "":
		return
	var info: WorkEngine.EngineInfo = WorkEngine.id_to_engine_info(engine_id, false)
	name_label.text = info.name
	is_stable = info.is_stable
	is_dotnet = info.is_dotnet
	if not is_stable:
		unstable_icon.show()
	if is_dotnet:
		source_icon.texture = DOTNET

func _on_download_button_pressed() -> void:
	download.emit(engine_id)
