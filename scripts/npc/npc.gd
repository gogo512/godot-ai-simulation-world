extends CharacterBody3D
class_name NPC
## NPC - 智能非玩家角色
## 具有AI对话能力、自主行为、情感状态

signal interaction_started
signal interaction_ended
signal ai_response_received(response: String)

@export var npc_id: String = "npc_001"
@export var npc_name: String = "Villager"
@export var personality: String = "friendly and helpful"
@export var role: String = "villager"
@export var interaction_radius: float = 3.0
@export var walk_speed: float = 2.0

@onready var mesh = $MeshInstance3D
@onready var interaction_area = $InteractionArea
@onready var detection_area = $DetectionArea

var ai_context: Dictionary = {}
var is_in_conversation: bool = false
var current_emotion: String = "neutral"
var target_position: Vector3
var is_moving: bool = false

func _ready():
	# 初始化AI上下文
	ai_context = {
		"name": npc_name,
		"personality": personality,
		"role": role,
		"world_state": "peaceful day in the village"
	}
	
	# 设置交互区域
	if interaction_area:
		interaction_area.body_entered.connect(_on_player_entered)
		interaction_area.body_exited.connect(_on_player_exited)
	
	print("👤 NPC initialized: " + npc_name)

func _physics_process(delta):
	if is_moving:
		_move_to_target(delta)

func _move_to_target(delta: float):
	if target_position.distance_to(position) < 0.5:
		is_moving = false
		return
	
	var direction = (target_position - position).normalized()
	velocity = direction * walk_speed
	look_at(target_position, Vector3.UP)
	move_and_slide()

func interact(player: Node3D):
	if is_in_conversation:
		return
	
	is_in_conversation = true
	look_at(player.position, Vector3.UP)
	emit_signal("interaction_started")
	
	# 显示初始对话
	_show_greeting()
	
	print("👤 NPC " + npc_name + " interacted by player")

func _show_greeting():
	var greetings = [
		"Hello there! How can I help you today?",
		"Greetings! Nice to meet you.",
		"Hey! What brings you here?",
		"Welcome! Is there something you need?"
	]
	
	var greeting = greetings[randi() % greetings.size()]
	UIManager.show_dialog(npc_name, greeting)

func send_message_to_ai(message: String):
	if AIManager:
		AIManager.response_received.connect(_on_ai_response, CONNECT_ONE_SHOT)
		AIManager.send_message(npc_id, message, ai_context)

func _on_ai_response(response_npc_id: String, response: String):
	if response_npc_id == npc_id:
		UIManager.update_dialog_text(response)
		emit_signal("ai_response_received", response)

func end_interaction():
	is_in_conversation = false
	UIManager.hide_dialog()
	emit_signal("interaction_ended")

func set_emotion(emotion: String):
	current_emotion = emotion
	# 可以在这里改变外观或动画
	print("👤 NPC " + npc_name + " emotion: " + emotion)

func walk_to(target: Vector3):
	target_position = target
	is_moving = true

func stop_moving():
	is_moving = false
	velocity = Vector3.ZERO

func _on_player_entered(body: Node3D):
	if body.is_in_group("player"):
		# 显示交互提示
		print("👤 Player entered interaction range of " + npc_name)

func _on_player_exited(body: Node3D):
	if body.is_in_group("player"):
		if is_in_conversation:
			end_interaction()
		print("👤 Player left interaction range of " + npc_name)

func update_world_state(new_state: String):
	ai_context["world_state"] = new_state
