extends Node
## Game Manager - 全局游戏管理器
## 负责游戏状态、场景切换、全局配置

signal game_started
signal game_paused
signal game_resumed
signal game_ended

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	DIALOG,
	RECORDING
}

var current_state: GameState = GameState.MENU
var is_recording: bool = false
var recording_start_time: float = 0.0

func _ready():
	print("🎮 Game Manager initialized")

func start_game():
	current_state = GameState.PLAYING
	emit_signal("game_started")
	print("🎮 Game started")

func pause_game():
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true
		emit_signal("game_paused")
		print("⏸️ Game paused")

func resume_game():
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false
		emit_signal("game_resumed")
		print("▶️ Game resumed")

func start_recording():
	is_recording = true
	recording_start_time = Time.get_time_dict_from_system()["second"]
	current_state = GameState.RECORDING
	print("🔴 Recording started")

func stop_recording():
	is_recording = false
	current_state = GameState.PLAYING
	print("⏹️ Recording stopped")

func get_formatted_play_time() -> String:
	var elapsed = Time.get_time_dict_from_system()["second"] - recording_start_time
	var minutes = int(elapsed / 60)
	var seconds = int(elapsed % 60)
	return "%02d:%02d" % [minutes, seconds]
