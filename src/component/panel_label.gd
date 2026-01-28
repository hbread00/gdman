extends PanelContainer

@export var text: String:
	set(v):
		text = v
		if Engine.is_editor_hint() or is_node_ready():
			label.text = text

@export var font_size: int = 16:
	set(v):
		font_size = v
		if Engine.is_editor_hint() or is_node_ready():
			label.add_theme_font_size_override("font_size", font_size)

@export_group("Margin")
@export var margin_left: int = 1:
	set(v):
		margin_left = v
		if Engine.is_editor_hint() or is_node_ready():
			margin_container.add_theme_constant_override("margin_left", margin_left)
@export var margin_top: int = 1:
	set(v):
		margin_top = v
		if Engine.is_editor_hint() or is_node_ready():
			margin_container.add_theme_constant_override("margin_top", margin_top)
@export var margin_right: int = 1:
	set(v):
		margin_right = v
		if Engine.is_editor_hint() or is_node_ready():
			margin_container.add_theme_constant_override("margin_right", margin_right)
@export var margin_bottom: int = 1:
	set(v):
		margin_bottom = v
		if Engine.is_editor_hint() or is_node_ready():
			margin_container.add_theme_constant_override("margin_bottom", margin_bottom)

@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/Label

func _ready() -> void:
	margin_container.add_theme_constant_override("margin_left", margin_left)
	margin_container.add_theme_constant_override("margin_top", margin_top)
	margin_container.add_theme_constant_override("margin_right", margin_right)
	margin_container.add_theme_constant_override("margin_bottom", margin_bottom)
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
