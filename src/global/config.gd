extends Node

const CONFIG_PATH: String = "user://config.cfg"

# resolution
var window_sizes: Array[Vector2i] = [
	Vector2i(3200, 2400), # QUXGA
	Vector2i(2800, 2100), # QSXGA+
	Vector2i(2048, 1536), # QXGA
	Vector2i(1600, 1200), # UXGA
	Vector2i(1440, 1080), # HDV 1080i
	Vector2i(1400, 1050), # SXGA+
	Vector2i(1280, 960), # SXGA-
	Vector2i(1152, 864), # XGA+
	Vector2i(1024, 768), # XGA
	Vector2i(800, 600), # SVGA
	Vector2i(768, 576), # PAL (4:3)
	Vector2i(640, 480), # VGA
]


func _ready() -> void:
	load_config()

func _exit_tree() -> void:
	store_config()

func store_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.save(CONFIG_PATH)

func load_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return