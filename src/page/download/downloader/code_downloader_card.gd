extends "res://src/page/download/downloader/downloader_card.gd"

var file_name: String = ""

func _handle_data() -> bool:
	if (file_name == ""
		or url == ""):
		return false
	download_task_id = "code-%s-%d" % [file_name.replace(" ", "_"), Time.get_unix_time_from_system()]
	var download_dir: String = ProjectSettings.globalize_path(DownloadManager.DOWNLOAD_DIR)
	cache_path = download_dir.path_join("%s.tmp" % download_task_id)
	download_path = download_dir.path_join("%s.tar.xz" % download_task_id)
	target_dir_path = ProjectSettings.globalize_path(
		CompileManager.SOURCE_CODE_DIR).path_join(file_name)
	return true

func _extract_task() -> void:
	if OS.execute("tar", ["-xJf", download_path, "-C", target_dir_path]) != OK:
		_failed.call_deferred()
		return
	extracted.emit.call_deferred()

func _succeeded() -> void:
	CompileManager.source_code_added.emit.call_deferred(file_name)