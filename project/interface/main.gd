extends Control

@onready var fps_label = $FPS
@onready var toggle_button = $ToggleButton

var building_panel: Panel
var is_panel_visible: bool = true

func _ready():
	# 实例化建筑面板
	var building_panel_scene = preload("res://interface/building_panel/building_panel.tscn")
	building_panel = building_panel_scene.instantiate()
	add_child(building_panel)
	
	# 连接信号
	toggle_button.pressed.connect(_on_toggle_button_pressed)
	building_panel.building_selected.connect(_on_building_selected)
	
	# 设置初始可见性
	building_panel.visible = is_panel_visible

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: " + str(fps)
	if fps >= 60:
		fps_label.modulate = Color(0, 1, 0)
	elif fps >= 30:
		fps_label.modulate = Color(1, 1, 0)
	else:
		fps_label.modulate = Color(1, 0, 0)

func _on_toggle_button_pressed():
	is_panel_visible = !is_panel_visible
	building_panel.visible = is_panel_visible

func _on_building_selected(building_type: String):
	print("Selected building type: ", building_type)
