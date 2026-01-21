extends Node

## 表示单个平台的下载信息
class PlatformDownload:
	var platform: String # 例如: "windows_x64", "linux_arm64", "macos_x64"
	var url: String
	
	func _init(platform_name: String, download_url: String = ""):
		platform = platform_name
		url = download_url
	
	func is_available() -> bool:
		return url != ""


## 表示构建类型（standard 或 dotnet）
class BuildType:
	var type: String # "standard" 或 "dotnet"
	var platforms: Dictionary[String, PlatformDownload]
	
	func _init(build_type: String):
		type = build_type
		platforms = {}
	
	func add_platform(platform_name: String, url: String = "") -> void:
		platforms[platform_name] = PlatformDownload.new(platform_name, url)
	
	func get_platform(platform_name: String) -> PlatformDownload:
		return platforms.get(platform_name)
	
	func get_available_platforms() -> Array[String]:
		var available: Array[String] = []
		for platform_name in platforms:
			if platforms[platform_name].is_available():
				available.append(platform_name)
		return available


## 表示具体的引擎版本（如 4.6rc2, 4.5.3）
class EngineVersion:
	var version: String # 例如: "4.6rc2", "4.5.3"
	var stable: bool
	var builds: Dictionary[String, BuildType] # "standard" 和 "dotnet"
	
	func _init(version_name: String, is_stable: bool = true):
		version = version_name
		stable = is_stable
		builds = {}
	
	func add_build(build_type: String) -> BuildType:
		if not builds.has(build_type):
			builds[build_type] = BuildType.new(build_type)
		return builds[build_type]
	
	func get_build(build_type: String) -> BuildType:
		return builds.get(build_type)
	
	func has_standard() -> bool:
		return builds.has("standard")
	
	func has_dotnet() -> bool:
		return builds.has("dotnet")
	
	func is_stable() -> bool:
		return stable


## 表示版本系列（如 4.6, 4.5）
class VersionSeries:
	var series: String # 例如: "4.6", "4.5"
	var versions: Dictionary[String, EngineVersion]
	
	func _init(series_name: String):
		series = series_name
		versions = {}
	
	func add_version(version_name: String, is_stable: bool = true) -> EngineVersion:
		if not versions.has(version_name):
			versions[version_name] = EngineVersion.new(version_name, is_stable)
		return versions[version_name]
	
	func get_version(version_name: String) -> EngineVersion:
		return versions.get(version_name)
	
	func get_all_versions() -> Array[String]:
		return versions.keys()
	
	func get_stable_versions() -> Array[String]:
		var stable: Array[String] = []
		for version_name in versions:
			if versions[version_name].is_stable():
				stable.append(version_name)
		return stable
	
	func get_latest_stable() -> EngineVersion:
		var stable_versions = get_stable_versions()
		if stable_versions.is_empty():
			return null
		# 返回第一个稳定版本（可以根据需要实现更复杂的版本比较）
		return versions[stable_versions[0]]


## 表示下载源（如 Godot 官方源）
class Source:
	var id: String # 例如: "godot"
	var name: String # 显示名称，例如: "Godot"
	var official: bool
	var version_series: Dictionary[String, VersionSeries]
	
	func _init(source_id: String, source_name: String = "", is_official: bool = false):
		id = source_id
		name = source_name if source_name != "" else source_id
		official = is_official
		version_series = {}
	
	func add_series(series_name: String) -> VersionSeries:
		if not version_series.has(series_name):
			version_series[series_name] = VersionSeries.new(series_name)
		return version_series[series_name]
	
	func get_series(series_name: String) -> VersionSeries:
		return version_series.get(series_name)
	
	func get_all_series() -> Array[String]:
		return version_series.keys()
	
	func is_official() -> bool:
		return official


## 从字典数据构建 Source 对象的工具函数
static func create_source_from_dict(source_id: String, data: Dictionary) -> Source:
	var source = Source.new(
		source_id,
		data.get("name", source_id),
		data.get("official", false)
	)
	
	# 遍历版本系列
	for series_name in data:
		if series_name in ["name", "official"]:
			continue
		
		var series_data = data[series_name]
		if not series_data is Dictionary:
			continue
		
		var series = source.add_series(series_name)
		
		# 遍历具体版本
		for version_name in series_data:
			var version_data = series_data[version_name]
			if not version_data is Dictionary:
				continue
			
			var version = series.add_version(
				version_name,
				version_data.get("stable", true)
			)
			
			# 遍历构建类型
			for build_type in version_data:
				if build_type == "stable":
					continue
				
				var build_data = version_data[build_type]
				if not build_data is Dictionary:
					continue
				
				var build = version.add_build(build_type)
				
				# 添加平台
				for platform_name in build_data:
					var platform_url = build_data[platform_name]
					build.add_platform(platform_name, platform_url)
	
	return source


## 从整个 source_data 字典创建所有 Source 对象
static func create_all_sources(source_data: Dictionary) -> Dictionary[String, Source]:
	var sources: Dictionary[String, Source] = {}
	
	for source_id in source_data:
		sources[source_id] = create_source_from_dict(source_id, source_data[source_id])
	
	return sources
