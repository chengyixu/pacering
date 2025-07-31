# Pacering

<a href="https://tinylaun.ch" target="_blank" rel="noopener">
    <img src="https://tinylaun.ch/tinylaunch_badge_launching_soon.svg" alt="TinyLaunch Badge" style="width:202px; height:auto;" />
</a>

A macOS productivity tracking application that monitors your work time and helps you achieve your daily goals.

[中文版本](#中文)

## Features

- **Automatic Time Tracking**: Monitors active applications and tracks time spent
- **Work Apps Selection**: Choose which applications count towards your work time
- **Daily Goals**: Set and track daily work hour targets
- **Visual Progress**: Clean progress circle visualization showing daily achievement
- **History View**: Review your productivity patterns over the past 30 days
- **AI Analysis**: Get intelligent insights about your productivity patterns powered by GLM-4
- **Achievements System**: Unlock achievements and track milestones across 5 categories
  - Productivity achievements (First Hour, Workday Warrior, Productivity Master)
  - Consistency achievements (Week Streak, Monthly Commitment)
  - Exploration achievements (App Explorer, Multitasker)
  - Milestone achievements (Early Bird, Night Owl)
  - Special achievements (Perfect Balance, Goal Crusher)
- **Dark Mode Support**: Full dark mode support with automatic theme switching
- **Performance Optimized**: Smooth performance with debounced updates and intelligent caching
- **Bilingual Support**: Full support for English and Chinese languages
- **Auto-start Support**: Can be configured to start automatically with macOS
- **Privacy-focused**: All data stored locally on your device

## What's New

### Latest Updates
- **Dark Mode Support**: The app now fully supports macOS dark mode with automatic theme switching
- **Performance Improvements**: 
  - Implemented intelligent caching for window titles (30-second cache)
  - Added debounced updates to reduce UI refresh frequency
  - Optimized data persistence with debounced UserDefaults saves
  - Limited resource-intensive operations to browser applications only
- **Enhanced UI**: Semantic colors that adapt to system appearance preferences

## Screenshots

### Main Interface
- Today view: Hourly breakdown of application usage
- Progress circle showing daily goal achievement
- Historical data visualization
- AI Analysis with markdown formatting
- Achievements tracking with progress indicators

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later (for building from source)

## Installation

### Option 1: Build from Source

1. Clone the repository:
```bash
git clone https://github.com/chengyixu/pacering.git
cd pacering
```

2. Open in Xcode:
```bash
open pacering.xcodeproj
```

3. Build and run (Cmd+R)

### Option 2: Download Release

Download the latest release from the [Releases](https://github.com/chengyixu/pacering/releases) page.

## Usage

1. **First Launch**: Grant accessibility permissions when prompted
2. **Set Work Apps**: Navigate to "Work Apps" and select applications that count as work
3. **Set Daily Goal**: In Profile view, set your target work hours
4. **Track Progress**: The app will automatically track time spent in work applications
5. **View AI Analysis**: Click "Generate Analysis" in AI Analysis tab for insights
6. **Check Achievements**: Monitor your progress and unlock achievements in the Achievements tab

## Privacy & Permissions

Pacering requires accessibility permissions to monitor active applications. All data is stored locally using UserDefaults. No data is sent to external servers.

## Development

### Architecture

- Built with SwiftUI and Combine
- Uses NSWorkspace for application monitoring
- Persistent storage via UserDefaults
- Timer-based monitoring with configurable intervals

### Building

```bash
# Build
xcodebuild -project pacering.xcodeproj -scheme pacering build

# Run tests
xcodebuild -project pacering.xcodeproj -scheme pacering test
```

## License

[Add your license information here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<a name="中文"></a>

# Pacering

一款 macOS 生产力追踪应用，监控您的工作时间并帮助您实现每日目标。

## 功能特点

- **自动时间追踪**：监控活跃应用程序并记录使用时间
- **工作应用选择**：选择哪些应用程序计入您的工作时间
- **每日目标**：设定并追踪每日工作小时目标
- **可视化进度**：清晰的进度圆环显示每日完成度
- **历史记录**：查看过去 30 天的生产力模式
- **AI 分析**：通过 GLM-4 获取关于您工作效率模式的智能洞察
- **成就系统**：解锁成就并跟踪 5 个类别的里程碑
  - 生产力成就（第一小时、工作日战士、生产力大师）
  - 一致性成就（周连续、月度承诺）
  - 探索成就（应用探索者、多任务处理者）
  - 里程碑成就（早起鸟、夜猫子）
  - 特殊成就（完美平衡、目标粉碎者）
- **深色模式支持**：完整的深色模式支持，自动跟随系统主题切换
- **性能优化**：通过防抖更新和智能缓存实现流畅的性能表现
- **双语支持**：完整支持英文和中文界面
- **开机自启支持**：可配置随 macOS 自动启动
- **隐私优先**：所有数据本地存储在您的设备上

## 最新更新

### 最近更新内容
- **深色模式支持**：应用现已完全支持 macOS 深色模式，自动跟随系统主题切换
- **性能改进**：
  - 实现了窗口标题的智能缓存（30秒缓存）
  - 添加了防抖更新以减少 UI 刷新频率
  - 通过防抖 UserDefaults 保存优化了数据持久化
  - 将资源密集型操作限制在浏览器应用程序中
- **界面增强**：采用语义化颜色，自动适应系统外观偏好

## 截图

### 主界面
- 今日视图：应用使用时间的小时分解
- 进度圆环显示每日目标完成情况
- 历史数据可视化
- AI 分析支持 Markdown 格式
- 成就追踪带进度指示器

## 系统要求

- macOS 13.0 或更高版本
- Xcode 14.0 或更高版本（用于从源码构建）

## 安装

### 方式一：从源码构建

1. 克隆仓库：
```bash
git clone https://github.com/chengyixu/pacering.git
cd pacering
```

2. 在 Xcode 中打开：
```bash
open pacering.xcodeproj
```

3. 构建并运行（Cmd+R）

### 方式二：下载发布版本

从 [Releases](https://github.com/chengyixu/pacering/releases) 页面下载最新版本。

## 使用方法

1. **首次启动**：在提示时授予辅助功能权限
2. **设置工作应用**：进入"工作应用"页面，选择计为工作的应用程序
3. **设定每日目标**：在个人资料视图中，设置您的目标工作小时数
4. **追踪进度**：应用将自动追踪在工作应用程序中花费的时间
5. **查看 AI 分析**：在 AI 分析标签页点击"生成分析"获取洞察
6. **查看成就**：在成就标签页监控您的进度并解锁成就

## 隐私与权限

Pacering 需要辅助功能权限来监控活跃的应用程序。所有数据使用 UserDefaults 本地存储。不会向外部服务器发送任何数据。

## 开发

### 架构

- 使用 SwiftUI 和 Combine 构建
- 使用 NSWorkspace 进行应用程序监控
- 通过 UserDefaults 实现持久化存储
- 基于定时器的监控，可配置监控间隔

### 构建

```bash
# 构建
xcodebuild -project pacering.xcodeproj -scheme pacering build

# 运行测试
xcodebuild -project pacering.xcodeproj -scheme pacering test
```

## 许可证

[在此添加您的许可证信息]

## 贡献

欢迎贡献！请随时提交 Pull Request。