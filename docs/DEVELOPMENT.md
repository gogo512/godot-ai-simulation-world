# AI 模拟世界 - 开发文档

## 🏗️ 系统架构

### 核心管理器 (Singletons)

| 管理器 | 职责 | 关键信号 |
|--------|------|----------|
| GameManager | 游戏状态、录制控制 | game_started, game_paused |
| AIManager | LLM API通信、对话历史 | response_received |
| CameraManager | 视角切换、摄像机控制 | camera_mode_changed |
| UIManager | 对话框、HUD、录制UI | dialog_opened, dialog_closed |
| RecordingManager | 帧捕获、视频录制 | recording_started, recording_stopped |

### 实体系统

```
CharacterBody3D (基类)
├── Player (玩家)
│   ├── 移动控制
│   ├── 摄像机交互
│   └── NPC检测
└── NPC (非玩家角色)
    ├── AI对话
    ├── 自主移动
    └── 情感状态
```

## 🔄 交互流程

### NPC 对话流程

```
玩家按E → Player._interact_with_npc()
              ↓
         NPC.interact()
              ↓
         UIManager.show_dialog()
              ↓
    [玩家输入消息]
              ↓
    AIManager.send_message()
              ↓
    [等待API响应]
              ↓
    UIManager.update_dialog_text()
              ↓
    [按E关闭对话]
              ↓
    NPC.end_interaction()
```

### 摄像机切换流程

```
按T键 → CameraManager.cycle_camera_mode()
            ↓
    CameraManager.switch_mode()
            ↓
    [创建新摄像机]
            ↓
    camera.make_current()
            ↓
    emit_signal("camera_mode_changed")
```

### 录制流程

```
按R键 → Player._toggle_recording()
            ↓
    GameManager.start_recording()
    RecordingManager.start_recording()
            ↓
    [定时器启动]
            ↓
    _capture_frame() [每帧]
            ↓
    [保存到磁盘]
            ↓
    再按R → stop_recording()
```

## 🎨 扩展指南

### 添加新的NPC

```gdscript
# 在 scenes/main.tscn 中复制一个NPC节点
# 或在代码中动态创建：

var npc_scene = preload("res://scenes/characters/npc.tscn")
var new_npc = npc_scene.instantiate()
new_npc.npc_id = "npc_004"
new_npc.npc_name = "David"
new_npc.personality = "mysterious and thoughtful"
new_npc.role = "scholar"
new_npc.position = Vector3(10, 1, 5)
$NPCs.add_child(new_npc)
```

### 配置AI参数

编辑 `assets/ai_config.json`：

```json
{
  "providers": {
    "your_provider": {
      "base_url": "https://api.example.com/v1",
      "default_model": "model-name",
      "temperature": 0.7
    }
  }
}
```

### 添加新的摄像机模式

1. 创建脚本继承 Camera3D：
```gdscript
extends Camera3D
class_name MyCustomCameraController

@export var target: Node3D

func _process(delta):
    if target:
        # 你的摄像机逻辑
        pass
```

2. 在 CameraManager 中注册：
```gdscript
enum CameraMode {
    # ... 现有模式
    CUSTOM
}

func switch_mode(mode: CameraMode, target: Node3D = null):
    # ... 现有代码
    CameraMode.CUSTOM:
        current_camera = _create_custom_camera(target)

func _create_custom_camera(target: Node3D) -> Camera3D:
    var camera = Camera3D.new()
    camera.set_script(load("res://scripts/utils/my_custom_camera_controller.gd"))
    camera.target = target
    return camera
```

## 🔧 调试技巧

### 常用命令

```gdscript
# 打印当前状态
print(GameManager.current_state)
print(CameraManager.current_mode)

# 强制切换摄像机
CameraManager.switch_mode(CameraManager.CameraMode.FREE)

# 测试AI响应
AIManager.set_api_key("your_key")
AIManager.send_message("npc_001", "Hello", {"name": "Test"})

# 查看NPC历史
print(AIManager.get_history("npc_001"))
```

### 性能优化

1. **帧率控制**
   - 在 `project.godot` 中调整 `max_fps`
   - 录制时降低分辨率

2. **AI请求优化**
   - 使用 `max_tokens` 限制响应长度
   - 实现请求队列避免并发过高

3. **内存管理**
   - 录制缓冲区满了自动保存
   - 对话历史定期清理

## 📱 导出配置

### Android 导出

在 `project.godot` 中添加：

```ini
[display]
window/handheld/orientation=landscape

[rendering]
renderer/rendering_method="mobile"
```

导出预设配置：
- Package: Unique Name
- Version: Code + Name
- Permissions: Internet (AI API)

### 桌面导出

- Windows: 包含所有DLL
- Linux: 单文件模式
- macOS: 签名配置

## 🐛 常见问题

### Q: AI 没有响应？
A: 检查：
1. 环境变量 `MOONSHOT_API_KEY` 是否设置
2. 网络连接是否正常
3. API额度是否充足

### Q: 摄像机切换后黑屏？
A: 确保：
1. 新摄像机已添加到场景
2. `make_current()` 已调用
3. 摄像机位置设置正确

### Q: 录制文件在哪里？
A: 默认路径：`user://recordings/`
- Windows: `%APPDATA%\Godot\app_userdata\[project_name]\recordings\`
- Linux: `~/.local/share/godot/app_userdata/[project_name]/recordings/`

## 📝 版本历史

### v0.1.0 (2024-03-16)
- ✨ 初始版本
- ✨ 基础AI NPC系统
- ✨ 5种摄像机模式
- ✨ 录制功能框架
- ✨ 对话UI系统

---

持续更新中...
