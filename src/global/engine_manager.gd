extends Node

const ENGINE_DIR: String = "user://engine"

enum EngineFlavor {
	STABLE,
	RC,
	BETA,
	ALPHA,
	DEV,
}

const FLAVOR_NAME: Dictionary[EngineFlavor, String] = {
	EngineFlavor.RC: "RC",
	EngineFlavor.BETA: "Beta",
	EngineFlavor.ALPHA: "Alpha",
	EngineFlavor.DEV: "Dev",
}

signal engines_loaded()

class EngineInfo:
	var id: String # 格式：x.y[.z]-flavor[a][-dotnet]，flavor 表示发布阶段
	var name: String # 界面显示名称
	var major_version: int
	var minor_version: int
	var patch_version: int
	var flavor: EngineFlavor
	var build: int
	var is_dotnet: bool

class LocalEngine:
	var dir_path: String
	var executable_path: String
	var info: EngineInfo

var _cache_engine_info: Dictionary[String, EngineInfo] = {}

var local_engines: Dictionary[String, LocalEngine] = {}
var local_engine_ids: Array[String] = [] # 排序后的本地引擎 id 列表，方便相关组件取用

func _ready() -> void:
	Config.config_updated.connect(_config_update)
	load_engines()

# 获取引擎目录，基于本架构
func get_engine_dir(architecture: String) -> String:
	if App.ARCHITECTURE.has(architecture):
		return ENGINE_DIR.path_join(architecture)
	# 无效标识回退到本机架构，避免生成任意目录
	return ENGINE_DIR.path_join(App.get_architecture())

func load_engines() -> void:
	local_engines.clear()
	local_engine_ids.clear()
	var architecture: String = Config.get_architecture()
	var engine_dir: String = get_engine_dir(architecture)
	var engines_dir: DirAccess = DirAccess.open(engine_dir)
	if engines_dir == null:
		# 架构目录不存在也属于有效的空列表状态
		engines_loaded.emit.call_deferred()
		return
	# 遍历引擎目录下的子目录，尝试解析为引擎信息
	for dir_name: String in engines_dir.get_directories():
		var engine_info: EngineInfo = id_to_engine_info(dir_name)
		if engine_info == null:
			continue
		var local_engine: LocalEngine = LocalEngine.new()
		local_engine.info = engine_info
		var dir_path: String = engine_dir.path_join(dir_name)
		local_engine.dir_path = ProjectSettings.globalize_path(
			dir_path)
		local_engine.executable_path = ProjectSettings.globalize_path(
			_get_executable_path(dir_path, architecture)
		)
		local_engines[engine_info.id] = local_engine
	local_engine_ids = local_engines.keys()
	local_engine_ids.sort_custom(func(a: String, b: String) -> bool:
		return EngineManager.id_to_engine_sort_value(a) < EngineManager.id_to_engine_sort_value(b)
	)
	engines_loaded.emit.call_deferred()


# 不同版本执行文件路径不同
func _get_executable_path(dir_path: String, architecture: String) -> String:
	# 发布包目录层级不固定，递归查找符合目标架构后缀的文件
	var target_suffix: String = App.architecture_to_executable_suffix(architecture)
	if target_suffix == "":
		return ""
	var dirs_to_scan: Array[String] = [dir_path]
	# 递归扫描目录，查找符合目标架构后缀的可执行文件
	while dirs_to_scan.size() > 0:
		var current_path: String = dirs_to_scan.pop_back()
		var current_dir: DirAccess = DirAccess.open(current_path)
		if current_dir == null:
			continue
		current_dir.list_dir_begin()
		var file_name: String = current_dir.get_next()
		# 扫描当前目录下的文件和子目录
		while file_name != "":
			if file_name not in App.SCAN_EXCLUDED_FILE:
				# 为目录，加入待扫描目录列表
				# MacOS的.app也是目录，所以需要单独排除
				if current_dir.current_is_dir() and not (
					architecture == "macos" and file_name.ends_with(".app")
				):
					# 跳过符号链接
					if current_dir.is_link(file_name):
						continue
					dirs_to_scan.append(current_path.path_join(file_name))
				# 判断是不是要找的后缀
				if file_name.ends_with(target_suffix):
					var target_path: String = current_path.path_join(file_name)
					current_dir.list_dir_end()
					return target_path
			file_name = current_dir.get_next()
		current_dir.list_dir_end()
	return ""

func _config_update(config_name: String) -> void:
	if config_name == "architecture":
		load_engines()

func id_to_engine_info(engine_id: String) -> EngineInfo:
	if _cache_engine_info.has(engine_id):
		return _cache_engine_info[engine_id]
	var info: PackedStringArray = engine_id.split("-")
	if info.size() != 2 and info.size() != 3:
		return null
	var engine_info: EngineInfo = EngineInfo.new()
	engine_info.id = engine_id
	# 解析版本号
	var version_info: PackedStringArray = info[0].split(".")
	if version_info.size() >= 2:
		engine_info.major_version = version_info[0].to_int()
		engine_info.minor_version = version_info[1].to_int()
		if version_info.size() == 3:
			engine_info.patch_version = version_info[2].to_int()
	# 解析发布阶段
	if info[1] == "stable":
		engine_info.flavor = EngineFlavor.STABLE
	elif info[1].begins_with("rc"):
		engine_info.flavor = EngineFlavor.RC
	elif info[1].begins_with("beta"):
		engine_info.flavor = EngineFlavor.BETA
	elif info[1].begins_with("alpha"):
		engine_info.flavor = EngineFlavor.ALPHA
	elif info[1].begins_with("dev"):
		engine_info.flavor = EngineFlavor.DEV
	engine_info.build = info[1].to_int()
	engine_info.is_dotnet = info.size() == 3 and info[2] == "dotnet"
	# 生成界面显示名称
	var name_array: Array[String] = []
	name_array.append("%d.%d" % [engine_info.major_version, engine_info.minor_version])
	if engine_info.patch_version > 0:
		name_array.append(".%d" % engine_info.patch_version)
	if engine_info.flavor != EngineFlavor.STABLE:
		name_array.append(" %s" % FLAVOR_NAME[engine_info.flavor])
	if engine_info.build > 0:
		name_array.append(" %d" % engine_info.build)
	if engine_info.is_dotnet:
		name_array.append(" (.NET)")
	engine_info.name = "".join(name_array)
	_cache_engine_info[engine_id] = engine_info
	return engine_info

func id_to_engine_sort_value(engine_id: String) -> int:
	var info: EngineInfo = id_to_engine_info(engine_id)
	if info == null:
		return -1
	var dotnet_value: int = 0 if info.is_dotnet else 1
	return (
		dotnet_value +
		info.build * 10 +
		(9 - info.flavor) * 1000 +
		info.patch_version * 10000 +
		info.minor_version * 1000000 +
		info.major_version * 10000000
	)
