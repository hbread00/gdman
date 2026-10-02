extends ColorRect

const PROJECT_ICON: CompressedTexture2D = preload("uid://bsia01kbmakd0")
const ENGINE_ICON: CompressedTexture2D = preload("uid://ccmwlrli63fhi")
const DOWNLOAD_ICON: CompressedTexture2D = preload("uid://ddqhbrd1han2p")
const SETTING_ICON: CompressedTexture2D = preload("uid://mgdysp5iuh4l")


@onready var project_nav: Button = $MarginContainer/HBoxContainer/SideBar/TopContainer/ProjectNav
@onready var engine_nav: Button = $MarginContainer/HBoxContainer/SideBar/TopContainer/EngineNav
@onready var download_nav: Button = $MarginContainer/HBoxContainer/SideBar/TopContainer/DownloadNav
@onready var setting_nav: Button = $MarginContainer/HBoxContainer/SideBar/BottomContainer/SettingNav

@onready var icon_rect: TextureRect = $MarginContainer/HBoxContainer/MainContainer/TitleContainer/IconRect
@onready var title_label: Label = $MarginContainer/HBoxContainer/MainContainer/TitleContainer/TitleLabel
@onready var page_container: TabContainer = $MarginContainer/HBoxContainer/MainContainer/PageContainer


# 当前页面的标题词条，切换语言时重新取译文
var current_title: String = ""

func _ready() -> void:
	Config.config_updated.connect(_config_updated)
	switch_page(0, PROJECT_ICON, "TITLE_PROJECT", project_nav)

func _config_updated(config_name: String) -> void:
	match config_name:
		"language":
			title_label.text = tr(current_title)


func switch_page(page_index: int, page_icon: CompressedTexture2D, page_title: String, nav_button: Button) -> void:
	page_container.current_tab = page_index
	icon_rect.texture = page_icon
	current_title = page_title
	title_label.text = tr(current_title)
	# 使其它导航按钮可用
	project_nav.disabled = false
	engine_nav.disabled = false
	download_nav.disabled = false
	setting_nav.disabled = false
	nav_button.set_deferred("disabled", true)

func _on_project_nav_pressed() -> void:
	switch_page(0, PROJECT_ICON, "TITLE_PROJECT", project_nav)


func _on_engine_nav_pressed() -> void:
	switch_page(1, ENGINE_ICON, "TITLE_ENGINE", engine_nav)

func _on_download_nav_pressed() -> void:
	switch_page(2, DOWNLOAD_ICON, "TITLE_DOWNLOAD", download_nav)

func _on_setting_nav_pressed() -> void:
	switch_page(3, SETTING_ICON, "TITLE_SETTING", setting_nav)
