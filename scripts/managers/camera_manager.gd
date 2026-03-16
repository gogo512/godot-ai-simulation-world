extends Node
## Camera Manager - 多视角摄像机管理器
## 支持自由视角、跟随视角、角色第一人称视角切换

signal camera_mode_changed(mode: int)
signal target_changed(target: Node3D)

enum CameraMode {
	FREE,       # 自由飞行视角
	FOLLOW,     # 跟随目标
	ORBIT,      # 环绕观察
	FIRST_PERSON,  # 角色第一人称
	CINEMATIC   # 电影运镜
}

@export var free_camera_scene: PackedScene
@export var follow_camera_scene: PackedScene
@export var orbit_camera_scene: PackedScene
@export var first_person_camera_scene: PackedScene

var current_camera: Camera3D
var current_mode: CameraMode = CameraMode.FREE
var current_target: Node3D

var camera_container: Node3D

func _ready():
	camera_container = Node3D.new()
	camera_container.name = "CameraContainer"
	get_tree().root.add_child.call_deferred(camera_container)
	
	print("📷 Camera Manager initialized")

func switch_mode(mode: CameraMode, target: Node3D = null):
	if current_mode == mode and current_target == target:
		return
	
	# 清理旧摄像机
	if current_camera:
		current_camera.queue_free()
	
	current_mode = mode
	current_target = target
	
	# 创建新摄像机
	match mode:
		CameraMode.FREE:
			current_camera = _create_free_camera()
		CameraMode.FOLLOW:
			current_camera = _create_follow_camera(target)
		CameraMode.ORBIT:
			current_camera = _create_orbit_camera(target)
		CameraMode.FIRST_PERSON:
			current_camera = _create_first_person_camera(target)
		CameraMode.CINEMATIC:
			current_camera = _create_cinematic_camera()
	
	camera_container.add_child(current_camera)
	
	# 设置为当前摄像机
	if current_camera:
		current_camera.make_current()
	
	emit_signal("camera_mode_changed", mode)
	if target:
		emit_signal("target_changed", target)
	
	print("📷 Camera switched to mode: " + str(mode))

func _create_free_camera() -> Camera3D:
	var camera = Camera3D.new()
	camera.name = "FreeCamera"
	
	# 添加自由控制器脚本
	var controller = load("res://scripts/utils/free_camera_controller.gd")
	camera.set_script(controller)
	
	return camera

func _create_follow_camera(target: Node3D) -> Camera3D:
	var camera = Camera3D.new()
	camera.name = "FollowCamera"
	
	if target:
		var offset = Vector3(0, 5, -8)
		camera.position = target.position + offset
		camera.look_at(target.position)
		
		# 添加跟随脚本
		var controller = load("res://scripts/utils/follow_camera_controller.gd")
		camera.set_script(controller)
		camera.target = target
	
	return camera

func _create_orbit_camera(target: Node3D) -> Camera3D:
	var camera = Camera3D.new()
	camera.name = "OrbitCamera"
	
	if target:
		var controller = load("res://scripts/utils/orbit_camera_controller.gd")
		camera.set_script(controller)
		camera.target = target
	
	return camera

func _create_first_person_camera(target: Node3D) -> Camera3D:
	var camera = Camera3D.new()
	camera.name = "FirstPersonCamera"
	
	if target:
		camera.position = target.position + Vector3(0, 1.7, 0)  # 眼睛高度
		
		var controller = load("res://scripts/utils/fp_camera_controller.gd")
		camera.set_script(controller)
		camera.target = target
	
	return camera

func _create_cinematic_camera() -> Camera3D:
	var camera = Camera3D.new()
	camera.name = "CinematicCamera"
	
	var controller = load("res://scripts/utils/cinematic_camera_controller.gd")
	camera.set_script(controller)
	
	return camera

func get_current_camera() -> Camera3D:
	return current_camera

func get_current_mode() -> CameraMode:
	return current_mode

func cycle_camera_mode():
	var next_mode = (current_mode + 1) % CameraMode.size()
	switch_mode(next_mode, current_target)
