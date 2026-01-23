extends VBoxContainer

const DOWNLOADER_CARD: PackedScene = preload("res://src/download/downloader_card.tscn")

@onready var download_confirm: ConfirmationDialog = $DownloadConfirm
@onready var stable_button: CheckButton = $TopBarContainer/OptionContainer/StableButton
@onready var dotnet_button: CheckButton = $TopBarContainer/OptionContainer/DotnetButton
@onready var downloader_container: VBoxContainer = $HSplitContainer/ScrollContainer2/DownloaderContainer

func _ready() -> void:
	var version_container: Array[Node] = get_tree().get_nodes_in_group("download_version_container")
	for container: Control in version_container:
		container.switch_unstable_display(stable_button.button_pressed)
		container.download.connect(_on_version_container_download)

func _on_stable_button_toggled(toggled_on: bool) -> void:
	var version_container: Array[Node] = get_tree().get_nodes_in_group("download_version_container")
	for container: Control in version_container:
		container.switch_unstable_display(toggled_on)

func _on_version_container_download(version_name: String, major_version: String) -> void:
	download_confirm.display(version_name, major_version, dotnet_button.button_pressed)


func _on_download_confirm_download(url: String, file_name: String) -> void:
	var downloader_card: Control = DOWNLOADER_CARD.instantiate()
	downloader_container.add_child(downloader_card)
	if dotnet_button.button_pressed:
		downloader_card.download(url, "%s-dotnet" % file_name)
	else:
		downloader_card.download(url, file_name)
