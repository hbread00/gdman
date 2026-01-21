extends HBoxContainer

var file_name: String = ""
var version_name: String = ""

@onready var delete_dialog: ConfirmationDialog = $DeleteButton/DeleteDialog

func _on_path_button_pressed() -> void:
	pass # Replace with function body.


func _on_download_button_pressed() -> void:
	pass # Replace with function body.


func _on_delete_button_pressed() -> void:
	delete_dialog.popup_centered()
