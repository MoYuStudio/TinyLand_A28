extends Node2D

var tile_scene = preload("res://entities/tile/Tile.tscn")
var tiles = {}
var tile_size = 16  # 瓷砖大小为16x16像素

# 地图尺寸控制
@export var map_size = 256      # 地图尺寸（正方形）

# 柏林噪声参数
@export var noise_scale: float = 0.02    # 噪声缩放（降低使地形变化更平缓）
@export var water_threshold: float = 0.5 # 水面阈值
var noise: FastNoiseLite

# 地形类型定义
const TILE_TYPES = {
	"grass": {
		"passable": true,
		"sailable": false,
		"plantable": true,
		"light_source": false
	},
	"water": {
		"passable": false,
		"sailable": true,
		"plantable": false,
		"light_source": false
	}
}

func _ready():
	# 初始化柏林噪声
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()  # 随机种子
	noise.fractal_octaves = 9        # 减少八度，使地形更平滑
	noise.fractal_gain = 0.6         # 降低增益，减少剧烈变化
	noise.fractal_lacunarity = 1.6   # 降低间隙，使地形更连贯
	noise.frequency =3.0            # 降低频率，减少细节变化
	
	# 创建初始地图
	generate_map()

func generate_map():
	# 清除现有tile
	for tile in tiles.values():
		tile.queue_free()
	tiles.clear()
	
	# 生成新地图
	var map_offset = calculate_map_offset()
	for x in range(map_size):
		for y in range(map_size):
			var grid_pos = Vector2i(x, y) + map_offset
			# 使用柏林噪声生成地形
			var noise_value = get_noise_value(x, y)
			# 使用两个噪声层叠加，减少细节变化
			var noise2 = get_noise_value(x * 1.5, y * 1.5) * 0.3
			var final_noise = (noise_value + noise2) / 1.3
			
			var tile_type = "water" if final_noise < water_threshold else "grass"
			add_tile(grid_pos, tile_type)

func get_noise_value(x: int, y: int) -> float:
	# 获取柏林噪声值
	var nx = x * noise_scale
	var ny = y * noise_scale
	return (noise.get_noise_2d(nx, ny) + 1.0) / 2.0  # 将值映射到0-1范围

# 等距地图的坐标转换
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# 等距地图的坐标转换公式
	var x = (grid_pos.x - grid_pos.y) * (tile_size / 2)
	var y = (grid_pos.x + grid_pos.y) * (tile_size / 4)
	return Vector2(x, y)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	# 反向转换：从世界坐标到网格坐标
	var x = (world_pos.x / (tile_size / 2) + world_pos.y / (tile_size / 4)) / 2
	var y = (world_pos.y / (tile_size / 4) - world_pos.x / (tile_size / 2)) / 2
	return Vector2i(round(x), round(y))

func calculate_map_offset() -> Vector2i:
	# 计算地图偏移，使地图居中
	var half_size = map_size / 2
	return Vector2i(-half_size, -half_size)

func is_valid_position(grid_position: Vector2i) -> bool:
	# 检查位置是否在地图范围内
	var map_offset = calculate_map_offset()
	var relative_pos = grid_position - map_offset
	return relative_pos.x >= 0 and relative_pos.x < map_size and \
		   relative_pos.y >= 0 and relative_pos.y < map_size

func add_tile(grid_position: Vector2i, tile_type: String = "grass") -> void:
	if not is_valid_position(grid_position):
		return
		
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

func get_tile(grid_position: Vector2i) -> Node2D:
	return tiles.get(grid_position)

func has_tile(grid_position: Vector2i) -> bool:
	return tiles.has(grid_position)

# 批量操作函数
func add_tiles(grid_positions: Array[Vector2i], tile_type: String = "grass") -> void:
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
	var map_offset = calculate_map_offset()
	var min_pos = map_offset
	var max_pos = map_offset + Vector2i(map_size - 1, map_size - 1)
	return {
		"min": min_pos,
		"max": max_pos,
		"center": (min_pos + max_pos) / 2
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
