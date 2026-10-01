extends VBoxContainer

const VERSION_CONTAINER: PackedScene = preload("uid://byfxbqtgp68d")
const ENGINE_DOWNLOADER_CARD: PackedScene = preload("uid://dqqd7c1vpwb5y")

@onready var download_dialog: ConfirmationDialog = $DownloadDialog

@onready var stable_check: CheckBox = $OptionContainer/StableCheck
@onready var unstable_check: CheckBox = $OptionContainer/UnstableCheck
@onready var update_prompt_button: LinkButton = $OptionContainer/UpdatePromptButton

@onready var card_container: VBoxContainer = $HSplitContainer/PanelContainer/MarginContainer/ScrollContainer/CardContainer
@onready var downloader_container: VBoxContainer = $HSplitContainer/PanelContainer2/MarginContainer/ScrollContainer/DownloaderContainer

# 加载版本容器队列
var version_container_request: Array = []

func _ready() -> void:
	set_process(false)
	_load_version_container()
	# 清单加载后，重新加载版本容器
	DownloadManager.manifest_loaded.connect(_load_version_container)
	DownloadManager.manifest_updated.connect(_on_manifest_updated)

func _on_manifest_updated() -> void:
	if is_visible_in_tree():
		update_prompt_button.show()
	else:
		DownloadManager.load_manifest()

func _process(_delta: float) -> void:
	if version_container_request.size() <= 0:
		set_process(false)
		_switch_display(stable_check.button_pressed, unstable_check.button_pressed)
	else:
		# 每帧只创建一个版本容器，避免大量节点同时实例化
		_add_version_container(version_container_request.pop_back())

# 加载版本容器
# 1. 清空现有的版本容器
# 2. 获取最新的版本列表
# 3. 排序，旧版本在前，新版本在后，加载时通过pop_back让最新的版本先被加载
# 4. 设置处理标志为 true，开始逐帧加载版本容器
func _load_version_container() -> void:
	for container: Control in card_container.get_children():
		container.queue_free()
	version_container_request = DownloadManager.manifest.keys()
	# 只有major.patch，只对比前两部分版本号
	version_container_request.sort_custom(func(a: String, b: String) -> bool:
		var a_parts: PackedStringArray = a.split(".")
		var b_parts: PackedStringArray = b.split(".")
		return int(a_parts[0]) * 1000 + int(a_parts[1]) < int(b_parts[0]) * 1000 + int(b_parts[1])
	)
	set_process(true)

# 添加版本容器到界面
func _add_version_container(version: String) -> void:
	var container: Control = VERSION_CONTAINER.instantiate()
	container.title = version
	container.loaded.connect(_on_version_container_loaded.bind(container))
	container.download.connect(_on_version_container_download)
	card_container.add_child.call_deferred(container)

# 版本容器加载完成后，发起一次过滤事件
func _on_version_container_loaded(node: Control) -> void:
	if node == null:
		return
	node.switch_display.call_deferred(stable_check.button_pressed, unstable_check.button_pressed)

func _on_version_container_download(engine_id: String) -> void:
	download_dialog.display(engine_id)

func _switch_display(show_stable: bool, show_unstable: bool) -> void:
	var version_containers: Array[Node] = get_tree().get_nodes_in_group("download_version_container")
	for container: Control in version_containers:
		container.switch_display(show_stable, show_unstable)

func _on_download_dialog_download(url: String, engine_id: String) -> void:
	var downloader_card: Control = ENGINE_DOWNLOADER_CARD.instantiate()
	downloader_card.url = url
	downloader_card.engine_id = engine_id
	# 固定任务创建时的架构，后续设置变化不应改变下载目标
	downloader_card.architecture = Config.get_architecture()
	downloader_container.add_child(downloader_card)

func _on_stable_check_toggled(_toggled_on: bool) -> void:
	_switch_display(stable_check.button_pressed, unstable_check.button_pressed)

func _on_unstable_check_toggled(_toggled_on: bool) -> void:
	_switch_display(stable_check.button_pressed, unstable_check.button_pressed)
