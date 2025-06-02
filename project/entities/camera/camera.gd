extends Camera2D

@export var move_speed = 200.0  # 相机移动速度
@export var zoom_speed = 2.0    # 缩放速度
@export var min_zoom = 0.5      # 最小缩放
@export var max_zoom = 10.0      # 最大缩放
@export var zoom_smoothness = 0.9  # 缩放平滑度 (0-1)

var current_zoom = 6.0          # 当前缩放值
var target_zoom = 6.0           # 目标缩放值
var last_printed_zoom = 6.0     # 上次打印的缩放值

func _ready():
	# 设置初始缩放
	zoom = Vector2(current_zoom, current_zoom)

func _process(delta):
	var direction = Vector2.ZERO
	
	# 检测WASD和方向键输入
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	# 检测缩放输入
	if Input.is_action_pressed("zoom_in"):
		target_zoom = clamp(target_zoom - zoom_speed * delta, min_zoom, max_zoom)
	if Input.is_action_pressed("zoom_out"):
		target_zoom = clamp(target_zoom + zoom_speed * delta, min_zoom, max_zoom)
	
	# 标准化方向向量，确保斜向移动速度不会更快
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# 更新相机位置
	position += direction * move_speed * delta
	
	# 平滑缩放
	if abs(current_zoom - target_zoom) > 0.001:
		current_zoom = lerp(current_zoom, target_zoom, zoom_smoothness)
		# 使用Camera2D的zoom属性
		zoom = Vector2(current_zoom, current_zoom)
		
		# 只在缩放值变化显著时打印
		if abs(current_zoom - last_printed_zoom) > 0.5:
			last_printed_zoom = current_zoom
