extends Node

const CONFIG_PATH: String = "user://config.cfg"


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
