extends Node2D

# 基础属性
@export var tile_name: String = "grass"  # 地形名称
@export var is_passable: bool = true     # 是否可通过
@export var is_sailable: bool = false    # 是否可航行
@export var is_plantable: bool = false   # 是否可种植
@export var is_light_source: bool = false # 是否发光

# 透明度设置
@export var alpha: float = 1.0          # 默认透明度 (0.0-1.0)
@export var grass_alpha: float = 1.0    # 草地透明度
@export var water_alpha: float = 0.8    # 水面透明度
@export var lava_alpha: float = 0.9     # 岩浆透明度
@export var farmland_alpha: float = 1.0  # 农田透明度

# 节点引用
@onready var animated_sprite = $AnimatedSprite

# 状态变量
var growth_stage: int = 0  # 生长阶段（用于可种植的地形）
var timer: float = 0.0     # 计时器
var counter: int = 0       # 计数器

func _ready():
	update_tile_properties()
	update_visual()
	update_alpha()

func _process(delta):
	timer += delta
	match tile_name:
		"water":
			# 水面动画由AnimatedSprite自动播放
			pass
		"farmland":
			update_farmland(delta)
		"lava":
			update_lava(delta)

func update_tile_properties():
	match tile_name:
		"grass":
			is_passable = true
			is_sailable = false
			is_plantable = true
			is_light_source = false
			alpha = grass_alpha
		"water":
			is_passable = false
			is_sailable = true
			is_plantable = false
			is_light_source = false
			alpha = water_alpha
		"lava":
			is_passable = false
			is_sailable = false
			is_plantable = false
			is_light_source = true
			alpha = lava_alpha
		"farmland":
			is_passable = true
			is_sailable = false
			is_plantable = true
			is_light_source = false
			alpha = farmland_alpha

func update_visual():
	# 检查是否存在对应的动画
	if animated_sprite.sprite_frames.has_animation(tile_name):
		# 如果有动画，播放动画
		animated_sprite.animation = tile_name
		animated_sprite.play()
	else:
		# 如果没有动画，显示静态图片
		var texture_path = "res://entities/tile/art/" + tile_name + ".png"
		var texture = load(texture_path)
		if texture:
			# 创建单帧动画
			var sprite_frames = SpriteFrames.new()
			sprite_frames.add_animation(tile_name)
			sprite_frames.add_frame(tile_name, texture)
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.animation = tile_name
			animated_sprite.play()

func update_farmland(delta: float):
	if is_plantable and growth_stage < 3:
		if timer >= 5.0:
			timer = 0.0
			growth_stage += 1

func update_lava(delta: float):
	if is_light_source:
		pass

func update_alpha():
	animated_sprite.modulate.a = alpha

func set_alpha(new_alpha: float):
	alpha = clamp(new_alpha, 0.0, 1.0)
	update_alpha()

func set_tile_type(new_type: String):
	tile_name = new_type
	update_tile_properties()
	update_visual()
	update_alpha()

func can_pass() -> bool:
	return is_passable

func can_sail() -> bool:
	return is_sailable

func can_plant() -> bool:
	return is_plantable

func get_growth_stage() -> int:
	return growth_stage

func increment_counter():
	counter += 1
	# 可以添加计数器达到特定值时的效果
