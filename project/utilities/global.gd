extends Node

# 玩家数据
var player_data = {
	"total_debris_collected": 0.0,  # 总收集垃圾量
	"total_resources": {            # 总资源
		"metal": 0.0,
		"plastic": 0.0,
		"organic": 0.0
	},
	"buildings": {                  # 建筑统计
		"house": 0,
		"apartment": 0,
		"shop": 0,
		"office": 0,
		"solar_panel": 0,
		"compost": 0,
		"cement": 0,
		"metallurgy": 0,
		"engine": 0,
		"thruster": 0,
		"flag": 0
	},
	"tiles": {                      # 地形统计
		"base": 0,
		"platform": 0,
		"support": 0,
		"soil": 0,
		"net": 0
	}
}

# 游戏设置
var game_settings = {
	"difficulty": "normal",         # 难度
	"sound_volume": 1.0,           # 音量
	"music_volume": 1.0,           # 音乐音量
	"fullscreen": false            # 全屏
}

# 信号
signal debris_collected(amount: float)
signal resource_updated(resource_type: String, amount: float)
signal building_placed(building_type: String)
signal tile_placed(tile_type: String)

func _ready():
	Save.load_data()

# 添加收集的垃圾
func add_debris(amount: float):
	player_data.total_debris_collected += amount
	emit_signal("debris_collected", amount)
	Save.save_data()

# 添加资源
func add_resource(resource_type: String, amount: float):
	if player_data.total_resources.has(resource_type):
		player_data.total_resources[resource_type] += amount
		emit_signal("resource_updated", resource_type, amount)
		Save.save_data()

# 放置建筑
func place_building(building_type: String):
	if player_data.buildings.has(building_type):
		player_data.buildings[building_type] += 1
		emit_signal("building_placed", building_type)
		Save.save_data()

# 放置地形
func place_tile(tile_type: String):
	if player_data.tiles.has(tile_type):
		player_data.tiles[tile_type] += 1
		emit_signal("tile_placed", tile_type)
		Save.save_data()

# 获取统计数据
func get_statistics() -> Dictionary:
	return {
		"total_debris": player_data.total_debris_collected,
		"total_resources": player_data.total_resources,
		"buildings": player_data.buildings,
		"tiles": player_data.tiles
	}

# 重置数据
func reset_data():
	player_data = {
		"total_debris_collected": 0.0,
		"total_resources": {
			"metal": 0.0,
			"plastic": 0.0,
			"organic": 0.0
		},
		"buildings": {
			"house": 0,
			"apartment": 0,
			"shop": 0,
			"office": 0,
			"solar_panel": 0,
			"compost": 0,
			"cement": 0,
			"metallurgy": 0,
			"engine": 0,
			"thruster": 0,
			"flag": 0
		},
		"tiles": {
			"base": 0,
			"platform": 0,
			"support": 0,
			"soil": 0,
			"net": 0
		}
	}
	Save.save_data()
