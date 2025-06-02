extends Node2D

@export var star_count: int = 1000
@export var min_star_size: float = 0.1
@export var max_star_size: float = 0.5
@export var twinkle_speed: float = 1.0
@export var star_region_size: float = 2000.0  # 星星生成区域大小
@export var drift_speed: float = 10.0  # 星星漂移速度
@export var random_movement_speed: float = 5.0  # 随机运动速度

var stars: Array[Node2D] = []
var rng = RandomNumberGenerator.new()
var camera: Camera2D
var last_camera_position: Vector2
var star_region_center: Vector2
var star_velocities: Array[Vector2] = []  # 存储每个星星的速度

func _ready():
	# 设置随机数种子
	rng.seed = Time.get_unix_time_from_system()
	
	# 等待一帧以确保相机已经准备好
	await get_tree().process_frame
	camera = get_viewport().get_camera_2d()
	if camera:
		last_camera_position = camera.global_position
		star_region_center = camera.global_position
		generate_stars_in_region()
	
	# 创建背景渐变
	create_background()

func generate_stars_in_region():
	# 清除现有星星
	for star in stars:
		star.queue_free()
	stars.clear()
	star_velocities.clear()
	
	# 在区域中心周围生成星星
	var half_size = star_region_size / 2
	for i in range(star_count):
		var star = create_star()
		star.position = Vector2(
			rng.randf_range(star_region_center.x - half_size, star_region_center.x + half_size),
			rng.randf_range(star_region_center.y - half_size, star_region_center.y + half_size)
		)
		# 为每个星星生成随机速度
		var angle = rng.randf_range(0, TAU)
		var speed = rng.randf_range(drift_speed * 0.5, drift_speed)
		star_velocities.append(Vector2(cos(angle), sin(angle)) * speed)

func create_star() -> Node2D:
	var star = Node2D.new()
	var sprite = Sprite2D.new()
	
	# 创建星星纹理
	var texture = create_star_texture()
	sprite.texture = texture
	
	# 随机大小
	var scale = rng.randf_range(min_star_size, max_star_size)
	star.scale = Vector2(scale, scale)
	
	# 随机初始透明度
	sprite.modulate.a = rng.randf_range(0.3, 1.0)
	
	star.add_child(sprite)
	add_child(star)
	stars.append(star)
	return star

func create_star_texture() -> ImageTexture:
	var image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(image)

func create_background():
	var shader_material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	
	void fragment() {
		vec2 uv = UV;
		vec3 color = mix(
			vec3(0.05, 0.05, 0.1),
			vec3(0.1, 0.1, 0.2),
			uv.y
		);
		COLOR = vec4(color, 1.0);
	}
	"""
	shader_material.shader = shader
	
	var color_rect = ColorRect.new()
	color_rect.material = shader_material
	color_rect.size = get_viewport_rect().size * 2  # 扩大背景尺寸
	add_child(color_rect)
	move_child(color_rect, 0)

func _process(delta):
	if not camera:
		return
		
	# 更新背景位置
	var color_rect = get_child(0)
	color_rect.position = camera.global_position - color_rect.size / 2
	
	# 检查是否需要重新生成星星
	var distance_moved = camera.global_position.distance_to(last_camera_position)
	if distance_moved > star_region_size * 0.5:
		star_region_center = camera.global_position
		generate_stars_in_region()
		last_camera_position = camera.global_position
	
	# 更新星星位置和闪烁效果
	for i in range(stars.size()):
		var star = stars[i]
		var sprite = star.get_child(0)
		
		# 更新星星位置
		var velocity = star_velocities[i]
		star.position += velocity * delta
		
		# 添加随机运动
		var random_movement = Vector2(
			rng.randf_range(-1, 1),
			rng.randf_range(-1, 1)
		) * random_movement_speed * delta
		star.position += random_movement
		
		# 如果星星移出区域，重新生成
		var distance_to_center = star.position.distance_to(star_region_center)
		if distance_to_center > star_region_size:
			var angle = rng.randf_range(0, TAU)
			star.position = star_region_center + Vector2(cos(angle), sin(angle)) * star_region_size * 0.8
			# 重新生成速度
			angle = rng.randf_range(0, TAU)
			var speed = rng.randf_range(drift_speed * 0.5, drift_speed)
			star_velocities[i] = Vector2(cos(angle), sin(angle)) * speed
		
		# 闪烁效果
		var time = Time.get_ticks_msec() / 1000.0
		var offset = star.position.x + star.position.y
		var alpha = (sin(time * twinkle_speed + offset) + 1.0) * 0.5
		sprite.modulate.a = lerp(0.3, 1.0, alpha)
