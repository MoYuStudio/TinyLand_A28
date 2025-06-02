extends Panel

@onready var debris_label = $VBoxContainer/DebrisLabel
@onready var resources_label = $VBoxContainer/ResourcesLabel
@onready var buildings_label = $VBoxContainer/BuildingsLabel
@onready var tiles_label = $VBoxContainer/TilesLabel

func _ready():
	print("统计面板初始化")
	
	# 检查节点是否存在
	if not debris_label or not resources_label or not buildings_label or not tiles_label:
		push_error("统计面板缺少必要的节点")
		return
		
	# 检查Global是否存在
	if not has_node("/root/Global"):
		push_error("Global节点不存在")
		return
		
	# 连接Global的信号
	Global.debris_collected.connect(_on_debris_collected)
	Global.resource_updated.connect(_on_resource_updated)
	Global.building_placed.connect(_on_building_placed)
	Global.tile_placed.connect(_on_tile_placed)
	
	# 初始化显示
	update_statistics()
	print("统计面板初始化完成")

func update_statistics():
	if not has_node("/root/Global"):
		push_error("Global节点不存在")
		return
		
	var stats = Global.get_statistics()
	
	# 更新垃圾数量
	debris_label.text = "总收集垃圾: %.1f" % stats.total_debris
	
	# 更新资源
	var resources_text = "资源:\n"
	for resource in stats.total_resources:
		resources_text += "%s: %.1f\n" % [resource, stats.total_resources[resource]]
	resources_label.text = resources_text
	
	# 更新建筑
	var buildings_text = "建筑:\n"
	for building in stats.buildings:
		buildings_text += "%s: %d\n" % [building, stats.buildings[building]]
	buildings_label.text = buildings_text
	
	# 更新地形
	var tiles_text = "地形:\n"
	for tile in stats.tiles:
		tiles_text += "%s: %d\n" % [tile, stats.tiles[tile]]
	tiles_label.text = tiles_text

func _on_debris_collected(_amount):
	update_statistics()

func _on_resource_updated(_resource_type, _amount):
	update_statistics()

func _on_building_placed(_building_type):
	update_statistics()

func _on_tile_placed(_tile_type):
	update_statistics() 