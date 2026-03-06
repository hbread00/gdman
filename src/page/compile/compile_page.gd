extends VBoxContainer

const SOURCE_CODE_CARD: PackedScene = preload("uid://dnwx7tc3bvgu1")

@onready var card_container: GridContainer = $PanelContainer/ScrollContainer/MarginContainer/CardContainer
@onready var compile_dialog: ConfirmationDialog = $CompileDialog

func _ready() -> void:
	_load_source_code()

func _load_source_code() -> void:
	for card: Control in card_container.get_children():
		card.queue_free()
	var source_code_dir: DirAccess = DirAccess.open(CompileManager.SOURCE_CODE_DIR)
	if source_code_dir == null:
		return
	for dir_name: String in source_code_dir.get_directories():
		var card: Control = SOURCE_CODE_CARD.instantiate()
		card.file_name = dir_name
		card.compile.connect(compile_dialog.display)
		card_container.add_child(card)
