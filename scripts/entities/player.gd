extends CharacterBody3D
class_name Player
## Player - 玩家控制器
## 支持第一人称/第三人称移动、与NPC交互

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@export var interaction_range: float = 3.0

@onready var camera = $Camera3D
@onready var interaction_ray = $InteractionRay

var current_speed: float = walk_speed
var can_interact: bool = true
var nearby_npc: NPC = null

func _ready():
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("🎮 Player initialized")

func _input(event):
	# 鼠标视角控制
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	# 交互按键
	if event.is_action_pressed("interact") and can_interact and nearby_npc:
		_interact_with_npc()
	
	# 摄像机切换
	if event.is_action_pressed("camera_switch"):
		CameraManager.cycle_camera_mode()
	
	# 录制切换
	if event.is_action_pressed("toggle_recording"):
		_toggle_recording()

func _physics_process(delta):
	# 重力
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# 移动
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# 冲刺
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	else:
		current_speed = walk_speed
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
	
	# 检测附近的NPC
	_detect_nearby_npc()

func _detect_nearby_npc():
	var nearest_dist = interaction_range
	nearby_npc = null
	
	# 使用PhysicsServer3D检测附近的NPC
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = interaction_range
	query.shape = sphere
	query.transform = global_transform
	query.collision_mask = 2  # NPC层
	
	var results = space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider is NPC:
			var dist = global_position.distance_to(collider.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearby_npc = collider
	
	# 更新UI提示
	if nearby_npc and not UIManager.is_dialog_open():
		print("🎮 Press E to interact with " + nearby_npc.npc_name)

func _interact_with_npc():
	if nearby_npc:
		nearby_npc.interact(self)
		can_interact = false
		
		# 等待对话结束
		await UIManager.dialog_closed
		can_interact = true

func _toggle_recording():
	if GameManager.is_recording:
		GameManager.stop_recording()
		UIManager.hide_recording_ui()
	else:
		GameManager.start_recording()
		UIManager.show_recording_ui()

func get_camera() -> Camera3D:
	return camera
