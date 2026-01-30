extends Node

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

func engine_flavor_to_display_name(flavor: String) -> String:
	if flavor == "stable":
		return ""
	elif flavor.begins_with("rc"):
		return flavor.replace("rc", "RC ")
	elif flavor.begins_with("beta"):
		return flavor.replace("beta", "Beta ")
	elif flavor.begins_with("alpha"):
		return flavor.replace("alpha", "Alpha ")
	elif flavor.begins_with("dev"):
		return flavor.replace("dev", "Dev ")
	return flavor.to_upper()

func architecture_to_executable_suffix(architecture: String) -> String:
	match architecture:
		"windows_x86", "windows_x64", "windows_arm64":
			return ".exe"
		"linux_x86":
			return "x86_32"
		"linux_x64":
			return "x86_64"
		"linux_arm32":
			return "arm32"
		"linux_arm64":
			return "arm64"
		"macos":
			return ".app"
	return "foo" # Should not reach here
