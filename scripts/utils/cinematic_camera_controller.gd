extends Camera3D
class_name CinematicCameraController
## 电影摄像机控制器
## 支持预设运镜路径和关键帧

@export var auto_play: bool = true
@export var loop: bool = true
@export var play_speed: float = 1.0

var keyframes: Array[Dictionary] = []
var current_keyframe: int = 0
var progress: float = 0.0
var is_playing: bool = false

func _ready():
	# 示例关键帧
	keyframes = [
		{"position": Vector3(0, 10, -20), "rotation": Vector3(-0.3, 0, 0), "duration": 3.0},
		{"position": Vector3(20, 5, -10), "rotation": Vector3(-0.2, 0.5, 0), "duration": 4.0},
		{"position": Vector3(-10, 8, 10), "rotation": Vector3(-0.4, -0.3, 0), "duration": 5.0}
	]
	
	if auto_play:
		play()
	
	print("📷 Cinematic camera ready with " + str(keyframes.size()) + " keyframes")

func play():
	is_playing = true
	current_keyframe = 0
	progress = 0.0

func stop():
	is_playing = false

func _process(delta):
	if not is_playing or keyframes.size() < 2:
		return
	
	var current = keyframes[current_keyframe]
	var next = keyframes[(current_keyframe + 1) % keyframes.size()]
	
	progress += delta * play_speed / current["duration"]
	
	if progress >= 1.0:
		progress = 0.0
		current_keyframe += 1
		
		if current_keyframe >= keyframes.size():
			if loop:
				current_keyframe = 0
			else:
				is_playing = false
				return
		
		current = keyframes[current_keyframe]
		next = keyframes[(current_keyframe + 1) % keyframes.size()]
	
	# 插值计算
	var t = ease(progress, 0.5)  # 使用缓动函数
	global_position = current["position"].lerp(next["position"], t)
	global_rotation = current["rotation"].lerp(next["rotation"], t)

func add_keyframe(pos: Vector3, rot: Vector3, duration: float):
	keyframes.append({
		"position": pos,
		"rotation": rot,
		"duration": duration
	})

func clear_keyframes():
	keyframes.clear()
