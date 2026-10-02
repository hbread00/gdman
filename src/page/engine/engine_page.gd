extends VBoxContainer

const ENGINE_CARD: PackedScene = preload("uid://bu4qc2q2pjb0t")

@onready var card_container: VBoxContainer = $PanelContainer/ScrollContainer/MarginContainer/CardContainer

var engine_id_request: Array[String] = []

func _ready() -> void:
	_load_engine()
	EngineManager.engines_loaded.connect(_load_engine)

func _process(_delta: float) -> void:
	if engine_id_request.is_empty():
		set_process(false)
	else:
		# 每帧只创建一张卡片，避免大量节点同时实例化
		_add_engine_card(engine_id_request.pop_back())

func _load_engine() -> void:
	for card: Control in card_container.get_children():
		card.queue_free()
	engine_id_request = EngineManager.local_engine_ids.duplicate()
	set_process(true)

func _add_engine_card(engine_id: String) -> void:
	var local_engine: EngineManager.LocalEngine = EngineManager.local_engines.get(engine_id, null)
	if local_engine == null:
		return
	var card: Control = ENGINE_CARD.instantiate()
	card.engine_id = local_engine.info.id
	card.dir_path = local_engine.dir_path
	card.executable_path = local_engine.executable_path
	card_container.add_child.call_deferred(card)
