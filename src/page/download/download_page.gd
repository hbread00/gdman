extends VBoxContainer

const DOWNLOADER_CARD: PackedScene = preload("uid://bgk1814jgblda")

@onready var download_dialog: ConfirmationDialog = $DownloadDialog

@onready var standard_check: CheckBox = $OptionContainer/StandardCheck
@onready var dotnet_check: CheckBox = $OptionContainer/DotnetCheck
@onready var stable_check: CheckBox = $OptionContainer/StableCheck
@onready var unstable_check: CheckBox = $OptionContainer/UnstableCheck
@onready var download_source_code_button: Button = $OptionContainer/DownloadSourceCodeButton
@onready var download_source_code_dialog: ConfirmationDialog = $OptionContainer/DownloadSourceCodeButton/DownloadSourceCodeDialog
@onready var update_prompt_button: LinkButton = $OptionContainer/UpdatePromptButton

@onready var downloader_container: VBoxContainer = $HSplitContainer/PanelContainer2/MarginContainer/ScrollContainer/DownloaderContainer

func _ready() -> void:
	update_prompt_button.hide()
	DownloadManager.source_updated.connect(update_prompt_button.show)
	var version_containers: Array[Node] = get_tree().get_nodes_in_group("download_version_container")
	for container: Control in version_containers:
		container.download.connect(_on_version_container_download)
	standard_check.toggled.connect(_switch_display)
	dotnet_check.toggled.connect(_switch_display)
	stable_check.toggled.connect(_switch_display)
	unstable_check.toggled.connect(_switch_display)
	_switch_display(false)
	_handle_component()
	Config.config_updated.connect(_config_updated)

func _config_updated(config_name: String) -> void:
	match config_name:
		"language":
			_handle_component()

func _handle_component() -> void:
	App.fix_button_width(download_source_code_button)

func _on_version_container_download(engine_id: String) -> void:
	download_dialog.title = tr("DOWNLOAD_DIALOG_TITLE") % engine_id
	download_dialog.display(engine_id)

func _switch_display(_pass: bool) -> void:
	var version_containers: Array[Node] = get_tree().get_nodes_in_group("download_version_container")
	for container: Control in version_containers:
		container.switch_display(
			standard_check.button_pressed,
			dotnet_check.button_pressed,
			stable_check.button_pressed,
			unstable_check.button_pressed
		)


func _on_download_dialog_download(url: String, engine_id: String) -> void:
	var downloader_card: Control = DOWNLOADER_CARD.instantiate()
	downloader_card.url = url
	downloader_card.file_name = engine_id
	downloader_card.file_type = DownloadManager.FileType.ENGINE
	downloader_container.add_child(downloader_card)


func _on_download_source_code_button_pressed() -> void:
	download_source_code_dialog.display()


func _on_download_source_code_dialog_download(url: String, file_name: String) -> void:
	var downloader_card: Control = DOWNLOADER_CARD.instantiate()
	downloader_card.url = url
	downloader_card.file_name = file_name
	downloader_card.file_type = DownloadManager.FileType.SOURCE_CODE
	downloader_container.add_child(downloader_card)
