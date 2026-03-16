extends Camera3D
class_name FreeCameraController
## 自由摄像机控制器
## WASD自由飞行，鼠标控制视角

@export var move_speed: float = 10.0
@export var fast_multiplier: float = 3.0
@export var mouse_sensitivity: float = 0.003

var velocity: Vector3 = Vector3.ZERO
var is_active: bool = true

func _ready():
	print("📷 Free camera ready")

func _input(event):
	if not is_active:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)

func _process(delta):
	if not is_active:
		return
	
	var speed = move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= fast_multiplier
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var vertical = Input.get_axis("jump", "move_backward")  # 空格上升，Q下降
	
	var direction = (transform.basis * Vector3(input_dir.x, vertical, input_dir.y)).normalized()
	
	if direction:
		position += direction * speed * delta
