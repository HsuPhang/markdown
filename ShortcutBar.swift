import SwiftUI

/// 顶部快捷工具栏：参考 macOS 的菜单分类，把 Markdown 命令收进「格式 / 标题 / 列表 / 插入」四个分类。
struct ShortcutBar: View {
    @ObservedObject var state: EditorState

    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Menu {
                        formatMenu
                    } label: {
                        chip(.formatCategory, systemImage: "textformat")
                    }

                    Menu {
                        headingMenu
                    } label: {
                        chip(.headingsCategory, systemImage: "textformat.size")
                    }

                    Menu {
                        listMenu
                    } label: {
                        chip(.listsCategory, systemImage: "list.bullet")
                    }

                    Menu {
                        insertMenu
                    } label: {
                        chip(.insertCategory, systemImage: "plus.square")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
            }

            Text(localization.text(.characterCount, state.text.count))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.trailing, 12)
                .lineLimit(1)
        }
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    @ViewBuilder
    private var formatMenu: some View {
        Button {
            state.insert(prefix: "**", suffix: "**")
        } label: {
            Label(localization.text(.bold), systemImage: "bold")
        }
        .keyboardShortcut("b", modifiers: .command)

        Button {
            state.insert(prefix: "*", suffix: "*")
        } label: {
            Label(localization.text(.italic), systemImage: "italic")
        }
        .keyboardShortcut("i", modifiers: .command)

        Button {
            state.insert(prefix: "~~", suffix: "~~")
        } label: {
            Label(localization.text(.strikethrough), systemImage: "strikethrough")
        }

        Divider()

        Button {
            state.insert(prefix: "`", suffix: "`")
        } label: {
            Label(localization.text(.inlineCode), systemImage: "chevron.left.forwardslash.chevron.right")
        }

        Button {
            state.insert(prefix: "[\(localization.text(.link))](", suffix: ")")
        } label: {
            Label(localization.text(.link), systemImage: "link")
        }
        .keyboardShortcut("k", modifiers: .command)

        Button {
            state.insert(prefix: "![\(localization.text(.imageAlt))](", suffix: ")")
        } label: {
            Label(localization.text(.image), systemImage: "photo")
        }
    }

    @ViewBuilder
    private var headingMenu: some View {
        ForEach(1...6, id: \.self) { level in
            Button {
                state.applyHeading(level: level)
            } label: {
                Text(localization.text(.headingFormat, level))
            }
            .keyboardShortcut(ShortcutBar.headingKey(level), modifiers: [.command, .option])
        }

        Divider()

        Button {
            state.applyHeading(level: 0)
        } label: {
            Text(localization.text(.bodyText))
        }
    }

    @ViewBuilder
    private var listMenu: some View {
        Button {
            state.insertLinePrefix("- ")
        } label: {
            Label(localization.text(.bulletList), systemImage: "list.bullet")
        }

        Button {
            state.insertLinePrefix("1. ")
        } label: {
            Label(localization.text(.numberedList), systemImage: "list.number")
        }

        Button {
            state.insertLinePrefix("- [ ] ")
        } label: {
            Label(localization.text(.taskList), systemImage: "checkmark.square")
        }

        Divider()

        Button {
            state.insertLinePrefix("> ")
        } label: {
            Label(localization.text(.quote), systemImage: "text.quote")
        }
    }

    @ViewBuilder
    private var insertMenu: some View {
        Button {
            state.insert(prefix: tableSnippet, suffix: "")
        } label: {
            Label(localization.text(.table), systemImage: "tablecells")
        }

        Button {
            state.insert(prefix: "```\n", suffix: "\n```")
        } label: {
            Label(localization.text(.codeBlock), systemImage: "curlybraces")
        }

        Button {
            state.insert(prefix: "\n---\n", suffix: "")
        } label: {
            Label(localization.text(.divider), systemImage: "minus")
        }
    }

    private var tableSnippet: String {
        let first = localization.text(.columnOne)
        let second = localization.text(.columnTwo)
        let content = localization.text(.tableContent)
        return "| \(first) | \(second) |\n| --- | --- |\n| \(content) | \(content) |\n"
    }

    private func chip(_ key: L10nKey, systemImage: String) -> some View {
        Label(localization.text(key), systemImage: systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.12), in: Capsule())
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
