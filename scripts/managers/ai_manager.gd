extends Node
## AI Manager - 大模型AI管理器
## 负责与LLM API通信、管理NPC对话上下文

signal response_received(npc_id: String, response: String)
signal context_updated(npc_id: String)

const API_BASE_URL = "https://api.moonshot.cn/v1"
const DEFAULT_MODEL = "kimi-k2.5"

var http_request: HTTPRequest
var api_key: String = ""
var conversation_history: Dictionary = {}  # npc_id: Array[message]

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# 尝试从环境变量读取API key
	api_key = OS.get_environment("MOONSHOT_API_KEY")
	if api_key.is_empty():
		push_warning("⚠️ MOONSHOT_API_KEY not set in environment")
	else:
		print("🔑 AI Manager initialized with API key")

func set_api_key(key: String):
	api_key = key
	print("🔑 API key updated")

func send_message(npc_id: String, message: String, context: Dictionary = {}):
	if api_key.is_empty():
		push_error("❌ API key not set")
		return
	
	# 构建系统提示
	var system_prompt = _build_system_prompt(context)
	
	# 获取或创建对话历史
	if not conversation_history.has(npc_id):
		conversation_history[npc_id] = []
	
	var messages = conversation_history[npc_id].duplicate()
	messages.append({"role": "system", "content": system_prompt})
	messages.append({"role": "user", "content": message})
	
	var body = {
		"model": DEFAULT_MODEL,
		"messages": messages,
		"temperature": 0.8,
		"max_tokens": 1024
	}
	
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	var json_body = JSON.stringify(body)
	var error = http_request.request(
		API_BASE_URL + "/chat/completions",
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	
	if error != OK:
		push_error("❌ Failed to send request: " + str(error))
	else:
		print("📤 Message sent to AI for NPC: " + npc_id)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("❌ Request failed: " + str(result))
		return
	
	if response_code != 200:
		push_error("❌ HTTP error: " + str(response_code))
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error != OK:
		push_error("❌ JSON parse error: " + json.get_error_message())
		return
	
	var response_data = json.get_data()
	if response_data.has("choices") and response_data["choices"].size() > 0:
		var message = response_data["choices"][0]["message"]["content"]
		var npc_id = "npc_001"  # 应该从上下文中获取
		
		# 保存到历史
		if not conversation_history.has(npc_id):
			conversation_history[npc_id] = []
		conversation_history[npc_id].append({"role": "assistant", "content": message})
		
		emit_signal("response_received", npc_id, message)
		print("📥 AI response received")

func _build_system_prompt(context: Dictionary) -> String:
	var npc_name = context.get("name", "Unknown")
	var personality = context.get("personality", "friendly")
	var role = context.get("role", "villager")
	var world_state = context.get("world_state", "peaceful day")
	
	return """You are %s, a %s in a simulation world. Your personality is %s.

Current world state: %s

Respond in character. Keep responses concise (2-3 sentences max). You can:
- Answer questions
- Share information about the world
- React to events
- Express emotions

Do not break character or mention you are an AI.""" % [npc_name, role, personality, world_state]

func clear_history(npc_id: String):
	conversation_history.erase(npc_id)

func get_history(npc_id: String) -> Array:
	return conversation_history.get(npc_id, [])
