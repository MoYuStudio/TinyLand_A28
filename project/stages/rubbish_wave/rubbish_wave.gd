extends Node2D

@export var wave_interval: float = 10.0  # 海浪间隔时间
@export var rubbish_per_wave: int = 20   # 每波垃圾数量
@export var wave_duration: float = 5.0   # 每波持续时间
@export var spawn_radius: float = 1000.0 # 生成半径

var rubbish_scene = preload("res://entities/rubbish/rubbish.tscn")
var timer: float = 0.0
var is_wave_active: bool = false
var wave_timer: float = 0.0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(delta):
	timer += delta
	
	# 检查是否需要开始新的一波
	if timer >= wave_interval and not is_wave_active:
		start_wave()
	
	# 如果正在生成垃圾
	if is_wave_active:
		wave_timer += delta
		
		# 检查是否应该结束这一波
		if wave_timer >= wave_duration:
			end_wave()
		else:
			# 在波持续时间内生成垃圾
			if get_child_count() < rubbish_per_wave:
				spawn_rubbish()

func start_wave():
	is_wave_active = true
	wave_timer = 0.0
	print("开始新的一波垃圾")

func end_wave():
	is_wave_active = false
	timer = 0.0
	print("结束当前垃圾波")

func spawn_rubbish():
	var rubbish = rubbish_scene.instantiate()
	
	# 在圆形边界上随机生成位置
	var angle = rng.randf_range(0, TAU)
	var distance = rng.randf_range(0, spawn_radius)
	var spawn_pos = Vector2(cos(angle), sin(angle)) * distance
	
	# 设置随机属性
	rubbish.speed = rng.randf_range(30.0, 70.0)
	rubbish.rotation_speed = rng.randf_range(-2.0, 2.0)
	rubbish.value = rng.randf_range(0.5, 2.0)
	
	# 设置位置和方向
	rubbish.position = spawn_pos
	rubbish.direction = -spawn_pos.normalized()  # 朝向中心
	
	add_child(rubbish)
