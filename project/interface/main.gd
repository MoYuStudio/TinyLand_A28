extends Control

@onready var fps_label = $FPS
@onready var building_panel = $BuildingPanel
@onready var toggle_button = $ToggleButton

# 基础设施按钮
@onready var platform_button = $BuildingPanel/VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/PlatformButton
@onready var support_button = $BuildingPanel/VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/SupportButton
@onready var soil_button = $BuildingPanel/VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/SoilButton
@onready var net_button = $BuildingPanel/VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/NetButton

# 农业按钮
@onready var berry_button = $BuildingPanel/VBoxContainer/CategoryTabs/农业/AgricultureGrid/BerryButton
@onready var potato_button = $BuildingPanel/VBoxContainer/CategoryTabs/农业/AgricultureGrid/PotatoButton
@onready var tree_button = $BuildingPanel/VBoxContainer/CategoryTabs/农业/AgricultureGrid/TreeButton

# 工业按钮
@onready var solar_panel_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/SolarPanelButton
@onready var compost_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/CompostButton
@onready var cement_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/CementButton
@onready var metallurgy_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/MetallurgyButton

# 推进器按钮
@onready var engine_button = $BuildingPanel/VBoxContainer/CategoryTabs/推进器/PropulsionGrid/EngineButton
@onready var thruster_button = $BuildingPanel/VBoxContainer/CategoryTabs/推进器/PropulsionGrid/ThrusterButton

# 装饰按钮
@onready var flag_button = $BuildingPanel/VBoxContainer/CategoryTabs/装饰/DecorationGrid/FlagButton

var selected_building_type: String = "net"
var is_panel_visible: bool = true
var all_building_buttons: Array[Button] = []

func _ready():
	# 收集所有建筑按钮
	all_building_buttons = [
		# 基础设施
		platform_button, support_button, soil_button, net_button,
		# 农业
		berry_button, potato_button, tree_button,
		# 工业
		solar_panel_button, compost_button, cement_button, metallurgy_button,
		# 推进器
		engine_button, thruster_button,
		# 装饰
		flag_button
	]
	
	# 连接信号
	toggle_button.pressed.connect(_on_toggle_button_pressed)
	for button in all_building_buttons:
		if button != null:
			button.pressed.connect(_on_building_button_pressed.bind(button))
	
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

func _on_building_button_pressed(button: Button):
	# 根据按钮设置建筑类型
	if button == platform_button:
		selected_building_type = "platform"
	elif button == support_button:
		selected_building_type = "support"
	elif button == soil_button:
		selected_building_type = "soil"
	elif button == net_button:
		selected_building_type = "net"
	elif button == berry_button:
		selected_building_type = "berry"
	elif button == potato_button:
		selected_building_type = "potato"
	elif button == tree_button:
		selected_building_type = "tree"
	elif button == solar_panel_button:
		selected_building_type = "solar_panel"
	elif button == compost_button:
		selected_building_type = "compost"
	elif button == cement_button:
		selected_building_type = "cement"
	elif button == metallurgy_button:
		selected_building_type = "metallurgy"
	elif button == engine_button:
		selected_building_type = "engine"
	elif button == thruster_button:
		selected_building_type = "thruster"
	elif button == flag_button:
		selected_building_type = "flag"
	
	_update_button_states(button)

func _update_button_states(selected_button: Button):
	for button in all_building_buttons:
		if button != null:
			button.modulate = Color(1, 1, 1)
	if selected_button != null:
		selected_button.modulate = Color(0.7, 0.7, 1)

func get_selected_building_type() -> String:
	return selected_building_type

func set_selected_building_type(type: String):
	selected_building_type = type
	print("Selected building type: ", type)
