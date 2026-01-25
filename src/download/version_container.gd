extends FoldableContainer

signal download(engine_id: String)

const SOURCE_CARD = preload("res://src/download/source_card.tscn")

@onready var card_container: VBoxContainer = $HBoxContainer/CardContainer

func _ready() -> void:
	var version_data: Dictionary = DownloadSource.source_data.get("godot", {})
	if not version_data.has(title):
		return
	var version_list: Array = version_data.get(title, [])
	for engine_id: String in version_list:
		var card: Node = SOURCE_CARD.instantiate()
		card.engine_id = engine_id
		card.download.connect(_on_download_card_download)
		card_container.add_child(card)
		var card_dotnet: Node = SOURCE_CARD.instantiate()
		card_dotnet.engine_id = "%s-dotnet" % engine_id
		card_dotnet.download.connect(_on_download_card_download)
		card_container.add_child(card_dotnet)

func switch_display(stable: bool, dotnet: bool) -> void:
	for card: Control in card_container.get_children():
		if card.is_dotnet and not dotnet:
			card.hide()
		elif not card.is_stable and stable:
			card.hide()
		else:
			card.show()
func _on_download_card_download(engine_id: String) -> void:
	download.emit(engine_id)
