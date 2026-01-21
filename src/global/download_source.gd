extends Node

const PLATFORM: Array[String] = [
	"windows_x86",
	"windows_x64",
	"windows_arm64",
	"linux_x86",
	"linux_x64",
	"linux_arm32",
	"linux_arm64",
	"macos_universal",
]

const SOURCE_GODOT_SLUG: Dictionary = {
	"windows_x86": "win32.exe.zip",
	"windows_x64": "win64.exe.zip",
	"windows_arm64": "windows_arm64.exe.zip",
	"linux_x86": "linux.x86_32.zip",
	"linux_x64": "linux.x86_64.zip",
	"linux_arm32": "linux.arm32.zip",
	"linux_arm64": "linux.arm64.zip",
	"macos_universal": "macos.universal.zip",
}

const SOURCE_GODOT_PLATFORM: Dictionary = {
	"windows_x86": "windows.32",
	"windows_x64": "windows.64",
	"windows_arm64": "windows.arm64",
	"linux_x86": "linux.32",
	"linux_x64": "linux.64",
	"linux_arm32": "linux.arm32",
	"linux_arm64": "linux.arm64",
	"macos_universal": "macos.universal",
}

const SOURCE_GODOT_DOTNET_PREFIX: String = "mono_"


var godot_source_data: Dictionary = {
		"name": "Godot",
		"official": true,
		"base_url": "https://downloads.godotengine.org/",
		"slug": {
			"windows_x86": "win32.exe.zip",
			"windows_x64": "win64.exe.zip",
			"windows_arm64": "windows_arm64.exe.zip",
			"linux_x86": "linux.x86_32.zip",
			"linux_x64": "linux.x86_64.zip",
			"linux_arm32": "linux.arm32.zip",
			"linux_arm64": "linux.arm64.zip",
			"macos_universal": "macos.universal.zip",
		},
		"platform": {
			"windows_x86": "windows.32",
			"windows_x64": "windows.64",
			"windows_arm64": "windows.arm64",
			"linux_x86": "linux.32",
			"linux_x64": "linux.64",
			"linux_arm32": "linux.arm32",
			"linux_arm64": "linux.arm64",
			"macos_universal": "macos.universal",
		},
		"release": [
			{
				"name": "4.6_rc2",
				"project": "4.6",
				"major": "4.6",
				"flavor": "rc2",
				"stable": false,
				"standard": {
					"windows_x86": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=win32.exe.zip&platform=windows.32",
					"windows_x64": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=win64.exe.zip&platform=windows.64",
					"windows_arm64": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=windows_arm64.exe.zip&platform=windows.arm64",
					"linux_x86": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.x86_32.zip&platform=linux.32",
					"linux_x64": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.x86_64.zip&platform=linux.64",
					"linux_arm32": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.arm32.zip&platform=linux.arm32",
					"linux_arm64": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=linux.arm64.zip&platform=linux.arm64",
					"macos_universal": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=macos.universal.zip&platform=macos.universal",
				},
				"dotnet": {
					"windows_x64": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_win64.zip&platform=windows.64",
					"linux_x64": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_linux_arm64.zip&platform=linux.arm64",
					"macos_universal": "https://downloads.godotengine.org/?version=4.6&flavor=rc2&slug=mono_macos.universal.zip&platform=macos.universal",
				},
			},
		]
	}