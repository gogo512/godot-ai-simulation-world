extends Camera3D
class_name OrbitCameraController
## 环绕摄像机控制器
## 围绕目标旋转观察

@export var target: Node3D
@export var distance: float = 10.0
@export var height: float = 3.0
@export var orbit_speed: float = 0.5
@export var mouse_sensitivity: float = 0.01

var angle: float = 0.0
var height_offset: float = 0.0
var is_mouse_controlling: bool = false

func _ready():
	print("📷 Orbit camera ready")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_mouse_controlling = event.pressed
	
	if is_mouse_controlling and event is InputEventMouseMotion:
		angle -= event.relative.x * mouse_sensitivity
		height_offset -= event.relative.y * mouse_sensitivity * 0.5
		height_offset = clamp(height_offset, -5, 10)

func _process(delta):
	if not target:
		return
	
	# 自动旋转
	if not is_mouse_controlling:
		angle += orbit_speed * delta
	
	var target_pos = target.global_position
	var x = target_pos.x + cos(angle) * distance
	var z = target_pos.z + sin(angle) * distance
	var y = target_pos.y + height + height_offset
	
	global_position = Vector3(x, y, z)
	look_at(target_pos + Vector3(0, 1, 0), Vector3.UP)
