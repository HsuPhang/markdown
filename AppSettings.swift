import SwiftUI
import UIKit

/// App 的外观模式。
enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var titleKey: L10nKey {
        switch self {
        case .system: return .followSystem
        case .light: return .lightMode
        case .dark: return .darkMode
        }
    }
}

/// 应用级设置：菜单与设置面板共用同一份 UserDefaults。
enum AppSettings {
    static let appearanceKey = "MarkPad.appearance"
    static let spellCheckKey = "MarkPad.spellCheck"
}

/// 应用内设置面板，由 ⌘, 打开。
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager

    @AppStorage(AppSettings.appearanceKey) private var appearanceRaw = AppAppearance.system.rawValue
    @AppStorage(AppSettings.spellCheckKey) private var spellCheckEnabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section(localization.text(.interfaceLanguage)) {
                    Button {
                        openSystemSettings()
                    } label: {
                        HStack {
                            Text(localization.text(.preferredLanguage))
                            Spacer()
                            Text(localization.resolved.displayName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section(localization.text(.appearance)) {
                    Picker(localization.text(.appearance), selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(localization.text(appearance.titleKey)).tag(appearance.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(localization.text(.editorSettings)) {
                    Toggle(localization.text(.spellCheck), isOn: $spellCheckEnabled)
                }
            }
            .navigationTitle(localization.text(.settings))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.text(.done)) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
