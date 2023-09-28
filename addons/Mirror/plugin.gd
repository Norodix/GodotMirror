@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Mirror", "Node3D", preload("Mirror/Mirror.gd"), preload("icon.svg"))
	add_autoload_singleton("MirrorManager","res://addons/Mirror/MirrorManager.gd")


func _exit_tree():
	remove_custom_type("Mirror")
	remove_autoload_singleton("MirrorManager")
