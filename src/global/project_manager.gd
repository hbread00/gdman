extends Node

const CONFIG_PATH: String = "user://project.cfg"

class ProjectInfo:
	var path: String = ""
	var version: String = ""
	var icon_path: String = ""
	var last_edited_time: int = 0
	var prefer_engine_id: String = ""

var project_info: Dictionary[String, ProjectInfo] = {
}

func _ready() -> void:
	load_config()

func store_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.save(CONFIG_PATH)

func load_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	for path: String in config.get_sections():
		var project_config: ConfigFile = ConfigFile.new()
		if project_config.load(path.path_join("project.godot")) != OK:
			continue
		var info: ProjectInfo = ProjectInfo.new()
		info.path = path
		info.version = _get_project_version(project_config)
		info.icon_path = _get_icon_path(
			project_config.get_value("application", "config/icon", ""),
			path)
		info.last_edited_time = _get_directory_last_edited_time(path)
		info.prefer_engine_id = config.get_value(path, "prefer_engine_id", "")
		if info.prefer_engine_id == "":
			for engine: EngineManager.LocalEngine in EngineManager.local_engines:
				if engine.info.id.begins_with(info.version):
					info.prefer_engine_id = engine.info.id
					break
		project_info[path] = info


func _get_project_version(config: ConfigFile) -> String:
	var feature: PackedStringArray = config.get_value("application", "config/features", ["unknown"])
	return feature[0]

func _get_icon_path(path: String, project_root: String) -> String:
	if path.begins_with("res://"):
		return project_root.path_join(path.replace("res://", ""))
	if path.begins_with("uid://"):
		var res_path: String = _uid_path_to_res_path(path, project_root)
		if res_path != "":
			return project_root.path_join(res_path.replace("res://", ""))
	return ""

func _uid_path_to_res_path(uid_path: String, project_root: String) -> String:
	var dir: DirAccess = DirAccess.open(project_root)
	if dir == null:
		return ""
	var dirs_to_scan: Array[String] = [project_root]
	while dirs_to_scan.size() > 0:
		var current_path: String = dirs_to_scan.pop_back()
		var current_dir: DirAccess = DirAccess.open(current_path)
		if current_dir != null:
			current_dir.list_dir_begin()
			var file_name: String = current_dir.get_next()
			while file_name != "":
				if current_dir.current_is_dir():
					if file_name != "." and file_name != "..":
						dirs_to_scan.append(current_path.path_join(file_name))
				else:
					if file_name.ends_with(".import"):
						var import_config: ConfigFile = ConfigFile.new()
						if (import_config.load(current_path.path_join(file_name)) == OK
							and import_config.get_value("remap", "uid", "") == uid_path):
							current_dir.list_dir_end()
							return import_config.get_value("deps", "source_file", "")
				file_name = current_dir.get_next()
			current_dir.list_dir_end()
	return ""


func _get_directory_last_edited_time(dir_path: String) -> int:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return 0
	var last_time: int = 0
	var dirs_to_scan: Array[String] = [dir_path]
	while dirs_to_scan.size() > 0:
		var current_path: String = dirs_to_scan.pop_back()
		var current_dir: DirAccess = DirAccess.open(current_path)
		if current_dir != null:
			current_dir.list_dir_begin()
			var file_name: String = current_dir.get_next()
			while file_name != "":
				if current_dir.current_is_dir():
					if file_name != "." and file_name != "..":
						dirs_to_scan.append(current_path.path_join(file_name))
				else:
					var file_time: int = FileAccess.get_modified_time(current_path.path_join(file_name))
					if file_time > last_time:
						last_time = file_time
				file_name = current_dir.get_next()
			current_dir.list_dir_end()
	return last_time