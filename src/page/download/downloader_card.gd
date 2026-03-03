extends PanelContainer

signal extracted()

var url: String = ""
var file_name: String = ""
var file_type: DownloadManager.FileType = DownloadManager.FileType.UNKNOWN

var task_id: String = ""

var download_path: String = ""
var extract_task_id: int = -1

@onready var title_container: HBoxContainer = $MarginContainer/VBoxContainer/TitleContainer
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleContainer/TitleLabel
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoContainer/InfoLabel
@onready var close_button: Button = $MarginContainer/VBoxContainer/TitleContainer/CloseButton
@onready var cancel_button: Button = $MarginContainer/VBoxContainer/InfoContainer/CancelButton
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var timer: Timer = $Timer

func _ready() -> void:
	_handle_component()
	Config.config_updated.connect(_config_updated)
	if (url.is_empty()
		or file_name.is_empty()
		or file_type == DownloadManager.FileType.UNKNOWN):
		queue_free()
		return
	match file_type:
		DownloadManager.FileType.ENGINE:
			task_id = "engine_%s" % file_name
		DownloadManager.FileType.SOURCE_CODE:
			task_id = "source-code_%s_%d%d" % [
				file_name,
				int(Time.get_unix_time_from_system()),
				randi_range(0, 9)]
	if DownloadManager.downloading_task.get(task_id, false):
		queue_free()
		return
	DownloadManager.downloading_task[task_id] = true
	title_container.tooltip_text = url
	title_label.text = task_id
	if DirAccess.make_dir_recursive_absolute(DownloadManager.DOWNLOAD_DIR) != OK:
		_failed()
		return
	# Check cached file
	var cached_file_path: String = ProjectSettings.globalize_path(
		DownloadManager.DOWNLOAD_DIR.path_join("%s.tmp" % task_id))
	if FileAccess.file_exists(cached_file_path):
		match file_type:
			DownloadManager.FileType.ENGINE:
				_extract_file(cached_file_path, EngineManager.ENGINE_DIR.path_join(file_name))
			DownloadManager.FileType.SOURCE_CODE:
				_extract_file(cached_file_path, CompileManager.SOURCE_CODE_DIR.path_join(file_name))
		return
	download_path = ProjectSettings.globalize_path(
		DownloadManager.DOWNLOAD_DIR.path_join("%s.tmp" % task_id))
	http_request.download_file = download_path
	if http_request.request(url) != OK:
		_failed()
		return
	cancel_button.disabled = false
	timer.start()

func _config_updated(config_name: String) -> void:
	match config_name:
		"language":
			_handle_component()

func _handle_component() -> void:
	App.fix_button_width(cancel_button)

func _failed() -> void:
	info_label.text = "Failed"
	cancel_button.disabled = false
	timer.stop()
	if (download_path != ""
		and FileAccess.file_exists(download_path)):
		OS.move_to_trash(download_path)

func _on_timer_timeout() -> void:
	var total: int = http_request.get_body_size()
	if total <= 0:
		return
	var downloaded: int = http_request.get_downloaded_bytes()
	progress_bar.set_value_no_signal(float(downloaded) / float(total) * 98)
	
	
func _on_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	# Check download result
	if (result != HTTPRequest.RESULT_SUCCESS
		or response_code != 200):
		_failed()
		return
	timer.stop()
	progress_bar.set_value_no_signal(98)
	# Rename file
	var new_file_name: String = ""
	match file_type:
		DownloadManager.FileType.ENGINE:
			new_file_name = "%s.zip" % task_id
		DownloadManager.FileType.SOURCE_CODE:
			new_file_name = "%s.tar.xz" % task_id
	var new_file_path: String = ProjectSettings.globalize_path(
		DownloadManager.DOWNLOAD_DIR.path_join(new_file_name))
	if DirAccess.rename_absolute(download_path, new_file_path) != OK:
		_failed()
		return
	var target_dir_path: String = ""
	match file_type:
		DownloadManager.FileType.ENGINE:
			target_dir_path = EngineManager.ENGINE_DIR.path_join(file_name)
		DownloadManager.FileType.SOURCE_CODE:
			target_dir_path = CompileManager.SOURCE_CODE_DIR.path_join(file_name)
	_extract_file(new_file_path, ProjectSettings.globalize_path(target_dir_path))

func _extract_file(file_path: String, target_dir: String) -> void:
	progress_bar.set_value_no_signal(99)
	info_label.text = tr("DOWNLOADER_EXTRACT")
	cancel_button.disabled = true
	match file_type:
		DownloadManager.FileType.ENGINE:
			var zip: ZIPReader = ZIPReader.new()
			if zip.open(file_path) == OK:
				var files: PackedStringArray = zip.get_files()
				zip.close()
				if files.size() <= 0:
					_failed()
					return
			if DirAccess.make_dir_recursive_absolute(target_dir) != OK:
				_failed()
				return
			extract_task_id = WorkerThreadPool.add_task(_extract_zip_task.bind(file_path, target_dir))
		DownloadManager.FileType.SOURCE_CODE:
			if DirAccess.make_dir_recursive_absolute(target_dir) != OK:
				_failed()
				return
			extract_task_id = WorkerThreadPool.add_task(_extract_tar_xz_task.bind(file_path, target_dir))
	
	
func _extract_zip_task(zip_path: String, output_dir: String) -> void:
	var zip: ZIPReader = ZIPReader.new()
	if zip.open(zip_path) != OK:
		zip.close()
		_failed.call_deferred()
		return
	var files: PackedStringArray = zip.get_files()
	for file_path: String in files:
		if file_path.ends_with("/"):
			if DirAccess.make_dir_recursive_absolute(output_dir.path_join(file_path)) != OK:
				zip.close()
				_failed.call_deferred()
				return
			continue
		var buffer: PackedByteArray = zip.read_file(file_path)
		if buffer.size() > 0:
			var full_path: String = output_dir.path_join(file_path)
			var file: FileAccess = FileAccess.open(full_path, FileAccess.WRITE)
			if file == null:
				zip.close()
				_failed.call_deferred()
				return
			file.store_buffer(buffer)
			file.close()
	zip.close()
	extracted.emit.call_deferred()

func _extract_tar_xz_task(tar_xz_path: String, output_dir: String) -> void:
	if OS.execute("tar", ["-xJf", tar_xz_path, "-C", output_dir]) != OK:
		_failed.call_deferred()
		return
	extracted.emit.call_deferred()

func _on_extracted() -> void:
	WorkerThreadPool.wait_for_task_completion(extract_task_id)
	info_label.text = tr("DOWNLOADER_COMPLETE")
	progress_bar.set_value_no_signal(100)
	if (download_path != ""
		and FileAccess.file_exists(download_path)):
		OS.move_to_trash(download_path)
	DownloadManager.downloading_task.erase(file_name)
	close_button.disabled = false
	if Config.delete_download_file:
		var file_path: String = ""
		match file_type:
			DownloadManager.FileType.ENGINE:
				file_path = ProjectSettings.globalize_path(
					DownloadManager.DOWNLOAD_DIR.path_join("%s.zip" % task_id))
			DownloadManager.FileType.SOURCE_CODE:
				file_path = ProjectSettings.globalize_path(
					DownloadManager.DOWNLOAD_DIR.path_join("%s.tar.xz" % task_id))
		if FileAccess.file_exists(file_path):
			OS.move_to_trash(file_path)
	EngineManager.load_engines.call_deferred()
	

func _on_cancel_button_pressed() -> void:
	http_request.cancel_request()
	DownloadManager.downloading_task.erase(file_name)
	info_label.text = tr("DOWNLOADER_CANCEL")
	close_button.disabled = false
	cancel_button.disabled = true
	if (download_path != ""
		and FileAccess.file_exists(download_path)):
		OS.move_to_trash(download_path)


func _on_close_button_pressed() -> void:
	queue_free()
