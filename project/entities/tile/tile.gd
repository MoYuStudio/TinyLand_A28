extends Node2D

# 基础属性
@export var tile_name: String = "base"  # 地形名称
@export var is_passable: bool = true     # 是否可通过
@export var is_sailable: bool = true     # 是否可航行
@export var is_plantable: bool = false   # 是否可种植
@export var is_light_source: bool = false # 是否发光
@export var is_platform: bool = false    # 是否是平台
@export var is_support: bool = false     # 是否是支撑架
@export var is_soil: bool = false        # 是否是泥土
@export var is_base: bool = true         # 是否是基地
@export var is_net: bool = false         # 是否是网

# 透明度设置
@export var alpha: float = 1.0          # 默认透明度 (0.0-1.0)
@export var base_alpha: float = 1.0     # 基地透明度
@export var platform_alpha: float = 0.9  # 平台透明度
@export var support_alpha: float = 0.85  # 支撑架透明度
@export var soil_alpha: float = 0.95    # 泥土透明度
@export var net_alpha: float = 0.8      # 网透明度

# 节点引用
@onready var animated_sprite = $AnimatedSprite
@onready var choose_sprite = $Choose
@onready var area_2d = $Area2D

# 状态变量
var is_selected: bool = false  # 是否被选中
var debris_amount: float = 0.0  # 太空垃圾数量

# 缓存
var _update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.1  # 每0.1秒更新一次

# 信号
signal tile_selected(tile: Node2D)
signal tile_deselected(tile: Node2D)
signal debris_collected(tile: Node2D, amount: float)

func _ready():
	print("Tile _ready called")
	update_tile_properties()
	update_visual()
	update_alpha()
	choose_sprite.visible = false
	
	# 连接Area2D信号
	area_2d.input_event.connect(_on_area_2d_input_event)
	area_2d.mouse_entered.connect(_on_area_2d_mouse_entered)
	area_2d.mouse_exited.connect(_on_area_2d_mouse_exited)

func _on_area_2d_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_selected()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			clear_selected()

func _on_area_2d_mouse_entered():
	if is_passable:
		modulate = Color(1.2, 1.2, 1.2)

func _on_area_2d_mouse_exited():
	modulate = Color(1, 1, 1)

func toggle_selected():
	is_selected = !is_selected
	choose_sprite.visible = is_selected
	if is_selected:
		emit_signal("tile_selected", self)
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
		if tile_name == "debris":
			update_debris(delta)

func update_tile_properties():
	match tile_name:
		"base":
			is_passable = true
			is_sailable = true
			is_plantable = false
			is_light_source = false
			is_platform = false
			is_support = false
			is_soil = false
			is_base = true
			is_net = false
			alpha = base_alpha
		"platform":
			is_passable = true
			is_sailable = false
			is_plantable = true
			is_light_source = false
			is_platform = true
			is_support = false
			is_soil = false
			is_base = false
			is_net = false
			alpha = platform_alpha
		"support":
			is_passable = false
			is_sailable = false
			is_plantable = false
			is_light_source = false
			is_platform = false
			is_support = true
			is_soil = false
			is_base = false
			is_net = false
			alpha = support_alpha
		"soil":
			is_passable = true
			is_sailable = false
			is_plantable = true
			is_light_source = false
			is_platform = false
			is_support = false
			is_soil = true
			is_base = false
			is_net = false
			alpha = soil_alpha
		"net":
			is_passable = false
			is_sailable = false
			is_plantable = false
			is_light_source = false
			is_platform = false
			is_support = false
			is_soil = false
			is_base = false
			is_net = true
			alpha = net_alpha

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

func update_debris(delta: float):
	# 太空垃圾的更新逻辑
	pass

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

func set_passable(value: bool):
	is_passable = value

func set_sailable(value: bool):
	is_sailable = value

func set_plantable(value: bool):
	is_plantable = value

func add_debris(amount: float):
	debris_amount += amount
	if debris_amount > 0 and tile_name == "space":
		set_tile_type("debris")

func remove_debris(amount: float) -> float:
	var collected = min(debris_amount, amount)
	debris_amount -= collected
	if debris_amount <= 0 and tile_name == "debris":
		set_tile_type("space")
		debris_amount = 0
	return collected
