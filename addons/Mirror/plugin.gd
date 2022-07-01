tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Mirror", "Spatial", preload("Mirror/Mirror.gd"), preload("icon.svg"))
	pass


func _exit_tree():
	remove_custom_type("Mirror")
	pass
