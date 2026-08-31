import SwiftUI

struct VisualizationSettingsView: View {
    @ObservedObject var model: VisualizationSettingsModel
    let onRestoreDefaults: () -> Void

    private func bind<T>(_ keyPath: WritableKeyPath<VisualizationSettings, T>) -> Binding<T> {
        Binding(
            get: { model.settings[keyPath: keyPath] },
            set: { newValue in
                var settings = model.settings
                settings[keyPath: keyPath] = newValue
                model.update(settings)
            }
        )
    }

    var body: some View {
        Form {
            Section("可视化") {
                MenuPicker(
                    title: "样式",
                    selection: bind(\.style),
                    options: VisualizationStyle.allCases.map { ($0, $0.title) }
                )

                MenuPicker(
                    title: "频段",
                    selection: bind(\.bandPreset),
                    options: BandPreset.allCases.map { ($0, $0.title) },
                    disabled: model.settings.style == .waveform
                )

                if model.settings.style == .waveform {
                    Text("频段设置仅影响频谱样式。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("动态响应") {
                MenuPicker(
                    title: "预设",
                    selection: bind(\.motionResponsePreset),
                    options: MotionResponsePreset.allCases.map { ($0, $0.title) }
                )
            }

            Section("节拍脉冲") {
                MenuPicker(
                    title: "强度",
                    selection: bind(\.beatPulseIntensity),
                    options: BeatPulseIntensity.allCases.map { ($0, $0.title) }
                )
            }

            Section("场景自适应") {
                Toggle("根据音频调整动态", isOn: bind(\.sceneAdaptationEnabled))
            }

            Section("渲染频率") {
                MenuPicker(
                    title: "刷新率",
                    selection: bind(\.renderingCadence),
                    options: RenderingCadence.allCases.map { ($0, $0.title) }
                )
            }

            Section {
                Button("恢复默认设置", role: .destructive) {
                    onRestoreDefaults()
                }
            }
        }
        .padding()
        .frame(width: 360)
    }
}

private struct MenuPicker<Option: Hashable>: View {
    let title: String
    @Binding var selection: Option
    let options: [(option: Option, title: String)]
    var disabled = false

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(options, id: \.option) { option in
                Text(option.title).tag(option.option)
            }
        }
        .pickerStyle(.menu)
        .disabled(disabled)
    }
}
