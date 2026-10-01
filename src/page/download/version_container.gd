extends FoldableContainer

signal download(engine_id: String)
signal loaded()

const SOURCE_CARD: PackedScene = preload("uid://cvhkrjsovo0lf")

@onready var card_container: VBoxContainer = $HBoxContainer/CardContainer

var source_card_request: Array = []

func _ready() -> void:
	set_process(false)
	_load_source_card()

func _process(_delta: float) -> void:
	if source_card_request.size() <= 0:
		set_process(false)
		loaded.emit.call_deferred()
	else:
		# 每帧只创建一张来源卡片，避免展开大版本列表时卡顿
		_add_source_card(source_card_request.pop_back())

func _load_source_card() -> void:
	for card: Control in card_container.get_children():
		card.queue_free()
	source_card_request = DownloadManager.manifest.get(title, {}).keys()
	source_card_request.sort_custom(func(a: String, b: String) -> bool:
		return EngineManager.id_to_engine_sort_value(a) < EngineManager.id_to_engine_sort_value(b)
	)
	set_process(true)

func _add_source_card(engine_id: String) -> void:
	var card: Control = SOURCE_CARD.instantiate()
	card.engine_id = engine_id
	card.download.connect(_on_download_card_download)
	card_container.add_child.call_deferred(card)

# 向下传递显示状态
func switch_display(show_stable: bool, show_unstable: bool) -> void:
	for card: Control in card_container.get_children():
		card.switch_display(show_stable, show_unstable)

# 向上传递下载信号
func _on_download_card_download(engine_id: String) -> void:
	download.emit(engine_id)
