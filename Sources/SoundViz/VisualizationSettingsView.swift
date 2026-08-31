import SwiftUI

struct VisualizationSettingsView: View {
    @Binding var settings: VisualizationSettings
    let onRestoreDefaults: () -> Void

    var body: some View {
        Form {
            Section("可视化") {
                Picker("样式", selection: $settings.style) {
                    ForEach(VisualizationStyle.allCases, id: \.self) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.menu)

                Picker("频段", selection: $settings.bandPreset) {
                    ForEach(BandPreset.allCases, id: \.self) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                .disabled(settings.style == .waveform)

                if settings.style == .waveform {
                    Text("频段设置仅影响频谱样式。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("动态响应") {
                Picker("预设", selection: $settings.motionResponsePreset) {
                    ForEach(MotionResponsePreset.allCases, id: \.self) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("节拍脉冲") {
                Picker("强度", selection: $settings.beatPulseIntensity) {
                    ForEach(BeatPulseIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.title).tag(intensity)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("场景自适应") {
                Toggle("根据音频调整动态", isOn: $settings.sceneAdaptationEnabled)
            }

            Section("渲染频率") {
                Picker("刷新率", selection: $settings.renderingCadence) {
                    ForEach(RenderingCadence.allCases, id: \.self) { cadence in
                        Text(cadence.title).tag(cadence)
                    }
                }
                .pickerStyle(.menu)
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
