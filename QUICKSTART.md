# 🚀 快速启动指南

## 1. 环境准备

### 安装 Godot 4.2+
```bash
# 下载地址: https://godotengine.org/download
# 或使用命令行
wget https://github.com/godotengine/godot/releases/download/4.2.2-stable/Godot_v4.2.2-stable_linux.x86_64.zip
unzip Godot_v4.2.2-stable_linux.x86_64.zip
chmod +x Godot_v4.2.2-stable_linux.x86_64
sudo mv Godot_v4.2.2-stable_linux.x86_64 /usr/local/bin/godot
```

### 配置 AI API 密钥
```bash
# Linux/macOS
export MOONSHOT_API_KEY="your_api_key_here"

# Windows
set MOONSHOT_API_KEY=your_api_key_here
```

获取 API Key: https://platform.moonshot.cn/

## 2. 打开项目

1. 启动 Godot
2. 点击 "Import"
3. 选择 `godot-ai-world/project.godot`
4. 点击 "Import & Edit"

## 3. 运行项目

### 在编辑器中运行
- 按 `F5` 或点击右上角的播放按钮

### 导出为可执行文件
1. 项目 → 导出
2. 添加预设（Windows/Linux/macOS/Android）
3. 点击 "导出项目"

## 4. 操作指南

### 基础控制
| 按键 | 功能 |
|------|------|
| `WASD` | 移动 |
| `Space` | 跳跃 |
| `Mouse` | 视角控制 |
| `E` | 与NPC交互/关闭对话 |
| `T` | 切换摄像机模式 |
| `R` | 开始/停止录制 |

### 摄像机模式
1. **自由视角** - WASD自由飞行
2. **跟随视角** - 跟随玩家
3. **环绕视角** - 360度环绕观察
4. **第一人称** - 沉浸式视角
5. **电影运镜** - 自动播放预设路径

### 与NPC对话
1. 靠近NPC（3米内）
2. 按 `E` 开始对话
3. 输入消息
4. 等待AI回复
5. 按 `E` 关闭对话

## 5. 项目结构速览

```
godot-ai-world/
├── project.godot          # 项目配置
├── scenes/
│   └── main.tscn         # 主场景
├── scripts/
│   ├── managers/         # 管理器（AI/摄像机/UI等）
│   ├── entities/         # 实体（玩家）
│   ├── npc/              # NPC系统
│   └── utils/            # 摄像机控制器
└── docs/
    └── DEVELOPMENT.md    # 开发文档
```

## 6. 自定义配置

### 修改NPC性格
编辑 `scripts/npc/npc.gd` 中的默认参数：
```gdscript
@export var personality: String = "your custom personality"
@export var role: String = "your custom role"
```

### 添加新NPC
1. 在 `scenes/main.tscn` 中复制一个NPC节点
2. 修改 `npc_id`, `npc_name`, `personality`
3. 调整位置

### 修改AI模型
编辑 `project.godot`：
```ini
[ai]
api/base_url="https://api.openai.com/v1"
api/model="gpt-3.5-turbo"
```

## 7. 故障排除

### 场景加载失败
- 检查所有 `.gd` 脚本路径是否正确
- 重新导入项目

### AI无响应
- 检查API key是否设置
- 检查网络连接
- 查看输出面板错误信息

### 摄像机问题
- 确保场景中只有一个激活的Camera3D
- 检查CameraManager是否正确初始化

## 8. 下一步

- 📖 阅读 `docs/DEVELOPMENT.md` 了解架构
- 🎨 添加更多3D模型和材质
- 🤖 扩展NPC行为树
- 📹 完善录制功能

---

Enjoy your AI Simulation World! 🎮✨
