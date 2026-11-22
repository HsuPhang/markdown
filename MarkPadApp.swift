import SwiftUI

@main
struct MarkPadApp: App {
    @StateObject private var localization = LocalizationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localization)
                .environment(\.layoutDirection, localization.layoutDirection)
                .environment(\.locale, localization.locale)
        }
    }
}
