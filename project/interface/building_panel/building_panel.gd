extends Panel

signal building_selected(building_type: String)

# 基础设施按钮
@onready var platform_button = $VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/PlatformButton
@onready var support_button = $VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/SupportButton
@onready var soil_button = $VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/SoilButton
@onready var net_button = $VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/NetButton

# 农业按钮
@onready var berry_button = $VBoxContainer/CategoryTabs/农业/AgricultureGrid/BerryButton
@onready var potato_button = $VBoxContainer/CategoryTabs/农业/AgricultureGrid/PotatoButton
@onready var tree_button = $VBoxContainer/CategoryTabs/农业/AgricultureGrid/TreeButton

# 工业按钮
@onready var solar_panel_button = $VBoxContainer/CategoryTabs/工业/IndustrialGrid/SolarPanelButton
@onready var compost_button = $VBoxContainer/CategoryTabs/工业/IndustrialGrid/CompostButton
@onready var cement_button = $VBoxContainer/CategoryTabs/工业/IndustrialGrid/CementButton
@onready var metallurgy_button = $VBoxContainer/CategoryTabs/工业/IndustrialGrid/MetallurgyButton

# 推进器按钮
@onready var engine_button = $VBoxContainer/CategoryTabs/推进器/PropulsionGrid/EngineButton
@onready var thruster_button = $VBoxContainer/CategoryTabs/推进器/PropulsionGrid/ThrusterButton

# 装饰按钮
@onready var flag_button = $VBoxContainer/CategoryTabs/装饰/DecorationGrid/FlagButton

var selected_building_type: String = "net"
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
	for button in all_building_buttons:
		if button != null:
			button.pressed.connect(_on_building_button_pressed.bind(button))
	
	# 设置初始选中状态
	_update_button_states(net_button)

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
	building_selected.emit(selected_building_type)

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
	
	# 更新按钮状态
	for button in all_building_buttons:
		if button != null:
			var button_type = ""
			if button == platform_button:
				button_type = "platform"
			elif button == support_button:
				button_type = "support"
			elif button == soil_button:
				button_type = "soil"
			elif button == net_button:
				button_type = "net"
			elif button == berry_button:
				button_type = "berry"
			elif button == potato_button:
				button_type = "potato"
			elif button == tree_button:
				button_type = "tree"
			elif button == solar_panel_button:
				button_type = "solar_panel"
			elif button == compost_button:
				button_type = "compost"
			elif button == cement_button:
				button_type = "cement"
			elif button == metallurgy_button:
				button_type = "metallurgy"
			elif button == engine_button:
				button_type = "engine"
			elif button == thruster_button:
				button_type = "thruster"
			elif button == flag_button:
				button_type = "flag"
			
			if button_type == type:
				_update_button_states(button)
				break 