extends Node

# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.x86_64.zip&platform=linux.64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_linux_x86_64.zip&platform=linux.64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.x86_32.zip&platform=linux.32
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_linux_x86_32.zip&platform=linux.32
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.arm64.zip&platform=linux.arm64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_linux_arm64.zip&platform=linux.arm64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.arm32.zip&platform=linux.arm32
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_linux_arm32.zip&platform=linux.arm32
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=macos.universal.zip&platform=macos.universal
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_macos.universal.zip&platform=macos.universal
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=win64.exe.zip&platform=windows.64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_win64.zip&platform=windows.64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=win32.exe.zip&platform=windows.32
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_win32.zip&platform=windows.32
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=windows_arm64.exe.zip&platform=windows.arm64
# https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_windows_arm64.zip&platform=windows.arm64
const SOURCE_GODOT_URL: String = "https://downloads.godotengine.org/?version=%s&flavor=%s&slug=%s.zip&platform=%s"

const SOURCE_GODOT_PLATFORM: Dictionary[String, String] = {
	"windows_x86": "windows.32",
	"windows_x64": "windows.64",
	"windows_arm64": "windows.arm64",
	"linux_x86": "linux.32",
	"linux_x64": "linux.64",
	"linux_arm32": "linux.arm32",
	"linux_arm64": "linux.arm64",
	"macos": "macos.universal",
}

const SOURCE_GODOT_SLUG: Dictionary[String, String] = {
	"windows_x86": "win32.exe",
	"windows_x64": "win64.exe",
	"windows_arm64": "windows_arm64.exe",
	"linux_x86": "linux.x86_32",
	"linux_x64": "linux.x86_64",
	"linux_arm32": "linux.arm32",
	"linux_arm64": "linux.arm64",
	"macos": "macos.universal",
}

const SOURCE_GODOT_DOTNET_SLUG: Dictionary[String, String] = {
	"windows_x86": "mono_win32",
	"windows_x64": "mono_win64",
	"windows_arm64": "mono_windows_arm64",
	"linux_x86": "mono_linux_x86_32",
	"linux_x64": "mono_linux_x86_64",
	"linux_arm32": "mono_linux_arm32",
	"linux_arm64": "mono_linux_arm64",
	"macos": "mono_macos.universal",
}

# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_linux.arm32.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_linux.arm64.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_linux.x86_32.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_linux.x86_64.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_macos.universal.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_linux_arm32.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_linux_arm64.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_linux_x86_32.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_linux_x86_64.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_macos.universal.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_win32.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_win64.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_mono_windows_arm64.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_win32.exe.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_win64.exe.zip
# https://github.com/godotengine/godot-builds/releases/download/4.6-beta3/Godot_v4.6-beta3_win64.exe.zip
const SOURCE_GITHUB_URL: String = "https://github.com/godotengine/godot-builds/releases/download/%s/Godot_v%s_%s.zip"

const SOURCE_GITHUB_FILE: Dictionary[String, String] = {
	"windows_x86": "win32.exe",
	"windows_x64": "win64.exe",
	"windows_arm64": "windows_arm64",
	"linux_x86": "linux.x86_32",
	"linux_x64": "linux.x86_64",
	"linux_arm32": "linux.arm32",
	"linux_arm64": "linux.arm64",
	"macos": "macos.universal",
}

const SOURCE_GITHUB_DOTNET_FILE: Dictionary[String, String] = {
	"windows_x86": "mono_win32",
	"windows_x64": "mono_win64",
	"windows_arm64": "mono_windows_arm64",
	"linux_x86": "mono_linux_x86_32",
	"linux_x64": "mono_linux_x86_64",
	"linux_arm32": "mono_linux_arm32",
	"linux_arm64": "mono_linux_arm64",
	"macos": "mono_macos.universal",
}

var source_data: Dictionary = {
	"godot": {
		"4.5": ["4.5.1-stable"],
		"4.4": ["4.4.1-stable"],
		"4.3": ["4.3-stable"],
		"4.2": ["4.2.2-stable"],
		"4.1": ["4.1.4-stable"],
		"4.0": ["4.0.4-stable"]
	}
}

func _ready() -> void:
	var source_json: String = FileAccess.get_file_as_string("res://src/global/source.json")
	var json: JSON = JSON.new()
	if json.parse(source_json) == OK:
		source_data = json.data

func get_source_godot_url(version_name: String, is_dotnet: bool, architecture: String) -> String:
	var version_data: PackedStringArray = version_name.split("-")
	if version_data.size() != 2:
		return ""
	var version: String = version_data[0]
	var flavor: String = version_data[1]
	var slug: String = SOURCE_GODOT_SLUG.get(architecture, "")
	if is_dotnet:
		slug = SOURCE_GODOT_DOTNET_SLUG.get(architecture, "")
	var platform: String = SOURCE_GODOT_PLATFORM.get(architecture, "")
	return SOURCE_GODOT_URL % [version, flavor, slug, platform]

func get_source_github_url(version_name: String, is_dotnet: bool, architecture: String) -> String:
	var file: String = SOURCE_GITHUB_FILE.get(architecture, "")
	if is_dotnet:
		file = SOURCE_GITHUB_DOTNET_FILE.get(architecture, "")
	return SOURCE_GITHUB_URL % [version_name, version_name, file]
