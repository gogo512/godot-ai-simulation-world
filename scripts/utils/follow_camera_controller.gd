extends Camera3D
class_name FollowCameraController
## 跟随摄像机控制器
## 平滑跟随目标

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 5, -8)
@export var follow_speed: float = 5.0
@export var look_at_offset: Vector3 = Vector3(0, 1, 0)

func _ready():
	print("📷 Follow camera ready")

func _process(delta):
	if not target:
		return
	
	var target_position = target.global_position + offset
	global_position = global_position.lerp(target_position, follow_speed * delta)
	look_at(target.global_position + look_at_offset, Vector3.UP)
