extends Node2D

var tile_scene = preload("res://entities/tile/Tile.tscn")
var tiles = {}
var interaction_areas = {}  # 存储交互区域
var tile_size = 16  # 瓷砖大小为16x16像素

# 地图尺寸控制
@export var initial_size = 1      # 初始地图尺寸（1x1）

# 缓存地图边界
var _map_bounds: Dictionary
var _map_offset: Vector2i

# 地形类型定义
const TILE_TYPES = {
	"base": {
		"passable": true,
		"sailable": true,
		"plantable": false,
		"light_source": false
	},
	"platform": {
		"passable": true,
		"sailable": false,
		"plantable": true,
		"light_source": false
	},
	"support": {
		"passable": false,
		"sailable": false,
		"plantable": false,
		"light_source": false
	},
	"soil": {
		"passable": true,
		"sailable": false,
		"plantable": true,
		"light_source": false
	},
	"net": {
		"passable": false,
		"sailable": false,
		"plantable": false,
		"light_source": false
	}
}

# 等距地图方向
const DIRECTIONS = [
	Vector2i(1, 0),   # 右
	Vector2i(0, 1),   # 下
	Vector2i(-1, 0),  # 左
	Vector2i(0, -1)   # 上
]

func _ready():
	# 预计算地图偏移和边界
	_map_offset = Vector2i(0, 0)  # 从中心开始
	_map_bounds = get_map_bounds()
	
	# 创建初始地图
	generate_initial_map()
	
	# 创建初始交互区域
	update_interaction_areas()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			var grid_pos = world_to_grid(mouse_pos)
			handle_tile_click(grid_pos)

func handle_tile_click(grid_pos: Vector2i):
	# 检查是否点击了交互区域
	for area_pos in interaction_areas.keys():
		if area_pos == grid_pos:
			# 使用默认的"net"类型
			var building_type = "net"
			
			# 创建新的tile
			add_tile(grid_pos, building_type)
			# 更新交互区域
			update_interaction_areas()
			break

func update_interaction_areas():
	# 清除旧的交互区域
	for area in interaction_areas.values():
		area.queue_free()
	interaction_areas.clear()
	
	# 为每个tile创建交互区域
	for tile_pos in tiles.keys():
		create_interaction_areas_for_tile(tile_pos)

func create_interaction_areas_for_tile(tile_pos: Vector2i):
	# 检查每个方向
	for dir in DIRECTIONS:
		var new_pos = tile_pos + dir
		# 如果该位置没有tile且没有交互区域，则创建交互区域
		if not tiles.has(new_pos) and not interaction_areas.has(new_pos):
			create_interaction_area(new_pos)

func create_interaction_area(grid_pos: Vector2i):
	var area = Area2D.new()
	area.collision_layer = 2
	area.collision_mask = 2
	area.monitorable = true
	area.monitoring = true
	area.input_pickable = true
	
	var collision = CollisionPolygon2D.new()
	var points = PackedVector2Array()
	# 创建菱形碰撞形状
	points.append(Vector2(0, -4))    # 上
	points.append(Vector2(-8, 0))    # 左
	points.append(Vector2(0, 4))     # 下
	points.append(Vector2(8, 0))     # 右
	collision.polygon = points
	area.add_child(collision)
	
	add_child(area)
	area.position = grid_to_world(grid_pos)
	interaction_areas[grid_pos] = area

func generate_initial_map():
	# 清除现有tile
	for tile in tiles.values():
		tile.queue_free()
	tiles.clear()
	
	# 生成初始基地格
	add_tile(Vector2i(0, 0), "base")

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x - grid_pos.y) * (tile_size / 2)
	var y = (grid_pos.x + grid_pos.y) * (tile_size / 4)
	return Vector2(x, y)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var x = (world_pos.x / (tile_size / 2) + world_pos.y / (tile_size / 4)) / 2
	var y = (world_pos.y / (tile_size / 4) - world_pos.x / (tile_size / 2)) / 2
	return Vector2i(round(x), round(y))

func is_valid_position(grid_position: Vector2i) -> bool:
	# 允许在任何位置创建新的基地格
	return true

func add_tile(grid_position: Vector2i, tile_type: String = "base") -> void:
	if not tiles.has(grid_position):
		var tile_instance = tile_scene.instantiate()
		add_child(tile_instance)
		tile_instance.position = grid_to_world(grid_position)
		tile_instance.set_tile_type(tile_type)
		tiles[grid_position] = tile_instance

func remove_tile(grid_position: Vector2i) -> void:
	if tiles.has(grid_position):
		var tile = tiles[grid_position]
		tile.queue_free()
		tiles.erase(grid_position)
		update_interaction_areas()

func get_tile(grid_position: Vector2i) -> Node2D:
	return tiles.get(grid_position)

func has_tile(grid_position: Vector2i) -> bool:
	return tiles.has(grid_position)

# 批量操作函数
func add_tiles(grid_positions: Array[Vector2i], tile_type: String = "base") -> void:
	for pos in grid_positions:
		add_tile(pos, tile_type)

func remove_tiles(grid_positions: Array[Vector2i]) -> void:
	for pos in grid_positions:
		remove_tile(pos)

# 获取指定区域内的所有tile
func get_tiles_in_area(start: Vector2i, end: Vector2i) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for x in range(start.x, end.x + 1):
		for y in range(start.y, end.y + 1):
			var pos = Vector2i(x, y)
			if has_tile(pos):
				result.append(get_tile(pos))
	return result

# 获取地图边界
func get_map_bounds() -> Dictionary:
	var min_pos = Vector2i(-initial_size/2, -initial_size/2)
	var max_pos = Vector2i(initial_size/2, initial_size/2)
	return {
		"min": min_pos,
		"max": max_pos,
		"center": Vector2i(0, 0)
	}

# 设置tile属性
func set_tile_properties(grid_position: Vector2i, properties: Dictionary) -> void:
	if has_tile(grid_position):
		var tile = get_tile(grid_position)
		for key in properties:
			if tile.has_method("set_" + key):
				tile.call("set_" + key, properties[key])

# 获取tile属性
func get_tile_properties(grid_position: Vector2i) -> Dictionary:
	if has_tile(grid_position):
		var tile = get_tile(grid_position)
		return {
			"name": tile.tile_name,
			"passable": tile.is_passable,
			"sailable": tile.is_sailable,
			"plantable": tile.is_plantable,
			"light_source": tile.is_light_source
		}
	return {}
