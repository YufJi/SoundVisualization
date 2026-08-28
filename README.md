# SoundViz

原生 macOS 菜单栏音频可视化工具。SoundViz 使用 Core Audio Process Tap 读取系统输出音频，在本地进行 FFT 分析，并渲染实时频谱和节奏脉冲。音频数据只在内存中处理，不会录制、保存、上传或播放。

## 功能

- 柱状频谱、波形线、频谱带三种可视化样式。
- 12 段对数频谱，逐频段自适应归一化。
- 低频 spectral flux 节拍脉冲。
- 独立 30 fps 渲染时钟。
- 样式选择自动保存。
- 菜单栏状态、启动/停止和退出控制。

## 构建与运行

```bash
./build-app.sh
open build/SoundViz.app
```

也可以使用 Makefile：

```bash
make run
```

## 开发

```bash
swift test          # 运行测试
make build          # 构建并打包 app bundle
make verify         # 测试、打包并校验 bundle
make clean          # 清理构建产物
```

CI 使用 GitHub Actions 的 `macos-15` runner 执行测试、打包和 bundle 校验。

## 权限

SoundViz 不使用屏幕录制权限，因此不会显示紫色屏幕捕获指示器。它要求 macOS 14.2 或更高版本，并需要授权 SoundViz 读取系统音频；该授权可能显示在“系统设置 → 隐私与安全性 → 麦克风/音频捕获”下。

## 可视化样式

| 样式 | 说明 |
| --- | --- |
| 柱状频谱 | 12 段对数频谱柱，低频在左、高频在右。 |
| 波形线 | 时间域波形曲线，经去直流和滚动峰值归一化。 |
| 频谱带 | 平滑频谱区域，低频节拍会带动边缘脉冲。 |

样式可在菜单栏的“可视化样式”中切换，选择会自动保存。

## 架构

```text
Core Audio Process Tap
        ↓
SystemAudioCaptureController
        ↓
SpectrumAnalyzer（FFT / 频段 / onset）
        ↓
AudioVisualizer（样式渲染）
        ↓
NSStatusItem
```

主要源码位于 `Sources/SoundViz`。

## 打包与签名

默认使用 ad-hoc 签名，适合本机原型验证：

```bash
./build-app.sh
```

如需使用 Developer ID 签名：

```bash
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)" ./build-app.sh
```

分发到其他 Mac 前仍需要公证；当前仓库未包含公证流程。

## 当前行为

- 启动后自动开始监听。
- 菜单栏显示 12 段频谱或时间域波形。
- 可视化样式支持柱状频谱、波形线和频谱带，选择会自动保存。
- 菜单提供启动/停止、权限状态和退出。
- 应用本身不录制、保存或播放音频。

## 已知原型限制

- 依赖 macOS 14.2+ 与 Core Audio Process Tap。
- 未做 Developer ID 签名和公证。
- Core Audio Tap 的系统授权行为可能随 macOS 版本变化。
- 未包含沙盒、Developer ID 公证和 Sparkle 自动更新。
