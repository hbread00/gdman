extends PanelContainer

const PROJECT_TAG: PackedScene = preload("uid://46nlwtxtu0rn")


signal uid_path_resolved(path: String)

var project_path: String = ""
var prefer_engine_id: String = ""

@onready var project_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/ProjectIcon
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var version_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/VersionLabel
@onready var dotnet_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/DotnetIcon
@onready var time_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TimeLabel
@onready var tag_container: GridContainer = $MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/TagContainer
@onready var path_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/PathButton
@onready var path_line: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer2/PathLine
@onready var editor_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/EditorButton
@onready var engine_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer2/EngineOption
@onready var engine_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/EngineButton

func _ready() -> void:
	# 获取项目配置，根据配置加载图标、版本、标签等信息
	var config: ConfigFile = ConfigFile.new()
	if config.load(project_path.path_join("project.godot")) != OK:
		queue_free()
		return
	name_label.text = config.get_value("application", "config/name", "")
	name_label.tooltip_text = name_label.text
	_load_project_icon(config.get_value("application", "config/icon", ""))
	version_label.text = config.get_value("application", "config/features", ["unknown"])[0]
	dotnet_icon.visible = config.has_section("dotnet")
	refresh_project_time()
	App.small_update.connect(refresh_project_time)
	uid_path_resolved.connect(_set_project_icon)
	path_line.text = project_path
	path_line.tooltip_text = project_path
	for tag: String in config.get_value("application", "config/tags", []):
		var tag_node: Control = PROJECT_TAG.instantiate()
		tag_node.text = tag
		tag_container.add_child(tag_node)
	editor_button.disabled = Config.external_editor_path == ""
	refresh_engine()
	EngineManager.engines_loaded.connect(refresh_engine)
	Config.config_updated.connect(_config_update)
	_handle_component()

func refresh_project_time() -> void:
	var time_dict: Dictionary = Time.get_datetime_dict_from_unix_time((
		App.unix_time_to_current(
		FileAccess.get_modified_time(project_path))))
	time_label.text = "%d/%d/%d-%d:%d:%d" % [
		time_dict.get("year", 1970),
		time_dict.get("month", 1),
		time_dict.get("day", 1),
		time_dict.get("hour", 0),
		time_dict.get("minute", 0),
		time_dict.get("second", 0),
	]

func _config_update(config_name: String) -> void:
	match config_name:
		"external_editor_path":
			editor_button.disabled = Config.external_editor_path == ""
		"language":
			_handle_component()

func _handle_component() -> void:
	App.fix_button_width(path_button)
	App.fix_button_width(editor_button)
	App.fix_button_width(engine_button)

func refresh_engine() -> void:
	engine_option.load_engine()
	engine_option.select_id(prefer_engine_id)
	engine_button.disabled = engine_option.get_selected_id() == -1

# 资源路径可直接读取，资源 UID 需要扫描项目目录解析
func _load_project_icon(path: String) -> void:
	if path.begins_with("res://"):
		_set_project_icon(path)
	elif path.begins_with("uid://"):
		WorkerThreadPool.add_task(_scan_uid_path.bind(path))

# 设置项目图标，根据资源路径加载图片
func _set_project_icon(path: String) -> void:
	if not path.begins_with("res://"):
		return
	var icon_path: String = project_path.path_join(path.trim_prefix("res://"))
	var image: Image = Image.new()
	if image.load(icon_path) == OK:
		project_icon.texture = ImageTexture.create_from_image(image)

# 扫描 UID 路径，找到对应的资源路径
func _scan_uid_path(target: String) -> void:
	var resource_path: String = ""
	var dirs_to_scan: Array[String] = [project_path]
	while dirs_to_scan.size() > 0 and resource_path == "":
		var current_path: String = dirs_to_scan.pop_back()
		# 目录被标记为不参与导入
		if FileAccess.file_exists(current_path.path_join(".gdignore")):
			continue
		var current_dir: DirAccess = DirAccess.open(current_path)
		if current_dir == null:
			continue
		current_dir.list_dir_begin()
		var file_name: String = current_dir.get_next()
		while file_name != "":
			if file_name not in App.SCAN_EXCLUDED_FILE:
				if current_dir.current_is_dir():
					# 跳过符号链接
					if current_dir.is_link(file_name):
						continue
					dirs_to_scan.append(current_path.path_join(file_name))
				elif file_name.ends_with(".import"):
					var import_config: ConfigFile = ConfigFile.new()
					if (import_config.load(current_path.path_join(file_name)) == OK
						and import_config.get_value("remap", "uid", "") == target):
						resource_path = import_config.get_value("deps", "source_file", "")
						break
			file_name = current_dir.get_next()
		current_dir.list_dir_end()
	# 工作线程不能操作界面，延迟回主线程应用结果
	uid_path_resolved.emit.call_deferred(resource_path)

func _on_path_button_pressed() -> void:
	OS.shell_show_in_file_manager(project_path)


func _on_engine_button_pressed() -> void:
	var selected_index: int = engine_option.selected
	if selected_index < 0 or engine_option.is_item_disabled(selected_index):
		return
	var engine: EngineManager.LocalEngine = EngineManager.local_engines.get(
		engine_option.get_item_text(selected_index), null)
	if engine == null:
		return
	# 在 Unix 平台上，可执行文件需要具有可执行权限
	if App.is_unix_platform():
		OS.execute("chmod", ["-R", "+x", engine.executable_path])
	OS.open_with_program(engine.executable_path, [project_path.path_join("project.godot")])
	ProjectManager.project_info[project_path].prefer_engine_id = engine.info.id
	ProjectManager.store_config()


func _on_remove_button_pressed() -> void:
	ProjectManager.project_info.erase(project_path)
	ProjectManager.store_config()
	queue_free()


func _on_editor_button_pressed() -> void:
	if Config.external_editor_path == "":
		return
	OS.open_with_program(Config.external_editor_path, [project_path])


func _on_engine_option_item_selected(index: int) -> void:
	if index < 0 or engine_option.is_item_disabled(index):
		engine_button.disabled = true
		return
	var engine: EngineManager.LocalEngine = EngineManager.local_engines.get(
		engine_option.get_item_text(index), null)
	engine_button.disabled = engine == null
