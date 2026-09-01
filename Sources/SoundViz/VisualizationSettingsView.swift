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
            Section(AppText.visualizationSection.localized) {
                MenuPicker(
                    title: AppText.styleLabel.localized,
                    selection: bind(\.style),
                    options: VisualizationStyle.allCases.map { ($0, $0.title) }
                )

                MenuPicker(
                    title: AppText.frequencyBandsLabel.localized,
                    selection: bind(\.bandPreset),
                    options: BandPreset.allCases.map { ($0, $0.title) },
                    disabled: model.settings.style == .waveform
                )

                if model.settings.style == .waveform {
                    Text(AppText.frequencyBandsHelp.localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(AppText.motionResponseSection.localized) {
                MenuPicker(
                    title: AppText.presetLabel.localized,
                    selection: bind(\.motionResponsePreset),
                    options: MotionResponsePreset.allCases.map { ($0, $0.title) }
                )
            }

            Section(AppText.beatPulseSection.localized) {
                MenuPicker(
                    title: AppText.intensityLabel.localized,
                    selection: bind(\.beatPulseIntensity),
                    options: BeatPulseIntensity.allCases.map { ($0, $0.title) }
                )
            }

            Section(AppText.sceneAdaptationSection.localized) {
                Toggle(AppText.audioAdaptiveMotionToggle.localized, isOn: bind(\.sceneAdaptationEnabled))
            }

            Section(AppText.renderingFrequencySection.localized) {
                MenuPicker(
                    title: AppText.refreshRateLabel.localized,
                    selection: bind(\.renderingCadence),
                    options: RenderingCadence.allCases.map { ($0, $0.title) }
                )
            }

            Section {
                Button(AppText.restoreDefaults.localized, role: .destructive) {
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
