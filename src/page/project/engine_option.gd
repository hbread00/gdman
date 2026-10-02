extends OptionButton

func _ready() -> void:
	load_engine()

# 选择对应引擎 id
func select_id(engine_id: String) -> void:
	for i: int in get_item_count():
		if is_item_separator(i) or is_item_disabled(i):
			continue
		if get_item_text(i) == engine_id:
			select(i)
			return
	select(-1)

func load_engine() -> void:
	select(-1)
	clear()
	var engine_ids: Array = EngineManager.local_engine_ids.duplicate()
	engine_ids.reverse()
	for engine_id: String in engine_ids:
		add_item(engine_id)
