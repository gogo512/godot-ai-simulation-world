# 🎮 AI Simulation World - Godot 4

一个基于 Godot 4 的 3D AI 驱动模拟世界，具有智能 NPC、多视角录制功能。

## ✨ 功能特性

### 🧠 AI NPC 系统
- 每个 NPC 都有独特的性格、角色和记忆
- 与大模型 API 集成（默认 Moonshot/Kimi）
- 自然语言对话，NPC 会记住对话历史
- 情感状态和动态行为

### 📹 多视角录制系统
- **自由视角**：WASD 自由飞行观察
- **跟随视角**：平滑跟随角色或 NPC
- **环绕视角**：360度环绕观察
- **第一人称**：沉浸式角色视角
- **电影运镜**：预设运镜路径自动播放
- 按 `T` 键切换视角模式
- 按 `R` 键开始/停止录制

### 🎮 交互系统
- `WASD` - 移动
- `Space` - 跳跃
- `Mouse` - 视角控制
- `E` - 与 NPC 交互/关闭对话
- `T` - 切换摄像机模式
- `R` - 开始/停止录制

## 📁 项目结构

```
godot-ai-world/
├── assets/              # 资源文件
│   ├── models/         # 3D模型
│   ├── materials/      # 材质
│   └── sounds/         # 音效
├── scenes/             # 场景文件
│   ├── main.tscn       # 主场景
│   ├── characters/     # 角色场景
│   ├── world/          # 世界场景
│   └── ui/             # UI场景
├── scripts/            # 脚本
│   ├── managers/       # 管理器
│   ├── entities/       # 实体
│   ├── npc/            # NPC系统
│   ├── world/          # 世界生成
│   └── utils/          # 工具类
└── docs/               # 文档
```

## 🔧 配置

### 1. 设置大模型 API

在运行前设置环境变量：
```bash
export MOONSHOT_API_KEY="your_api_key_here"
```

或在代码中设置：
```gdscript
AIManager.set_api_key("your_api_key_here")
```

### 2. 支持的模型

- **Moonshot AI (Kimi)** - 默认，国内可用
- **OpenAI GPT** - 国际标准
- **本地模型** - Ollama/LM Studio（需修改 API 地址）

## 🚀 运行项目

### 使用 Godot 编辑器
1. 下载并安装 Godot 4.2+
2. 打开项目文件夹
3. 按 F5 运行

### 导出为 Android
1. 安装 Android 导出模板
2. 项目 → 导出 → Android
3. 配置 SDK 和密钥库
4. 导出 APK

## 📖 开发文档

### 核心架构

#### GameManager
- 管理游戏状态（菜单/游戏中/暂停）
- 控制录制状态
- 全局游戏时间

#### AIManager
- 与 LLM API 通信
- 管理 NPC 对话历史
- 构建 AI 上下文

#### CameraManager
- 管理多种摄像机模式
- 平滑切换视角
- 支持自定义运镜

#### UIManager
- 对话框系统
- HUD 显示
- 录制指示器

#### NPC 系统
- 每个 NPC 独立 AI 上下文
- 可配置性格和角色
- 自主移动和交互

### 扩展 NPC

```gdscript
# 在场景中创建新的 NPC
var npc = preload("res://scripts/npc/npc.gd").new()
npc.npc_id = "npc_004"
npc.npc_name = "David"
npc.personality = "mysterious and quiet"
npc.role = "wanderer"
```

### 添加新的摄像机模式

1. 继承 `Camera3D` 创建新的控制器脚本
2. 在 `CameraManager.switch_mode()` 中添加新模式
3. 实现 `_create_your_camera()` 方法

## 📝 开发计划

- [x] 项目骨架搭建
- [x] 核心管理器实现
- [x] AI NPC 系统
- [x] 多视角摄像机系统
- [x] 基础交互系统
- [ ] 视频录制功能
- [ ] 更丰富的世界场景
- [ ] NPC 行为树
- [ ] 物理交互
- [ ] 音效系统
- [ ] 存档系统

## 📜 许可证

MIT License - 可自由使用、修改和分发

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

Made with ❤️ using Godot 4
