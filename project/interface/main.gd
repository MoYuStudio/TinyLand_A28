extends Control

@onready var fps_label = $FPS

func _process(_delta):
	# 更新FPS显示
	var fps = Engine.get_frames_per_second()
	fps_label.text = "FPS: %d" % fps
	
	# 根据FPS值改变颜色
	if fps >= 120:
		fps_label.modulate = Color(0, 1, 0)  # 绿色
	elif fps >= 90:
		fps_label.modulate = Color(0.5, 1, 0)  # 浅绿色
	elif fps >= 60:
		fps_label.modulate = Color(1, 1, 0)  # 黄色
	elif fps >= 30:
		fps_label.modulate = Color(1, 0.5, 0)  # 橙色
	else:
		fps_label.modulate = Color(1, 0, 0)  # 红色
