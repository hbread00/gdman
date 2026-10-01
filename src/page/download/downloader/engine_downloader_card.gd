extends "res://src/page/download/downloader/downloader_card.gd"

var engine_id: String = ""
var architecture: String = ""

func _handle_data() -> bool:
	if (engine_id == ""
			or architecture == ""
			or url == ""):
		return false
	download_task_name = "%s:%s" % [engine_id, architecture]
	# 架构写入任务 ID，使同版本的不同架构拥有独立缓存
	download_task_id = encode_id("engine:%s:%s" % [architecture, engine_id])
	cache_path = _download_dir.path_join("%s.tmp" % download_task_id)
	download_path = _download_dir.path_join("%s.zip" % download_task_id)
	# 解压目标为引擎目录下的 架构/引擎 子目录
	target_dir_path = ProjectSettings.globalize_path(
		EngineManager.get_architecture_engine_dir(
		architecture).path_join(engine_id))
	return true

# 解压前的预检，必须在主线程、创建目标目录之前完成
func _pre_extract_file() -> bool:
	var zip: ZIPReader = ZIPReader.new()
	# open 失败时无需 close，此时文件引用已由内部释放，close 反而会报错
	if zip.open(download_path) != OK:
		return false
	var files: PackedStringArray = zip.get_files()
	zip.close()
	# 空压缩包视为无效，避免建出空的引擎目录
	return files.size() > 0

# 解压任务，运行在工作线程，内部不能直接操作界面
func _extract_task() -> void:
	var zip: ZIPReader = ZIPReader.new()
	if zip.open(download_path) != OK:
		_failed.call_deferred()
		return
	# 逐条目写入，zip 读出来的是路径，不是文件本身，需要先将每个条目读取出来再写入文件
	for file_path: String in zip.get_files():
		# 以 / 结尾的条目表示目录，创建对应的目录
		if file_path.ends_with("/"):
			if DirAccess.make_dir_recursive_absolute(target_dir_path.path_join(file_path)) != OK:
				zip.close()
				_failed.call_deferred()
				return
			continue
		var full_path: String = target_dir_path.path_join(file_path)
		# FileAccess.open 不会自动创建父目录，且条目未必带有对应的目录条目，所以先创建父目录
		if DirAccess.make_dir_recursive_absolute(full_path.get_base_dir()) != OK:
			zip.close()
			_failed.call_deferred()
			return
		# 最后写入文件内容
		var file: FileAccess = FileAccess.open(full_path, FileAccess.WRITE)
		if file == null:
			zip.close()
			_failed.call_deferred()
			return
		file.store_buffer(zip.read_file(file_path))
		file.close()
	zip.close()
	extracted.emit.call_deferred()

func _succeeded() -> void:
	EngineManager.load_engines.call_deferred()
