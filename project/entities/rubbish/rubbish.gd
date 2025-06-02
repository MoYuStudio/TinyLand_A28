extends Node2D

@export var speed: float = 50.0  # 移动速度
@export var rotation_speed: float = 1.0  # 旋转速度
@export var value: float = 1.0  # 垃圾价值

var direction: Vector2
var rng = RandomNumberGenerator.new()

func _ready():
	# 随机初始方向
	rng.randomize()
	var angle = rng.randf_range(0, TAU)
	direction = Vector2(cos(angle), sin(angle))
	
	# 随机初始旋转
	rotation = rng.randf_range(0, TAU)
	
	# 连接Area2D信号
	$Area2D.area_entered.connect(_on_area_2d_area_entered)

func _process(delta):
	# 移动
	position += direction * speed * delta
	
	# 旋转
	rotation += rotation_speed * delta
	
	# 检查是否超出边界
	var viewport_size = get_viewport_rect().size
	if position.x < -100 or position.x > viewport_size.x + 100 or \
	   position.y < -100 or position.y > viewport_size.y + 100:
		queue_free()

func _on_area_2d_area_entered(area: Area2D):
	# 检查是否与网碰撞
	var tile = area.get_parent()
	if tile and tile.has_method("get_tile_name") and tile.get_tile_name() == "net":
		print("垃圾被网捕获")
		tile.add_debris(value)
		queue_free()
