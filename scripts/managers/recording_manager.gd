extends Node
## Recording Manager - 视频录制管理器
## 使用 Godot 的 MovieWriter 或帧捕获实现录制

signal recording_started
signal recording_stopped
signal frame_captured(frame_number: int)

var is_recording: bool = false
var recording_fps: int = 30
var output_path: String = "user://recordings/"
var current_frame: int = 0
var recording_start_time: int = 0

var capture_timer: Timer
var frame_buffer: Array[Image] = []
var max_buffer_size: int = 100

func _ready():
	# 创建输出目录
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("recordings")
	
	# 创建定时器
	capture_timer = Timer.new()
	capture_timer.wait_time = 1.0 / recording_fps
	capture_timer.timeout.connect(_on_capture_timer)
	add_child(capture_timer)
	
	print("🎥 Recording Manager initialized")

func start_recording(filename: String = ""):
	if is_recording:
		return
	
	is_recording = true
	current_frame = 0
	frame_buffer.clear()
	recording_start_time = Time.get_ticks_msec()
	
	# 生成文件名
	if filename.is_empty():
		var datetime = Time.get_datetime_dict_from_system()
		filename = "recording_%04d%02d%02d_%02d%02d%02d" % [
			datetime["year"], datetime["month"], datetime["day"],
			datetime["hour"], datetime["minute"], datetime["second"]
		]
	
	output_path = "user://recordings/" + filename + "/"
	DirAccess.make_dir_recursive_absolute(output_path)
	
	capture_timer.start()
	emit_signal("recording_started")
	print("🎥 Recording started: " + output_path)

func stop_recording():
	if not is_recording:
		return
	
	is_recording = false
	capture_timer.stop()
	
	# 保存剩余的帧
	_save_buffered_frames()
	
	emit_signal("recording_stopped")
	print("🎥 Recording stopped. Total frames: " + str(current_frame))
	
	# 提示用户
	OS.shell_open(ProjectSettings.globalize_path("user://recordings/"))

func _on_capture_timer():
	if not is_recording:
		return
	
	# 捕获当前帧
	_capture_frame()
	
	# 更新UI
	var elapsed = (Time.get_ticks_msec() - recording_start_time) / 1000.0
	var minutes = int(elapsed / 60)
	var seconds = int(elapsed) % 60
	var time_str = "%02d:%02d" % [minutes, seconds]
	
	if UIManager:
		UIManager.update_recording_time(time_str)

func _capture_frame():
	# 获取当前视口
	var viewport = get_viewport()
	if not viewport:
		return
	
	# 捕获帧
	var img = viewport.get_texture().get_image()
	if img:
		frame_buffer.append(img)
		current_frame += 1
		emit_signal("frame_captured", current_frame)
		
		# 缓冲区满了就保存
		if frame_buffer.size() >= max_buffer_size:
			_save_buffered_frames()

func _save_buffered_frames():
	if frame_buffer.is_empty():
		return
	
	# 在后台线程保存帧
	var thread = Thread.new()
	thread.start(_save_frames_thread.bind(frame_buffer.duplicate()))
	frame_buffer.clear()

func _save_frames_thread(frames: Array[Image]):
	for i in range(frames.size()):
		var frame_index = current_frame - frames.size() + i
		var filename = output_path + "frame_%06d.png" % frame_index
		frames[i].save_png(filename)
	
	print("🎥 Saved " + str(frames.size()) + " frames")

func set_fps(fps: int):
	recording_fps = fps
	capture_timer.wait_time = 1.0 / fps

func get_recording_duration() -> float:
	if not is_recording:
		return 0.0
	return (Time.get_ticks_msec() - recording_start_time) / 1000.0

func get_estimated_file_size() -> String:
	var viewport_size = get_viewport().size
	var bytes_per_frame = viewport_size.x * viewport_size.y * 4  # RGBA
	var total_bytes = bytes_per_frame * current_frame
	
	if total_bytes < 1024 * 1024:
		return "%.2f KB" % (total_bytes / 1024.0)
	elif total_bytes < 1024 * 1024 * 1024:
		return "%.2f MB" % (total_bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (total_bytes / (1024.0 * 1024.0 * 1024.0))
