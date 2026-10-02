extends PanelContainer

const DOTNET: CompressedTexture2D = preload("uid://dfgbgdrbcpnri")

var engine_id: String = ""
var dir_path: String = ""
var executable_path: String = ""
var is_dotnet: bool = false

@onready var engine_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/EngineIcon
@onready var name_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var version_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VersionLabel
@onready var id_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/IDLabel
@onready var unstable_icon: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/UnstableIcon
@onready var run_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/RunButton

func _ready() -> void:
	var engine_info: EngineManager.EngineInfo = EngineManager.id_to_engine_info(engine_id)
	if engine_info == null:
		queue_free()
		return
	id_label.text = engine_id
	name_label.text = engine_info.name
	version_label.text = "%d.%d" % [engine_info.major_version, engine_info.minor_version]
	if engine_info.is_dotnet:
		engine_icon.texture = DOTNET
	var is_stable: bool = engine_info.flavor == EngineManager.EngineFlavor.STABLE
	is_dotnet = engine_info.is_dotnet
	unstable_icon.visible = not is_stable
	run_button.disabled = executable_path == ""
	Config.config_updated.connect(_config_updated)
	App.fix_button_width(run_button)

func _config_updated(config_name: String) -> void:
	match config_name:
		"language":
			App.fix_button_width(run_button)

func _on_delete_button_pressed() -> void:
	App.remove_file(dir_path)
	# 很多页面都需要重新加载，所以不能只在这里移除
	EngineManager.load_engines()

func _on_run_button_pressed() -> void:
	# 在 Unix 平台上，可执行文件需要具有可执行权限
	if App.is_unix_platform():
		OS.execute("chmod", ["-R", "+x", executable_path])
	OS.create_process(executable_path, [])


func _on_path_button_pressed() -> void:
	OS.shell_show_in_file_manager(dir_path)
