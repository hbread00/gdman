extends VBoxContainer

const ENGINE_CARD: PackedScene = preload("uid://bu4qc2q2pjb0t")

@onready var refresh_button: Button = $OptionContainer/RefreshButton
@onready var card_container: GridContainer = $PanelContainer/MarginContainer/ScrollContainer/CardContainer

func _ready() -> void:
	_load_engine()

func _load_engine() -> void:
	refresh_button.disabled = true
	for engine_info: WorkEngine.EngineInfo in WorkEngine.engines:
		var card: Node = ENGINE_CARD.instantiate()
		card.engine_id = engine_info.id
		card.display_name = engine_info.name
		card.version = engine_info.version
		card.dir_path = engine_info.work_info.dir_path
		card.executable_path = engine_info.work_info.executable_path
		card.is_dotnet = engine_info.is_dotnet
		card_container.add_child(card)

func _on_refresh_button_pressed() -> void:
	_load_engine()
