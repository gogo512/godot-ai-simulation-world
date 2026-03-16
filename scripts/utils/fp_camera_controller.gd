extends Camera3D
class_name FirstPersonCameraController
## 第一人称摄像机控制器
## 绑定到角色的头部

@export var target: Node3D
@export var head_offset: Vector3 = Vector3(0, 1.7, 0)
@export var mouse_sensitivity: float = 0.003

var rotation_x: float = 0.0

func _ready():
	print("📷 First person camera ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		target.rotate_y(-event.relative.x * mouse_sensitivity)
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, -PI/2, PI/2)
		rotation.x = rotation_x

func _process(delta):
	if target:
		global_position = target.global_position + head_offset
		global_rotation.y = target.global_rotation.y
