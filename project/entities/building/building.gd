extends Node2D

# 基础属性
@export var building_name: String = "net"  # 建筑物名称
@export var is_passable: bool = false        # 是否可通过
@export var is_enterable: bool = false       # 是否可进入
@export var is_destructible: bool = true     # 是否可破坏
@export var is_light_source: bool = false    # 是否发光

# 建筑物属性
@export var health: float = 50.0            # 建筑物生命值
@export var max_health: float = 50.0        # 最大生命值
@export var construction_time: float = 2.0   # 建造时间
@export var construction_cost: int = 50     # 建造成本
@export var maintenance_cost: int = 5       # 维护成本
@export var collection_rate: float = 1.0    # 收集速率（每秒）
@export var collection_range: int = 1       # 收集范围

# 透明度设置
@export var alpha: float = 1.0              # 默认透明度
@export var construction_alpha: float = 0.5  # 建造中的透明度

# 节点引用
@onready var animated_sprite = $AnimatedSprite
@onready var choose_sprite = $Choose
@onready var health_bar = $HealthBar

# 状态变量
var is_selected: bool = false
var is_dragging: bool = false
var is_under_construction: bool = false
var construction_progress: float = 0.0
var _last_mouse_pos: Vector2
var _update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # 每0.1秒更新一次
var total_collected: float = 0.0    # 总共收集的垃圾数量

# 信号
signal building_selected(building: Node2D)
signal building_deselected(building: Node2D)
signal construction_completed(building: Node2D)
signal building_destroyed(building: Node2D)
signal debris_collected(amount: float)

func _ready():
	z_index = 1  # 设置building始终在tile上层
	add_to_group("buildings")  # 添加到buildings组
	update_building_properties()
	update_visual()
	update_alpha()
	choose_sprite.visible = false
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		health_bar.visible = false

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				_last_mouse_pos = get_global_mouse_position()
				if is_point_in_building(_last_mouse_pos):
					toggle_selected()
			else:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_selected()
	elif event is InputEventMouseMotion and is_dragging:
		var mouse_pos = get_global_mouse_position()
		if is_point_in_building(mouse_pos) and !is_selected:
			toggle_selected()
		_last_mouse_pos = mouse_pos

func is_point_in_building(point: Vector2) -> bool:
	var local_pos = point - position
	var dx = abs(local_pos.x)
	var dy = abs(local_pos.y + 4)
	return dx <= 8 and dy <= 4 and (dx/8 + dy/4) <= 1

func toggle_selected():
	is_selected = !is_selected
	choose_sprite.visible = is_selected
	if health_bar:
		health_bar.visible = is_selected
	if is_selected:
		emit_signal("building_selected", self)
	else:
		emit_signal("building_deselected", self)

func clear_selected():
	if is_selected:
		is_selected = false
		choose_sprite.visible = false
		if health_bar:
			health_bar.visible = false
		emit_signal("building_deselected", self)

func _process(delta):
	_update_timer += delta
	if _update_timer >= UPDATE_INTERVAL:
		_update_timer = 0.0
		if is_under_construction:
			update_construction(delta)
		else:
			update_building(delta)

func update_building_properties():
	match building_name:
		"net":
			is_passable = false
			is_enterable = false
			is_destructible = true
			is_light_source = false
			health = 50.0
			max_health = 50.0
			construction_time = 2.0
			construction_cost = 50
			maintenance_cost = 5
			collection_rate = 1.0
			collection_range = 1

func update_visual():
	var texture_path = "res://entities/building/art/" + building_name + ".png"
	print("尝试加载建筑图片: ", texture_path)
	var texture = load(texture_path)
	if texture:
		print("成功加载建筑图片")
		var sprite_frames = SpriteFrames.new()
		sprite_frames.add_animation(building_name)
		sprite_frames.add_frame(building_name, texture)
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.animation = building_name
		animated_sprite.play()
	else:
		print("无法加载建筑图片: ", texture_path)

func update_construction(delta: float):
	construction_progress += delta
	if construction_progress >= construction_time:
		construction_progress = construction_time
		is_under_construction = false
		alpha = 1.0
		update_alpha()
		emit_signal("construction_completed", self)

func update_building(delta: float):
	if is_under_construction:
		alpha = lerp(construction_alpha, 1.0, construction_progress / construction_time)
		update_alpha()
	else:
		# 收集太空垃圾
		collect_debris(delta)

func collect_debris(delta: float):
	var tilemap = get_parent()
	if not tilemap:
		return
		
	var grid_pos = tilemap.world_to_grid(position)
	var collected = 0.0
	
	# 在收集范围内搜索太空垃圾
	for x in range(-collection_range, collection_range + 1):
		for y in range(-collection_range, collection_range + 1):
			var check_pos = grid_pos + Vector2i(x, y)
			var tile = tilemap.get_tile(check_pos)
			if tile and tile.tile_name == "debris":
				var amount = tile.remove_debris(collection_rate * delta)
				collected += amount
	
	if collected > 0:
		total_collected += collected
		emit_signal("debris_collected", collected)

func update_alpha():
	animated_sprite.modulate.a = alpha

func set_alpha(new_alpha: float):
	alpha = clamp(new_alpha, 0.0, 1.0)
	update_alpha()

func set_building_type(new_type: String):
	if building_name != new_type:
		building_name = new_type
		update_building_properties()
		update_visual()
		update_alpha()

func take_damage(amount: float):
	if is_destructible:
		health = max(0.0, health - amount)
		if health_bar:
			health_bar.value = health
		if health <= 0:
			emit_signal("building_destroyed", self)
			queue_free()

func repair(amount: float):
	health = min(max_health, health + amount)
	if health_bar:
		health_bar.value = health

func start_construction():
	is_under_construction = true
	construction_progress = 0.0
	alpha = construction_alpha
	update_alpha()

func can_enter() -> bool:
	return is_enterable and !is_under_construction

func can_destroy() -> bool:
	return is_destructible and !is_under_construction

func get_construction_progress() -> float:
	return construction_progress / construction_time

func get_total_collected() -> float:
	return total_collected 
