extends Control

@onready var fps_label = $FPS
@onready var building_panel = $BuildingPanel
@onready var toggle_button = $ToggleButton
@onready var category_tabs = $BuildingPanel/VBoxContainer/CategoryTabs

# 住宅类建筑按钮
@onready var house_button = $BuildingPanel/VBoxContainer/CategoryTabs/住宅/ResidentialGrid/HouseButton
@onready var apartment_button = $BuildingPanel/VBoxContainer/CategoryTabs/住宅/ResidentialGrid/ApartmentButton

# 商业类建筑按钮
@onready var shop_button = $BuildingPanel/VBoxContainer/CategoryTabs/商业/CommercialGrid/ShopButton
@onready var office_button = $BuildingPanel/VBoxContainer/CategoryTabs/商业/CommercialGrid/OfficeButton

# 工业类建筑按钮
@onready var farm_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/FarmButton
@onready var mine_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/MineButton
@onready var factory_button = $BuildingPanel/VBoxContainer/CategoryTabs/工业/IndustrialGrid/FactoryButton

# 基础设施类建筑按钮
@onready var road_button = $BuildingPanel/VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/RoadButton
@onready var power_plant_button = $BuildingPanel/VBoxContainer/CategoryTabs/基础设施/InfrastructureGrid/PowerPlantButton

var selected_building_type: String = ""
var is_panel_visible: bool = true
var all_building_buttons: Array[Button] = []

func _ready():
	# 收集所有建筑按钮
	all_building_buttons = [
		house_button, apartment_button,
		shop_button, office_button,
		farm_button, mine_button, factory_button,
		road_button, power_plant_button
	]
	
	# 连接按钮信号
	toggle_button.pressed.connect(_on_toggle_button_pressed)
	
	# 连接所有建筑按钮的信号
	for button in all_building_buttons:
		button.pressed.connect(_on_building_button_pressed.bind(button))
	
	# 初始化面板状态
	building_panel.visible = is_panel_visible

func _process(_delta):
	# 更新FPS显示
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: %d" % fps
	
	# 根据FPS值改变颜色
	if fps >= 120:
		fps_label.modulate = Color(0, 1, 0)  # 绿色
	elif fps >= 90:
		fps_label.modulate = Color(0.5, 1, 0)  # 浅绿色
	elif fps >= 60:
		fps_label.modulate = Color(1, 1, 0)  # 黄色
	elif fps >= 30:
		fps_label.modulate = Color(1, 0.5, 0)  # 橙色
	else:
		fps_label.modulate = Color(1, 0, 0)  # 红色

func _on_toggle_button_pressed():
	is_panel_visible = !is_panel_visible
	building_panel.visible = is_panel_visible

func _on_building_button_pressed(button: Button):
	# 获取按钮名称并转换为建筑类型
	var button_name = button.name.to_lower()
	selected_building_type = button_name.replace("button", "")
	_update_button_states(button)

func _update_button_states(selected_button: Button):
	# 重置所有按钮状态
	for button in all_building_buttons:
		button.modulate = Color(1, 1, 1)
	
	# 高亮选中的按钮
	selected_button.modulate = Color(0.7, 0.7, 1)

func get_selected_building_type() -> String:
	return selected_building_type
