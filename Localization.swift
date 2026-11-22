import SwiftUI
import Combine

/// App 支持的界面语言。
enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case system
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"
    case japanese = "ja"
    case vietnamese = "vi"
    case korean = "ko"
    case tibetan = "bo"
    case uyghur = "ug"
    case yi = "ii"
    case spanish = "es"

    var id: String { rawValue }

    /// 语言菜单里显示的名称，使用该语言自身的写法。
    var displayName: String {
        switch self {
        case .system: return ""
        case .simplifiedChinese: return "简体中文"
        case .traditionalChinese: return "繁體中文"
        case .english: return "English"
        case .japanese: return "日本語"
        case .vietnamese: return "Tiếng Việt"
        case .korean: return "한국어"
        case .tibetan: return "བོད་ཡིག"
        case .uyghur: return "ئۇيغۇرچە"
        case .yi: return "ꆈꌠꉙ"
        case .spanish: return "Español"
        }
    }

    var localeIdentifier: String {
        self == .system ? Locale.current.identifier : rawValue
    }

    /// 维吾尔文使用从右到左排版。
    var isRightToLeft: Bool {
        self == .uyghur
    }
}

/// 管理界面语言：持久化选择、解析系统语言、提供布局方向与翻译。
final class LocalizationManager: ObservableObject {
    static let storageKey = "MarkPad.interfaceLanguage"

    @Published var selection: AppLanguage {
        didSet {
            UserDefaults.standard.set(selection.rawValue, forKey: Self.storageKey)
            resolved = Self.resolve(selection)
        }
    }

    @Published private(set) var resolved: AppLanguage

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppLanguage.system.rawValue
        let choice = AppLanguage(rawValue: stored) ?? .system
        selection = choice
        resolved = Self.resolve(choice)
    }

    var locale: Locale {
        Locale(identifier: resolved.localeIdentifier)
    }

    var layoutDirection: LayoutDirection {
        resolved.isRightToLeft ? .rightToLeft : .leftToRight
    }

    /// 取当前语言的文案，`arguments` 用于填充 `%d` 之类的占位符。
    func text(_ key: L10nKey, _ arguments: CVarArg...) -> String {
        let template = resolved.string(for: key)
        guard !arguments.isEmpty else { return template }
        return String(format: template, locale: locale, arguments: arguments)
    }

    private static func resolve(_ choice: AppLanguage) -> AppLanguage {
        guard choice == .system else { return choice }

        for identifier in Locale.preferredLanguages {
            let tag = identifier.lowercased()
            if tag.hasPrefix("zh-hant") || tag.hasPrefix("zh-tw") || tag.hasPrefix("zh-hk") || tag.hasPrefix("zh-mo") {
                return .traditionalChinese
            }
            if tag.hasPrefix("zh") { return .simplifiedChinese }
            if tag.hasPrefix("en") { return .english }
            if tag.hasPrefix("ja") { return .japanese }
            if tag.hasPrefix("vi") { return .vietnamese }
            if tag.hasPrefix("ko") { return .korean }
            if tag.hasPrefix("bo") { return .tibetan }
            if tag.hasPrefix("ug") { return .uyghur }
            if tag.hasPrefix("ii") { return .yi }
            if tag.hasPrefix("es") { return .spanish }
        }

        return .english
    }
}
