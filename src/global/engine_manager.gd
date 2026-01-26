extends Node

class EngineInfo:
	var id: String # X.Y.Z-flavor[-dotnet]
	var name: String # name for display
	var version: String # X.Y[.Z]
	var project_version: String # X.Y
	var flavor: String
	var is_stable: bool
	var is_dotnet: bool
	var sort_number: int = 0

class LocalEngine:
	var dir_path: String
	var executable_path: String
	var info: EngineInfo

var local_engines: Array[LocalEngine] = []

func _ready() -> void:
	load_engines()

func load_engines() -> void:
	local_engines.clear()
	var engines_dir: DirAccess = DirAccess.open(App.ENGINE_DIR)
	if engines_dir == null:
		return
	for dir_name: String in engines_dir.get_directories():
		var engine_info: EngineInfo = id_to_engine_info(dir_name)
		if engine_info == null:
			continue
		var local_engine: LocalEngine = LocalEngine.new()
		local_engine.info = engine_info
		local_engine.dir_path = ProjectSettings.globalize_path(App.ENGINE_DIR.path_join(dir_name))
		local_engine.executable_path = ProjectSettings.globalize_path(_get_executable_path(dir_name))
		local_engines.append(local_engine)
	local_engines.sort_custom(_compare_local_engine)

func id_to_engine_info(engine_id: String) -> EngineInfo:
	var info: PackedStringArray = engine_id.split("-")
	if info.size() != 2 and info.size() != 3:
		return null
	var engine_info: EngineInfo = EngineInfo.new()
	engine_info.id = engine_id
	engine_info.name = id_to_display_name(engine_id)
	engine_info.version = info[0]
	var version_info: PackedStringArray = engine_info.version.split(".")
	if version_info.size() >= 2:
		engine_info.project_version = "%s.%s" % [version_info[0], version_info[1]]
	else:
		engine_info.project_version = engine_info.version
	engine_info.flavor = info[1]
	engine_info.sort_number = _get_sort_number(engine_info.version, engine_info.flavor)
	engine_info.is_stable = engine_info.flavor == "stable"
	engine_info.is_dotnet = info.size() == 3 and info[2] == "dotnet"
	return engine_info

# Format: 1Major|1Minor|1Patch|1Flavor|2Build
func _get_sort_number(version: String, flavor: String) -> int:
	var major: int = 0
	var minor: int = 0
	var patch: int = 0
	var version_info: PackedStringArray = version.split(".")
	if version_info.size() == 2:
		major = version_info[0].to_int()
		minor = version_info[1].to_int()
	elif version_info.size() == 3:
		major = version_info[0].to_int()
		minor = version_info[1].to_int()
		patch = version_info[2].to_int()
	var flavor_number: int = 0 # stable=9, rc=8, beta=7, alpha=6, dev=5
	if flavor == "stable":
		flavor_number = 9
	elif flavor.begins_with("rc"):
		flavor_number = 8
	elif flavor.begins_with("beta"):
		flavor_number = 7
	elif flavor.begins_with("alpha"):
		flavor_number = 6
	elif flavor.begins_with("dev"):
		flavor_number = 5
	var build: int = flavor.to_int()
	return major * 1000000 + minor * 10000 + patch * 1000 + flavor_number * 100 + build

func _compare_local_engine(a: LocalEngine, b: LocalEngine) -> bool:
	return a.info.sort_number > b.info.sort_number

func _get_executable_path(dir_name: String) -> String:
	var target_path: String = ""
	var target_suffix: String = App.architecture_to_executable_suffix(App.get_architecture())
	var dirs_to_scan: Array[String] = [App.ENGINE_DIR.path_join(dir_name)]
	while dirs_to_scan.size() > 0:
		var current_path: String = dirs_to_scan.pop_back()
		var current_dir: DirAccess = DirAccess.open(current_path)
		if current_dir != null:
			current_dir.list_dir_begin()
			var file_name: String = current_dir.get_next()
			while file_name != "":
				if file_name.ends_with(target_suffix):
					target_path = current_path.path_join(file_name)
					break
				elif current_dir.current_is_dir():
					if file_name != "." and file_name != "..":
						dirs_to_scan.append(current_path.path_join(file_name))
				file_name = current_dir.get_next()
			current_dir.list_dir_end()
	return target_path

func id_to_display_name(engine_id: String) -> String:
	var info: PackedStringArray = engine_id.split("-")
	if info.size() != 2 and info.size() != 3:
		return engine_id
	var version: String = info[0]
	var flavor: String = info[1]
	var result: String = ""
	if flavor == "stable":
		result = version
	elif flavor.begins_with("rc"):
		result = "%s RC %s" % [version, flavor.replace("rc", "")]
	elif flavor.begins_with("beta"):
		result = "%s Beta %s" % [version, flavor.replace("beta", "")]
	elif flavor.begins_with("dev"):
		result = "%s Dev %s" % [version, flavor.replace("dev", "")]
	elif flavor.begins_with("alpha"):
		result = "%s Alpha %s" % [version, flavor.replace("alpha", "")]
	if info.size() == 3 and info[2] == "dotnet":
		result = "%s (.NET)" % result
	return result
