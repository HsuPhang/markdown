import SwiftUI

@main
struct MarkPadApp: App {
    @StateObject private var localization = LocalizationManager()
    @AppStorage(AppSettings.appearanceKey) private var appearanceRaw = AppAppearance.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localization)
                .environment(\.layoutDirection, localization.layoutDirection)
                .environment(\.locale, localization.locale)
                .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
        }
        // 系统默认菜单由 UIKit/SwiftUI 按 bundle 语言生成，无法跟随 App 内语言，
        // 因此整体替换成完全由本地化表驱动的自定义菜单。
        .commandsReplaced {
            EditorCommands()
        }
    }
}
