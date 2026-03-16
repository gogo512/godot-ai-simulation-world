extends Node
## UI Manager - 用户界面管理器
## 管理所有UI界面、对话框、HUD

signal dialog_opened(npc_name: String)
signal dialog_closed
signal recording_ui_toggled(recording: bool)

var dialog_ui: Control
var hud_ui: Control
var recording_ui: Control
var main_menu: Control

func _ready():
	print("🖥️ UI Manager initialized")
	_create_ui_elements()

func _create_ui_elements():
	# 创建CanvasLayer作为UI容器
	var canvas = CanvasLayer.new()
	canvas.name = "UI_Canvas"
	canvas.layer = 10
	add_child(canvas)
	
	# 创建各个UI组件
	_create_hud(canvas)
	_create_dialog_ui(canvas)
	_create_recording_ui(canvas)

func _create_hud(parent: Node):
	hud_ui = Control.new()
	hud_ui.name = "HUD"
	hud_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_ui.visible = false
	parent.add_child(hud_ui)
	
	# 十字准星
	var crosshair = ColorRect.new()
	crosshair.name = "Crosshair"
	crosshair.size = Vector2(4, 4)
	crosshair.position = Vector2(-2, -2)
	crosshair.color = Color.WHITE
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	hud_ui.add_child(crosshair)
	
	# 状态信息
	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "AI Simulation World"
	status_label.position = Vector2(20, 20)
	status_label.add_theme_font_size_override("font_size", 16)
	hud_ui.add_child(status_label)

func _create_dialog_ui(parent: Node):
	dialog_ui = Control.new()
	dialog_ui.name = "DialogUI"
	dialog_ui.set_anchors_preset(Control.PRESET_CENTER)
	dialog_ui.visible = false
	parent.add_child(dialog_ui)
	
	# 对话框背景
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.size = Vector2(600, 200)
	bg.position = Vector2(-300, 200)
	bg.color = Color(0, 0, 0, 0.8)
	dialog_ui.add_child(bg)
	
	# NPC名称
	var name_label = Label.new()
	name_label.name = "NPCName"
	name_label.text = "NPC"
	name_label.position = Vector2(-280, 210)
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color.YELLOW)
	dialog_ui.add_child(name_label)
	
	# 对话内容
	var content_label = Label.new()
	content_label.name = "Content"
	content_label.text = "..."
	content_label.position = Vector2(-280, 240)
	content_label.size = Vector2(560, 120)
	content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_label.add_theme_font_size_override("font_size", 16)
	dialog_ui.add_child(content_label)
	
	# 输入提示
	var hint_label = Label.new()
	hint_label.name = "Hint"
	hint_label.text = "Press E to continue"
	hint_label.position = Vector2(-280, 360)
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color.GRAY)
	dialog_ui.add_child(hint_label)

func _create_recording_ui(parent: Node):
	recording_ui = Control.new()
	recording_ui.name = "RecordingUI"
	recording_ui.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	recording_ui.visible = false
	parent.add_child(recording_ui)
	
	# 录制指示器
	var indicator = ColorRect.new()
	indicator.name = "Indicator"
	indicator.size = Vector2(16, 16)
	indicator.position = Vector2(-120, 20)
	indicator.color = Color.RED
	recording_ui.add_child(indicator)
	
	# REC文字
	var rec_label = Label.new()
	rec_label.name = "RECLabel"
	rec_label.text = "REC"
	rec_label.position = Vector2(-100, 18)
	rec_label.add_theme_font_size_override("font_size", 16)
	rec_label.add_theme_color_override("font_color", Color.RED)
	recording_ui.add_child(rec_label)
	
	# 时长
	var time_label = Label.new()
	time_label.name = "TimeLabel"
	time_label.text = "00:00"
	time_label.position = Vector2(-60, 18)
	time_label.add_theme_font_size_override("font_size", 16)
	recording_ui.add_child(time_label)

func show_dialog(npc_name: String, text: String):
	dialog_ui.visible = true
	dialog_ui.get_node("NPCName").text = npc_name
	dialog_ui.get_node("Content").text = text
	emit_signal("dialog_opened", npc_name)
	print("💬 Dialog opened: " + npc_name)

func hide_dialog():
	dialog_ui.visible = false
	emit_signal("dialog_closed")
	print("💬 Dialog closed")

func update_dialog_text(text: String):
	if dialog_ui.visible:
		dialog_ui.get_node("Content").text = text

func show_hud():
	hud_ui.visible = true

func hide_hud():
	hud_ui.visible = false

func show_recording_ui():
	recording_ui.visible = true
	emit_signal("recording_ui_toggled", true)
	print("🔴 Recording UI shown")

func hide_recording_ui():
	recording_ui.visible = false
	emit_signal("recording_ui_toggled", false)
	print("⏹️ Recording UI hidden")

func update_recording_time(time_string: String):
	if recording_ui.visible:
		recording_ui.get_node("TimeLabel").text = time_string

func is_dialog_open() -> bool:
	return dialog_ui.visible

func _input(event):
	if event.is_action_pressed("interact") and dialog_ui.visible:
		hide_dialog()
