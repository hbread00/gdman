extends Node

const ENGINE_DIR: String = "user://engine"
const DOWNLOAD_DIR: String = "user://download"

const ARCHITECTURE: Array[String] = [
	"windows_x86",
	"windows_x64",
	"windows_arm64",
	"linux_x86",
	"linux_x64",
	"linux_arm32",
	"linux_arm64",
	"macos",
]

func get_architecture() -> String:
	match OS.get_name():
		"Windows":
			match Engine.get_architecture_name():
				"x86_32":
					return "windows_x86"
				"x86_64":
					return "windows_x64"
				"arm64":
					return "windows_arm64"
		"macOS":
			return "macos"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			match Engine.get_architecture_name():
				"x86_32":
					return "linux_x86"
				"x86_64":
					return "linux_x64"
				"arm32":
					return "linux_arm32"
				"arm64":
					return "linux_arm64"
	return ""
