extends Node

class EngineInfo:
	var id: String
	var name: String
	var version: String
	var is_unstable: bool = false
	var sort_number: int = 0
	var is_dotnet: bool = false
	var work_info: EngineWorkInfo
	
class EngineWorkInfo:
	var dir_path: String
	var executable_path: String

var engines: Array[EngineInfo] = []

func _ready() -> void:
	load_engines()

func load_engines() -> void:
	engines.clear()
	var engines_dir: DirAccess = DirAccess.open(App.ENGINE_DIR)
	if engines_dir == null:
		return
	for dir_name: String in engines_dir.get_directories():
		var engine_info: EngineInfo = id_to_engine_info(dir_name, true)
		if engine_info != null:
			engines.append(engine_info)
	engines.sort_custom(_compare_engine_info)

func id_to_engine_info(engine_id: String, with_work_info: bool = false) -> EngineInfo:
	var info: PackedStringArray = engine_id.split("-")
	if info.size() < 2 or info.size() > 3:
		return null
	var result: EngineInfo = EngineInfo.new()
	result.id = engine_id
	result.name = id_to_display_name(engine_id)
	# Version format: X.Y.Z or X.Y
	# Project only check X.Y
	var version_info: PackedStringArray = info[0].split(".")
	if version_info.size() >= 2:
		result.version = "%s.%s" % [version_info[0], version_info[1]]
	else:
		result.version = info[0]
	result.sort_number = _get_sort_number(result.version, info[1])
	if info.size() == 3 and info[2] == "dotnet":
		result.is_dotnet = true
	if info[1] != "stable":
		result.is_unstable = true
	if with_work_info:
		var target_path: String = _get_executable_path(engine_id)
		if target_path == "":
			result.free()
			return null
		var work_info: EngineWorkInfo = EngineWorkInfo.new()
		work_info.dir_path = ProjectSettings.globalize_path(App.ENGINE_DIR.path_join(engine_id))
		work_info.executable_path = ProjectSettings.globalize_path(target_path)
		result.work_info = work_info
	return result

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

func _compare_engine_info(a: EngineInfo, b: EngineInfo) -> bool:
	return a.sort_number > b.sort_number

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
