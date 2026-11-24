import SwiftUI
import UIKit

/// 把当前编辑器的状态暴露给菜单栏命令。
struct EditorStateFocusedKey: FocusedValueKey {
    typealias Value = EditorState
}

/// 编辑器层面的动作：保存、导出、是否允许分栏。
struct EditorActions {
    var saveDocument: () -> Void
    var exportDocument: () -> Void
    var allowsSplit: Bool
}

struct EditorActionsFocusedKey: FocusedValueKey {
    typealias Value = EditorActions
}

/// 文档列表层面的动作。
struct DocumentActions {
    var newDocument: () -> Void
    var openDocument: () -> Void
    var previousDocument: () -> Void
    var nextDocument: () -> Void
    var renameSelection: () -> Void
    var deleteSelection: () -> Void
    var openSettings: () -> Void
    var hasSelection: Bool
    var hasPreviousDocument: Bool
    var hasNextDocument: Bool
}

struct DocumentActionsFocusedKey: FocusedValueKey {
    typealias Value = DocumentActions
}

extension FocusedValues {
    var editorState: EditorState? {
        get { self[EditorStateFocusedKey.self] }
        set { self[EditorStateFocusedKey.self] = newValue }
    }

    var editorActions: EditorActions? {
        get { self[EditorActionsFocusedKey.self] }
        set { self[EditorActionsFocusedKey.self] = newValue }
    }

    var documentActions: DocumentActions? {
        get { self[DocumentActionsFocusedKey.self] }
        set { self[DocumentActionsFocusedKey.self] = newValue }
    }
}

/// iPadOS 顶部菜单栏里的全部命令，按「文件 / 编辑 / 格式 / 标题 / 列表 / 插入 / 视图 / 设置」分类。
/// 菜单文字跟随「设置 > Mark > 界面语言」。
struct EditorCommands: Commands {
    @FocusedValue(\.editorState) private var state
    @FocusedValue(\.editorActions) private var editorActions
    @FocusedValue(\.documentActions) private var documentActions

    /// 菜单文字跟随系统的「首选语言」，语言变更后重启 App 生效。
    @AppStorage(AppSettings.appearanceKey) private var appearanceRaw = AppAppearance.system.rawValue
    @AppStorage(AppSettings.spellCheckKey) private var spellCheckEnabled = false

    private var language: AppLanguage {
        LocalizationManager.currentLanguage
    }

    private func text(_ key: L10nKey) -> String {
        language.string(for: key)
    }

    var body: some Commands {
        CommandMenu(text(.fileCategory)) { fileMenu }
        CommandMenu(text(.editCategory)) { editMenu }
        CommandMenu(text(.formatCategory)) { formatMenu }
        CommandMenu(text(.headingsCategory)) { headingMenu }
        CommandMenu(text(.listsCategory)) { listMenu }
        CommandMenu(text(.insertCategory)) { insertMenu }
        CommandMenu(text(.viewCategory)) { viewMenu }
        CommandMenu(text(.settings)) { settingsMenu }
    }

    // MARK: - 文件

    @ViewBuilder
    private var fileMenu: some View {
        Button {
            documentActions?.newDocument()
        } label: {
            Text(text(.newDocument))
        }
        .keyboardShortcut("n", modifiers: .command)
        .disabled(documentActions == nil)

        Button {
            documentActions?.openDocument()
        } label: {
            Text(text(.openFile))
        }
        .keyboardShortcut("o", modifiers: .command)
        .disabled(documentActions == nil)

        Button {
            editorActions?.saveDocument()
        } label: {
            Text(text(.save))
        }
        .keyboardShortcut("s", modifiers: .command)
        .disabled(editorActions == nil)

        Divider()

        Button {
            documentActions?.renameSelection()
        } label: {
            Text(text(.rename))
        }
        .keyboardShortcut("r", modifiers: [.command, .shift])
        .disabled(!(documentActions?.hasSelection ?? false))

        Button {
            documentActions?.deleteSelection()
        } label: {
            Text(text(.delete))
        }
        .keyboardShortcut(.delete, modifiers: [.command, .shift])
        .disabled(!(documentActions?.hasSelection ?? false))

        Divider()

        Button {
            editorActions?.exportDocument()
        } label: {
            Text(text(.export))
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])
        .disabled(editorActions == nil)
    }

    // MARK: - 编辑

    @ViewBuilder
    private var editMenu: some View {
        Button {
            perform(NSSelectorFromString("undo:"))
        } label: {
            Text(text(.undo))
        }
        .keyboardShortcut("z", modifiers: .command)
        .disabled(state == nil)

        Button {
            perform(NSSelectorFromString("redo:"))
        } label: {
            Text(text(.redo))
        }
        .keyboardShortcut("z", modifiers: [.command, .shift])
        .disabled(state == nil)

        Divider()

        Button {
            perform(#selector(UIResponderStandardEditActions.cut(_:)))
        } label: {
            Text(text(.cut))
        }
        .keyboardShortcut("x", modifiers: .command)
        .disabled(state == nil)

        Button {
            perform(#selector(UIResponderStandardEditActions.copy(_:)))
        } label: {
            Text(text(.copy))
        }
        .keyboardShortcut("c", modifiers: .command)
        .disabled(state == nil)

        Button {
            perform(#selector(UIResponderStandardEditActions.paste(_:)))
        } label: {
            Text(text(.paste))
        }
        .keyboardShortcut("v", modifiers: .command)
        .disabled(state == nil)

        Button {
            perform(#selector(UIResponderStandardEditActions.selectAll(_:)))
        } label: {
            Text(text(.selectAll))
        }
        .keyboardShortcut("a", modifiers: .command)
        .disabled(state == nil)

        Divider()

        Button {
            perform(#selector(UIResponderStandardEditActions.find(_:)))
        } label: {
            Text(text(.find))
        }
        .keyboardShortcut("f", modifiers: .command)
        .disabled(state == nil)

        Divider()

        Button {
            documentActions?.previousDocument()
        } label: {
            Text(text(.previousDocument))
        }
        .keyboardShortcut(.upArrow, modifiers: [.command, .control])
        .disabled(!(documentActions?.hasPreviousDocument ?? false))

        Button {
            documentActions?.nextDocument()
        } label: {
            Text(text(.nextDocument))
        }
        .keyboardShortcut(.downArrow, modifiers: [.command, .control])
        .disabled(!(documentActions?.hasNextDocument ?? false))
    }

    // MARK: - 格式

    @ViewBuilder
    private var formatMenu: some View {
        Button {
            state?.insert(prefix: "**", suffix: "**")
        } label: {
            Text(text(.bold))
        }
        .keyboardShortcut("b", modifiers: .command)
        .disabled(state == nil)

        Button {
            state?.insert(prefix: "*", suffix: "*")
        } label: {
            Text(text(.italic))
        }
        .keyboardShortcut("i", modifiers: .command)
        .disabled(state == nil)

        Button {
            state?.insert(prefix: "~~", suffix: "~~")
        } label: {
            Text(text(.strikethrough))
        }
        .keyboardShortcut("x", modifiers: [.command, .shift])
        .disabled(state == nil)

        Button {
            state?.insert(prefix: "`", suffix: "`")
        } label: {
            Text(text(.inlineCode))
        }
        .keyboardShortcut("c", modifiers: [.command, .option])
        .disabled(state == nil)

        Divider()

        Button {
            state?.applyHeading(level: 0)
        } label: {
            Text(text(.bodyText))
        }
        .keyboardShortcut("0", modifiers: .command)
        .disabled(state == nil)
    }

    // MARK: - 标题

    @ViewBuilder
    private var headingMenu: some View {
        ForEach(1...6, id: \.self) { level in
            Button {
                state?.applyHeading(level: level)
            } label: {
                Text(String(format: text(.headingFormat), level))
            }
            .keyboardShortcut(EditorCommands.headingKey(level), modifiers: .command)
            .disabled(state == nil)
        }
    }

    // MARK: - 列表

    @ViewBuilder
    private var listMenu: some View {
        Button {
            state?.insertLinePrefix("- ")
        } label: {
            Text(text(.bulletList))
        }
        .keyboardShortcut("7", modifiers: [.command, .shift])
        .disabled(state == nil)

        Button {
            state?.insertLinePrefix("1. ")
        } label: {
            Text(text(.numberedList))
        }
        .keyboardShortcut("8", modifiers: [.command, .shift])
        .disabled(state == nil)

        Button {
            state?.insertLinePrefix("- [ ] ")
        } label: {
            Text(text(.taskList))
        }
        .keyboardShortcut("9", modifiers: [.command, .shift])
        .disabled(state == nil)

        Divider()

        Button {
            state?.insertLinePrefix("> ")
        } label: {
            Text(text(.quote))
        }
        .keyboardShortcut("'", modifiers: .command)
        .disabled(state == nil)
    }

    // MARK: - 插入

    @ViewBuilder
    private var insertMenu: some View {
        Button {
            state?.insert(prefix: "[\(text(.link))](", suffix: ")")
        } label: {
            Text(text(.link))
        }
        .keyboardShortcut("k", modifiers: .command)
        .disabled(state == nil)

        Button {
            state?.insert(prefix: "![\(text(.imageAlt))](", suffix: ")")
        } label: {
            Text(text(.image))
        }
        .keyboardShortcut("i", modifiers: [.command, .shift])
        .disabled(state == nil)

        Button {
            state?.insert(prefix: tableSnippet, suffix: "")
        } label: {
            Text(text(.table))
        }
        .keyboardShortcut("t", modifiers: [.command, .option])
        .disabled(state == nil)

        Button {
            state?.insert(prefix: "```\n", suffix: "\n```")
        } label: {
            Text(text(.codeBlock))
        }
        .keyboardShortcut("c", modifiers: [.command, .shift])
        .disabled(state == nil)

        Divider()

        Button {
            state?.insert(prefix: "$", suffix: "$")
        } label: {
            Text(text(.inlineMath))
        }
        .keyboardShortcut("m", modifiers: [.command, .option])
        .disabled(state == nil)

        Button {
            state?.insert(prefix: "$$\n", suffix: "\n$$")
        } label: {
            Text(text(.blockMath))
        }
        .keyboardShortcut("m", modifiers: [.command, .option, .shift])
        .disabled(state == nil)

        Divider()

        Button {
            state?.insert(prefix: "\n---\n", suffix: "")
        } label: {
            Text(text(.divider))
        }
        .keyboardShortcut("d", modifiers: [.command, .option])
        .disabled(state == nil)
    }

    // MARK: - 视图

    @ViewBuilder
    private var viewMenu: some View {
        Button {
            state?.mode = .edit
        } label: {
            Text(text(.editMode))
        }
        .keyboardShortcut("1", modifiers: [.command, .control])
        .disabled(state == nil)

        Button {
            state?.mode = .split
        } label: {
            Text(text(.splitMode))
        }
        .keyboardShortcut("2", modifiers: [.command, .control])
        .disabled(!(editorActions?.allowsSplit ?? false) || state == nil)

        Button {
            state?.mode = .preview
        } label: {
            Text(text(.previewMode))
        }
        .keyboardShortcut("3", modifiers: [.command, .control])
        .disabled(state == nil)
    }

    // MARK: - 设置

    @ViewBuilder
    private var settingsMenu: some View {
        Button {
            openSystemSettings()
        } label: {
            Text(text(.preferredLanguage))
        }

        Picker(text(.appearance), selection: $appearanceRaw) {
            ForEach(AppAppearance.allCases) { item in
                Text(text(item.titleKey)).tag(item.rawValue)
            }
        }

        Toggle(text(.spellCheck), isOn: $spellCheckEnabled)
            .keyboardShortcut("p", modifiers: [.command, .option])

        Divider()

        Button {
            documentActions?.openSettings()
        } label: {
            Text(text(.settings))
        }
        .keyboardShortcut(",", modifiers: .command)
        .disabled(documentActions == nil)
    }

    // MARK: - 辅助

    private var tableSnippet: String {
        let first = text(.columnOne)
        let second = text(.columnTwo)
        let content = text(.tableContent)
        return "| \(first) | \(second) |\n| --- | --- |\n| \(content) | \(content) |\n"
    }

    /// 通过响应链转发 UIKit 的标准编辑动作（撤销、复制、粘贴等）。
    private func perform(_ selector: Selector) {
        UIApplication.shared.sendAction(selector, to: nil, from: nil, for: nil)
    }

    /// 打开系统的 App 设置页，原生「首选语言」在这里切换。
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private static func headingKey(_ level: Int) -> KeyEquivalent {
        switch level {
        case 1: return "1"
        case 2: return "2"
        case 3: return "3"
        case 4: return "4"
        case 5: return "5"
        default: return "6"
        }
    }
}
