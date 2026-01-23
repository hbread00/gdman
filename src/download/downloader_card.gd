extends PanelContainer

const TEMP_DIR: String = "user://temp"
const TEMP_PATH: String = "user://temp/%s.zip"
const ENGINE_PATH: String = "user://engine"
const FINISH_DIR: String = "user://engine/%s"

var temp_path: String = ""
var finish_dir: String = ""

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var info_label: Label = $VBoxContainer/InfoLabel
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var timer: Timer = $Timer

func download(url: String, file_name: String) -> void:
	title_label.text = file_name
	info_label.text = "Starting download..."
	progress_bar.value = 0
	if DirAccess.make_dir_recursive_absolute(TEMP_DIR) != OK:
		info_label.text = "Failed"
		return
	temp_path = TEMP_PATH % file_name
	http_request.download_file = temp_path
	if http_request.request(url) != OK:
		info_label.text = "Failed"
		return
	info_label.text = "Downloading..."
	finish_dir = FINISH_DIR % file_name
	timer.start()

func _on_timer_timeout() -> void:
	var total: int = http_request.get_body_size()
	if total <= 0:
		return
	var downloaded: int = http_request.get_downloaded_bytes()
	progress_bar.value = float(downloaded) / float(total) * 98
	
			
func _on_cancel_button_pressed() -> void:
	if http_request.get_http_client_status() == HTTPClient.STATUS_REQUESTING:
		http_request.cancel_request()
	queue_free()


func _on_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if (result == HTTPRequest.RESULT_SUCCESS
		and response_code == 200):
		timer.stop()
		progress_bar.value = 99
		if DirAccess.make_dir_recursive_absolute(finish_dir) != OK:
			info_label.text = "Failed"
			return
		var task_id: int = WorkerThreadPool.add_task(_uncompress_file.bind(temp_path, finish_dir))
		WorkerThreadPool.wait_for_task_completion(task_id)
	else:
		info_label.text = "Failed"

func _uncompress_file(zip_path: String, output_dir: String) -> void:
	info_label.set_deferred("text", "Uncompressing...")
	var zip: ZIPReader = ZIPReader.new()
	if DirAccess.make_dir_recursive_absolute(output_dir) != OK:
		zip.close()
		print("Failed to create output directory: %s" % output_dir)
		info_label.set_deferred("text", "Failed")
		return
	if zip.open(zip_path) != OK:
		print("Failed to open zip file: %s" % zip_path)
		info_label.set_deferred("text", "Failed")
		return
	var files: PackedStringArray = zip.get_files()
	for file_path: String in files:
		if file_path.ends_with("/"):
			if DirAccess.make_dir_recursive_absolute(output_dir.path_join(file_path)) != OK:
				zip.close()
				print("Failed to create directory: %s" % file_path)
				info_label.set_deferred("text", "Failed")
				return
			continue
		var buffer: PackedByteArray = zip.read_file(file_path)
		if buffer.size() > 0:
			var full_path: String = output_dir.path_join(file_path)
			var file: FileAccess = FileAccess.open(full_path, FileAccess.WRITE)
			if file == null:
				print("Failed to open file: %s" % full_path)
				info_label.set_deferred("text", "Failed")
				return
			file.store_buffer(buffer)
			file.close()
	zip.close()
	info_label.set_deferred("text", "Completed")
	progress_bar.set_deferred("value", 100)
