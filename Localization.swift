import SwiftUI
import Combine

/// App 支持的界面语言。
enum AppLanguage: String, CaseIterable, Identifiable, Codable {
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

    /// 显示该语言自身的写法。
    var displayName: String {
        switch self {
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

    var localeIdentifier: String { rawValue }

    /// 维吾尔文使用从右到左排版。
    var isRightToLeft: Bool {
        self == .uyghur
    }
}

/// 管理界面语言：读取系统为 App 选择的「首选语言」，提供布局方向与翻译。
final class LocalizationManager: ObservableObject {
    @Published private(set) var resolved: AppLanguage

    init() {
        resolved = Self.detect()
    }

    /// 从系统设置返回时重新解析一次；切换首选语言后系统会重启 App。
    func syncFromSystemSettings() {
        let detected = Self.detect()
        guard detected != resolved else { return }
        resolved = detected
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

    /// 菜单构建时读取当前语言；原生首选语言只在重启 App 后生效。
    static var currentLanguage: AppLanguage {
        detect()
    }

    /// 优先读取 App 的本地化顺序（受系统「首选语言」影响），再回退到系统语言列表。
    private static func detect() -> AppLanguage {
        for identifier in Bundle.main.preferredLocalizations {
            if let language = match(identifier) { return language }
        }
        for identifier in Locale.preferredLanguages {
            if let language = match(identifier) { return language }
        }
        return .english
    }

    private static func match(_ identifier: String) -> AppLanguage? {
        let tag = identifier.lowercased()
        if tag.hasPrefix("zh-hant") || tag.hasPrefix("zh-tw") || tag.hasPrefix("zh-hk") || tag.hasPrefix("zh-mo") {
            return .traditionalChinese
        }
        if tag.hasPrefix("zh") { return .simplifiedChinese }

        for language in AppLanguage.allCases {
            let code = language.rawValue.lowercased()
            if tag == code || tag.hasPrefix(code + "-") || tag.hasPrefix(code + "_") {
                return language
            }
        }
        return nil
    }
}
