# 从原型到产品：一次 macOS 菜单栏应用的 Agent 工程实践

SoundViz 的起点很简单：在 macOS 菜单栏里实时展示系统声音。它看起来像一个小玩具，但真正做下去后会发现，它牵涉 Core Audio、实时音频回调、FFT 分析、菜单栏渲染、系统权限、能耗控制、错误恢复和多语言界面。这个项目最终变成了一次完整的 Agent 工程实践：人类负责产品方向与关键决策，Agent 负责探索代码、起草规格、拆分任务、测试实现、审查代码，并持续维护工程上下文。

这篇文章记录整个过程，以及我们从中学到的 Agent 协作方法。

## 一、不要让 Agent 直接“开始写代码”

最初的功能目标很明确，但如果直接对 Agent 说“帮我做一个菜单栏音频可视化工具”，很容易得到一个能跑但缺乏边界的原型。

所以我们先使用了一个更工程化的流程：**grill**，也就是让 Agent 反过来追问人类。

Agent 不是立刻写代码，而是持续提出问题：

- 目标用户是谁？
- 这个工具是个人原型，还是要做成开源产品？
- 可视化应该低干扰，还是强调律动感？
- 设置项应该放在菜单里，还是独立窗口？
- 是否允许引入系统音量参数？
- 音频是否可以落盘？
- 如何处理权限失败？

这些问题看起来琐碎，但每一个都直接影响架构。比如“不使用系统音量参数”这个约束，最终让实现从“音量表”转向“频谱内容驱动”的可视化。又如“音频只在内存中处理，不录制、不上传”，成为后续所有采集和错误处理的隐私边界。

最终我们形成了几条核心决策：

1. 使用 Core Audio Process Tap，而不是 ScreenCaptureKit。
2. 不使用屏幕录制权限，因此不会出现紫色屏幕捕获指示器。
3. 可视化只来自频谱内容，不来自系统音量。
4. 音频只在内存中处理，不录制、不保存、不上传。
5. 应用是低干扰的菜单栏工具，而不是音乐播放器附属 UI。

这些决策后来被写入 `CONTEXT.md` 和 ADR，成为后续 Agent 工作的共同上下文。

## 二、把模糊想法变成规格和任务

需求访谈之后，Agent 并没有马上实现所有功能，而是先生成规格。

我们把功能拆成几个主题：

- Band Preset：8 / 12 / 16 / 24 个频段。
- Motion Response：Snappy、Balanced、Smooth 三种动态响应。
- Beat Pulse Intensity：Off / Low / Normal / High。
- Scene Adaptation：根据音频活跃度自动切换低干扰和增强状态。
- Rendering Cadence：30 fps、60 fps，以及在低功耗或安静场景下降到 15 fps。
- Capture State Recovery：权限失败、运行失败、停止状态和恢复动作。
- Localization：英文和简体中文。

每一项都写清楚用户故事、验收标准、测试方式和 out-of-scope。这个阶段最大的价值不是文档本身，而是把“我想要更酷的可视化”这种模糊表达，翻译成可以被测试和验收的工程任务。

例如，Beat Pulse Intensity 不再只是一个感觉，而是被定义成：

- Off 必须保留底层频谱形态；
- Low / Normal / High 有明确强度排序；
- 变更必须立即生效并持久化；
- 测试不能依赖真实音乐；
- 所有三种可视化样式都要响应这个设置。

这种写法让后续实现可以直接走 TDD。

## 三、本地 Markdown tracker：让 Agent 有明确的工作面

这个项目没有使用 GitHub Issues，而是选择了本地 Markdown tracker。所有任务放在：

```text
.scratch/adaptive-visualization-settings/
├── spec.md
└── issues/
    ├── 01-visualization-settings-model-and-persistence.md
    ├── 02-swiftui-settings-window.md
    ├── 03-band-preset-end-to-end.md
    ├── ...
```

每张 ticket 都有：

- What to build
- Blocked by
- Acceptance criteria
- Status
- Answer

这种方式非常适合单人或小团队项目。它不要求额外平台，也不需要 issue 编号、label 和网络同步。Agent 每次开工前可以读取完整上下文；任务完成后又能把结果写回本地文件。

更重要的是，这些 ticket 不是简单的 TODO，而是 **tracer bullet**：每个任务都要切出一条完整的垂直路径，从设置模型到 UI，再到渲染或分析，最后到测试。

## 四、从设置模型开始，而不是从 UI 开始

实现顺序上，我们避免了一上来就写漂亮界面，而是先建立 `VisualizationSettings`。

它包含：

```swift
var style: VisualizationStyle
var bandPreset: BandPreset
var motionResponsePreset: MotionResponsePreset
var beatPulseIntensity: BeatPulseIntensity
var sceneAdaptationEnabled: Bool
var renderingCadence: RenderingCadence
```

同时提供一个可注入的持久化 store。这样测试时可以使用隔离的 `UserDefaults`，不会污染真实配置。

这一步看似枯燥，但它让后面的每个功能都有统一入口。无论用户是从 SwiftUI 设置窗口修改，还是从菜单栏 Quick Controls 修改，最终都会进入同一个 settings model，再广播到 visualizer 和 capture controller。

Agent 后续实现 Band Preset、Motion Response、Beat Pulse Intensity 时，也都能沿着这条既有链路扩展，而不是每次另起炉灶。

## 五、真实音频采集：从 ScreenCaptureKit 到 Core Audio Process Tap

最初使用 `ScreenCaptureKit` 获取系统声音时，很快遇到一个系统级问题：macOS 会在菜单栏显示紫色屏幕捕获指示器。对一个只读声音的可视化工具来说，这个提示会让用户误以为屏幕正在被录屏。

于是方案切换到 Core Audio Process Tap。

新的架构是：

```text
Core Audio Process Tap
        ↓
SystemAudioCaptureController
        ↓
SpectrumAnalyzer（FFT / bands / onset）
        ↓
AudioVisualizer（style rendering）
        ↓
NSStatusItem
```

这个选择有几个好处：

- 不触发屏幕录制权限；
- 不显示紫色捕获指示器；
- 可以直接读取系统输出音频；
- 能以私有 aggregate device 形式运行。

但它也带来了新问题：macOS 14.2+ 的 Core Audio Tap API、音频格式查询、IOProc 回调、聚合设备生命周期管理，以及权限失败分类。

这也体现了 Agent 工程实践中的一个现实：换掉一个“有副作用的方案”后，复杂度不会消失，只会转移到更需要设计的位置。

## 六、音频回调里不要做 UI，也不要做临时分配

实时音频路径是整个项目最容易出问题的区域。

早期有过一个明显教训：在音频回调附近做过多处理，或者把数据处理和 UI 更新耦合得不够清晰。后来我们确立了规则：

1. 音频回调只负责采样转换和 SpectrumAnalyzer 分析。
2. 分析结果通过 `SpectrumFrame` 传给渲染器。
3. 渲染器内部再调度到主线程。
4. AppKit 渲染和状态项更新必须在主线程。
5. 音频回调里避免锁、日志、UI 和不必要的分配。

最终形成了类似的结构：

```swift
AudioDeviceCreateIOProcIDWithBlock(...) { ... }
    ↓
process(inputData:timestamp:)
    ↓
SpectrumAnalyzer.process(...)
    ↓
onSpectrum(SpectrumFrame)
```

`AudioVisualizer.push` 再把结果送到主线程渲染。这让实时路径保持清晰，也让 UI 层可以专注于表现。

## 七、可视化不是“音量表”

用户明确要求不要让可视化依赖系统音量。这个决策很关键。

如果只是把 RMS 音量画成柱状图，副歌时会很容易从左到右全部拉满，视觉上缺乏结构。于是实现逐步演进为：

1. FFT 分成 8 / 12 / 16 / 24 个对数频段；
2. 每个频段独立自适应归一化；
3. 频谱柱、波形线、频谱带各自渲染；
4. 低频 spectral flux 生成 Beat Pulse；
5. Scene Adapter 根据音频活跃度切换 Low-distraction Baseline 和 Active Enhancement；
6. Reduce Motion 时抑制脉冲，但不隐藏可视化。

也就是说，可视化的输入不是“声音有多大”，而是“声音的结构和节奏发生了什么变化”。

这也是这个项目从 demo 感走向产品感的关键。

## 八、测试可观测行为，而不是测试私有实现

项目使用了 XCTest，但测试重点不是把私有变量都暴露出来，而是围绕稳定 seam：

- `SpectrumAnalyzer.process` 验证频段数量、有限性和稳定性；
- `AudioVisualizer` 验证样式、频段数量、Motion Response、Beat Pulse Intensity、Scene Adaptation；
- `CaptureControlling` 验证状态迁移和恢复；
- `CaptureFailure` 验证权限错误与运行时错误分类；
- 设置持久化使用注入的 `UserDefaults`，不污染真实系统配置。

比如 Beat Pulse Intensity 的测试并不是播放真实音乐，而是构造合成 `SpectrumFrame`：

```swift
SpectrumFrame(
    bands: [Float](repeating: 0.8, count: 12),
    beat: 1,
    waveform: [Float](repeating: 0.25, count: 32)
)
```

然后验证 Off / Low / Normal / High 渲染出来的脉冲强度是否符合排序，并且底层可视化形态仍然保留。

这让 Agent 可以在没有真实音乐、没有 AirPods、没有 QQ 音乐运行的情况下验证逻辑。

## 九、Capture State Recovery 是产品化的重要一步

原型阶段，如果采集失败，菜单栏可能只是显示一句技术错误。但产品化要求更明确：

- Starting
- Running
- Stopped
- Permission Required
- Capture Failure

每种状态都要有清晰的菜单文案。

权限失败时，用户应该能打开系统设置并重试；运行失败时，用户应该知道失败原因并手动 Retry；停止时，菜单栏应该显示一个低幅静态基线，而不是继续保留最后一帧动态画面。

实现中引入了 `CaptureFailure`：

```swift
enum CaptureFailureKind {
    case permissionRequired
    case runtime
}
```

并把 Core Audio 状态转换为可操作的 UI 状态。这样 Agent 的实现不再是“能启动就启动”，而是完整地考虑了失败、恢复和用户沟通。

## 十、Agent 的双重代码审查很有价值

每个 ticket 完成后，我们不是马上认为结束，而是做了两类审查：

1. **Standards Review**：是否符合项目规范、命名、结构、线程规则、README 更新要求。
2. **Spec Review**：是否真的实现了 ticket 中承诺的行为，有没有遗漏、过度实现或看起来错误的逻辑。

这类审查经常发现真实问题。例如：

- 高频段数量会导致菜单栏图标溢出；
- Waveform 在低干扰状态下没有正确降低 prominence；
- 禁用 Scene Adaptation 后状态不应被强制切到 Active；
- 渲染 cadence 未变化时不应反复重建 timer；
- 权限失败可能被误报成普通 runtime failure；
- stopped 后迟到的 spectrum frame 应该被丢弃。

这些都不是靠“看一眼代码”就能稳定发现的。双轴审查让 Agent 不仅检查“代码好不好看”，也检查“代码有没有实现承诺”。

## 十一、本地化：不是最后翻译字符串那么简单

多语言看起来只是加几个字符串，但实际会牵涉：

- 菜单项；
- SwiftUI 设置表单；
- 状态消息；
- 恢复动作；
- Core Audio 错误描述；
- 权限说明；
- Info.plist 本地化；
- 语言 fallback 规则。

我们最终建立了集中式 `AppText`，并根据系统首选语言选择英文或简体中文。系统语言是简体中文时使用中文，其他情况 fallback 到英文。没有应用内语言切换器。

这个设计保持简单，也符合系统习惯。

同时，我们手动检查了英文和简体中文设置窗口截图，确认两种语言都能正确显示。本地化不是把中文换成英文，而是让同一套领域概念在两种语言中都表达清晰。

## 十二、结果

经过这一轮流程，SoundViz 从最初的菜单栏原型成长为具备产品边界的 macOS 工具：

- 支持 Core Audio Process Tap 系统音频采集；
- 不触发屏幕录制权限和紫色指示器；
- 提供三种可视化样式；
- 支持可选 8 / 12 / 16 / 24 频段；
- 提供 Beat Pulse Intensity 和 Motion Response 预设；
- 具备 Scene Adaptation 和 Reduce Motion 支持；
- 支持标准 / 高刷新率渲染和自动功耗限制；
- 提供完整捕获状态与恢复 UX；
- 支持英文和简体中文界面；
- 拥有测试、CI、图标、打包脚本和双语文档。

## 十三、关于 Agent 实践的几点总结

这个项目最大的启发不是“Agent 能写代码”，而是：

**Agent 更适合嵌入工程流程，而不是绕过工程流程。**

当 Agent 被要求直接生成功能时，它可能很快产出一个原型。但当 Agent 被置于需求访谈、领域建模、规格生成、任务拆分、测试驱动、代码审查和持续文档维护中时，它更像一个可以协作的工程师。

这个项目里的关键实践是：

1. **人类负责边界和取舍**。例如隐私边界、是否使用系统音量、产品定位、低干扰体验。
2. **Agent 负责事实调查和实现细节**。例如 API 结构、SDK 常量、测试组织、状态迁移。
3. **领域语言必须持续沉淀**。`CONTEXT.md` 统一了 System Audio、Frequency Band、Beat Pulse、Low-distraction Baseline 等概念。
4. **规格先行降低返工**。大量 UI 和 DSP 细节都能追溯到 ticket。
5. **本地 issue tracker 保持上下文连续**。Agent 不需要反复从聊天记录里猜任务。
6. **测试和审查不是形式**。它们捕捉到了真实的功能溢出、状态错误和本地化缺口。
7. **失败路径也是产品**。权限失败、运行失败、停止状态都需要设计。

## 结语

SoundViz 本身仍然是一个相对小型的 macOS 应用，但它的开发过程完整展示了一种 Agent 驱动的软件工程方式：

> 人类提出目标和约束，Agent 参与梳理、实现、验证和维护；每一步都留下可读的工程上下文。

这比“AI 一句话生成 App”慢，但结果是可持续的。后续无论是新增可视化样式、优化性能，还是开始分发签名版本，项目都有清晰的规格、测试、决策记录和任务历史可以继续依赖。

这也许才是 Agent 辅助开发真正有价值的地方：不是让代码突然出现，而是让工程过程变得可重复、可审查、可延续。
