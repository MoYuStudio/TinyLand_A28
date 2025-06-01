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
@onready var choose_sprite = $Choose

# 状态变量
var growth_stage: int = 0  # 生长阶段（用于可种植的地形）
var timer: float = 0.0     # 计时器
var counter: int = 0       # 计数器
var is_selected: bool = false  # 是否被选中
var is_dragging: bool = false  # 是否正在拖动

# 缓存
var _last_mouse_pos: Vector2
var _update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # 每0.1秒更新一次

# 信号
signal tile_selected(tile: Node2D)
signal tile_deselected(tile: Node2D)

func _ready():
	update_tile_properties()
	update_visual()
	update_alpha()
	choose_sprite.visible = false

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				_last_mouse_pos = get_global_mouse_position()
				if is_point_in_tile(_last_mouse_pos):
					toggle_selected()
			else:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_selected()
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_pos = get_global_mouse_position()
		if is_point_in_tile(mouse_pos) and !is_selected:
			toggle_selected()
		_last_mouse_pos = mouse_pos

func is_point_in_tile(point: Vector2) -> bool:
	var local_pos = point - position
	var dx = abs(local_pos.x)
	var dy = abs(local_pos.y + 4)
	return dx <= 8 and dy <= 4 and (dx/8 + dy/4) <= 1

func toggle_selected():
	is_selected = !is_selected
	choose_sprite.visible = is_selected
	if is_selected:
		emit_signal("tile_selected", self)
		# 检查该位置是否已有building
		var has_building = false
		for child in get_parent().get_children():
			if child.is_in_group("buildings") and child.position == position + Vector2(0, -8):
				has_building = true
				break
		
		if not has_building:
			# 创建building
			var building_scene = load("res://entities/building/Building.tscn")
			if building_scene:
				print("成功加载Building场景")
				var building = building_scene.instantiate()
				building.add_to_group("buildings")  # 添加到buildings组
				get_parent().add_child(building)
				# 设置building位置，在等距地图中向上偏移8像素
				building.position = position + Vector2(0, -8)
				building.start_construction()
				# 设置tile属性
				set_passable(false)
				set_sailable(false)
				set_plantable(false)
			else:
				print("无法加载Building场景")
	else:
		emit_signal("tile_deselected", self)

func clear_selected():
	if is_selected:
		is_selected = false
		choose_sprite.visible = false
		emit_signal("tile_deselected", self)

func _process(delta):
	_update_timer += delta
	if _update_timer >= UPDATE_INTERVAL:
		_update_timer = 0.0
		match tile_name:
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
	if animated_sprite.sprite_frames.has_animation(tile_name):
		animated_sprite.animation = tile_name
		animated_sprite.play()
	else:
		var texture_path = "res://entities/tile/art/" + tile_name + ".png"
		var texture = load(texture_path)
		if texture:
			var sprite_frames = SpriteFrames.new()
			sprite_frames.add_animation(tile_name)
			sprite_frames.add_frame(tile_name, texture)
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.animation = tile_name
			animated_sprite.play()

func update_farmland(delta: float):
	if is_plantable and growth_stage < 3:
		timer += delta
		if timer >= 5.0:
			timer = 0.0
			growth_stage += 1

func update_lava(delta: float):
	pass  # 简化岩浆更新逻辑

func update_alpha():
	animated_sprite.modulate.a = alpha

func set_alpha(new_alpha: float):
	alpha = clamp(new_alpha, 0.0, 1.0)
	update_alpha()

func set_tile_type(new_type: String):
	if tile_name != new_type:
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

func set_passable(value: bool):
	is_passable = value

func set_sailable(value: bool):
	is_sailable = value

func set_plantable(value: bool):
	is_plantable = value
