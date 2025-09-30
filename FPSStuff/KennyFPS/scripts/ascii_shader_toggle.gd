extends Node3D

# Reference to the ASCII post-process mesh
@onready var ascii_postprocess = $ASCIIPostProcess

func _ready():
	print("ASCII Shader Toggle loaded - Press F1 to toggle ASCII effect")

func _input(event):
	if event.is_action_pressed("ui_select"): # F1 key by default in Godot
		toggle_ascii_shader()

func toggle_ascii_shader():
	if ascii_postprocess:
		ascii_postprocess.visible = !ascii_postprocess.visible
		if ascii_postprocess.visible:
			print("ASCII Shader: ON")
		else:
			print("ASCII Shader: OFF")