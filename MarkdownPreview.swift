import SwiftUI
import UIKit

struct MDTaskItem {
    let done: Bool
    let text: String
}

enum MDBlock {
    case heading(level: Int, text: String)
    case paragraph(String)
    case quote(String)
    case bullet([String])
    case ordered([String])
    case tasks([MDTaskItem])
    case code(language: String?, text: String)
    case table(header: [String], rows: [[String]])
    case math(String)
    case divider
}

enum MarkdownParser {
    struct Heading {
        let level: Int
        let text: String
    }

    static func blocks(from source: String) -> [MDBlock] {
        let normalized = source.replacingOccurrences(of: "\r\n", with: "\n")
        let lines = normalized.components(separatedBy: "\n")
        var result: [MDBlock] = []
        var i = 0

        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespaces)
            if line.isEmpty {
                i += 1
                continue
            }

            if line.hasPrefix("```") {
                let language = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                var body: [String] = []
                i += 1
                while i < lines.count {
                    if lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        i += 1
                        break
                    }
                    body.append(lines[i])
                    i += 1
                }
                result.append(.code(language: language.isEmpty ? nil : language, text: body.joined(separator: "\n")))
                continue
            }

            // 块级公式：$$ ... $$ 或 \[ ... \]，允许跨行。
            if line.hasPrefix("$$") {
                let rest = String(line.dropFirst(2))
                var body: [String] = []
                if let closing = rest.range(of: "$$") {
                    body.append(String(rest[..<closing.lowerBound]))
                    i += 1
                } else {
                    if !rest.isEmpty { body.append(rest) }
                    i += 1
                    while i < lines.count {
                        if let closing = lines[i].range(of: "$$") {
                            body.append(String(lines[i][..<closing.lowerBound]))
                            i += 1
                            break
                        }
                        body.append(lines[i])
                        i += 1
                    }
                }
                result.append(.math(body.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)))
                continue
            }

            if line.hasPrefix("\\[") {
                let rest = String(line.dropFirst(2))
                var body: [String] = []
                if let closing = rest.range(of: "\\]") {
                    body.append(String(rest[..<closing.lowerBound]))
                    i += 1
                } else {
                    if !rest.isEmpty { body.append(rest) }
                    i += 1
                    while i < lines.count {
                        if let closing = lines[i].range(of: "\\]") {
                            body.append(String(lines[i][..<closing.lowerBound]))
                            i += 1
                            break
                        }
                        body.append(lines[i])
                        i += 1
                    }
                }
                result.append(.math(body.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)))
                continue
            }

            if let detected = heading(line) {
                result.append(.heading(level: detected.level, text: detected.text))
                i += 1
                continue
            }

            if line == "---" || line == "***" || line == "___" {
                result.append(.divider)
                i += 1
                continue
            }

            if line.hasPrefix(">") {
                var buffer: [String] = []
                while i < lines.count, lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                    let stripped = String(lines[i].trimmingCharacters(in: .whitespaces).dropFirst())
                    buffer.append(stripped.trimmingCharacters(in: .whitespaces))
                    i += 1
                }
                result.append(.quote(buffer.joined(separator: "\n")))
                continue
            }

            if let header = tableHeader(in: lines, at: i) {
                var rows: [[String]] = []
                i += 2
                while i < lines.count {
                    let candidate = lines[i].trimmingCharacters(in: .whitespaces)
                    if candidate.isEmpty || !candidate.contains("|") { break }
                    rows.append(splitRow(candidate))
                    i += 1
                }
                result.append(.table(header: header, rows: rows))
                continue
            }

            if taskItem(line) != nil {
                var items: [MDTaskItem] = []
                while i < lines.count, let item = taskItem(lines[i].trimmingCharacters(in: .whitespaces)) {
                    items.append(item)
                    i += 1
                }
                result.append(.tasks(items))
                continue
            }

            if bulletBody(line) != nil {
                var items: [String] = []
                while i < lines.count, let body = bulletBody(lines[i].trimmingCharacters(in: .whitespaces)) {
                    items.append(body)
                    i += 1
                }
                result.append(.bullet(items))
                continue
            }

            if orderedBody(line) != nil {
                var items: [String] = []
                while i < lines.count, let body = orderedBody(lines[i].trimmingCharacters(in: .whitespaces)) {
                    items.append(body)
                    i += 1
                }
                result.append(.ordered(items))
                continue
            }

            var paragraph: [String] = []
            while i < lines.count {
                let candidate = lines[i].trimmingCharacters(in: .whitespaces)
                if candidate.isEmpty { break }
                if startsNewBlock(candidate) { break }
                // 表格可以紧跟在段落后面，不需要空行。
                if tableHeader(in: lines, at: i) != nil { break }
                paragraph.append(candidate)
                i += 1
            }

            if paragraph.isEmpty {
                paragraph.append(line)
                i += 1
            }
            result.append(.paragraph(paragraph.joined(separator: " ")))
        }

        return result
    }

    private static func startsNewBlock(_ line: String) -> Bool {
        if line.hasPrefix("```") { return true }
        if line.hasPrefix("$$") { return true }
        if line.hasPrefix("\\[") { return true }
        if heading(line) != nil { return true }
        if line.hasPrefix(">") { return true }
        if line == "---" || line == "***" || line == "___" { return true }
        if bulletBody(line) != nil { return true }
        if orderedBody(line) != nil { return true }
        return false
    }

    private static func heading(_ line: String) -> Heading? {
        var count = 0
        var rest = Substring(line)
        while rest.first == "#", count < 6 {
            count += 1
            rest = rest.dropFirst()
        }
        guard count > 0 else { return nil }
        guard rest.isEmpty || rest.first == " " else { return nil }
        let text = rest.trimmingCharacters(in: .whitespaces)
        return Heading(level: count, text: text)
    }

    private static func bulletBody(_ line: String) -> String? {
        for marker in ["- ", "* ", "+ "] {
            if line.hasPrefix(marker) {
                return String(line.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
            }
        }
        return nil
    }

    private static func taskItem(_ line: String) -> MDTaskItem? {
        guard let body = bulletBody(line) else { return nil }
        let lower = body.lowercased()
        if lower.hasPrefix("[ ]") {
            return MDTaskItem(done: false, text: String(body.dropFirst(3)).trimmingCharacters(in: .whitespaces))
        }
        if lower.hasPrefix("[x]") {
            return MDTaskItem(done: true, text: String(body.dropFirst(3)).trimmingCharacters(in: .whitespaces))
        }
        return nil
    }

    private static func orderedBody(_ line: String) -> String? {
        var index = line.startIndex
        var digits = 0
        while index < line.endIndex, line[index].isNumber, digits < 4 {
            digits += 1
            index = line.index(after: index)
        }
        guard digits > 0, index < line.endIndex else { return nil }
        guard line[index] == "." || line[index] == ")" else { return nil }
        let afterMarker = line.index(after: index)
        guard afterMarker < line.endIndex, line[afterMarker] == " " else { return nil }
        return String(line[line.index(after: afterMarker)...]).trimmingCharacters(in: .whitespaces)
    }

    /// 判断某个位置是否是表格（表头 + 分隔行），并返回表头单元格。
    private static func tableHeader(in lines: [String], at index: Int) -> [String]? {
        guard index + 1 < lines.count, lines[index].contains("|") else { return nil }
        let header = splitRow(lines[index])
        guard isTableSeparator(lines[index + 1], expectedColumns: header.count) else { return nil }
        return header
    }

    private static func isTableSeparator(_ line: String, expectedColumns: Int) -> Bool {
        let cells = splitRow(line)
        guard !cells.isEmpty, cells.count == expectedColumns else { return false }
        return cells.allSatisfy { cell in
            var body = cell
            while body.hasPrefix(":") { body.removeFirst() }
            while body.hasSuffix(":") { body.removeLast() }
            return body.count >= 3 && body.allSatisfy { $0 == "-" }
        }
    }

    private static func splitRow(_ line: String) -> [String] {
        var text = line.trimmingCharacters(in: .whitespaces)
        if text.hasPrefix("|") { text.removeFirst() }
        if text.hasSuffix("|") { text.removeLast() }
        return text.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

enum Markdown {
    static func inline(_ string: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible
        )
        if let attributed = try? AttributedString(markdown: string, options: options) {
            return attributed
        }
        return AttributedString(string)
    }

    static func headingSize(_ level: Int) -> CGFloat {
        switch level {
        case 1: return 28
        case 2: return 23
        case 3: return 19
        case 4: return 17
        default: return 15
        }
    }
}

struct MarkdownBlocksView: View {
    let blocks: [MDBlock]
    var mathRendering: MathRendering = .rendered

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(blocks.indices, id: \.self) { index in
                blockView(blocks[index])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 有公式时交给 MathJax 排版，没有公式时用原生 Text，保证性能和原有样式。
    @ViewBuilder
    private func inlineText(
        _ text: String,
        fontSize: CGFloat,
        weight: Font.Weight,
        bold: Bool = false,
        secondary: Bool = false,
        strikethrough: Bool = false,
        estimatedHeight: CGFloat
    ) -> some View {
        if mathRendering == .rendered, MathHTMLBuilder.containsMath(text) {
            MathRichText(
                markdown: text,
                fontSize: fontSize,
                bold: bold,
                secondary: secondary,
                strikethrough: strikethrough,
                estimatedHeight: estimatedHeight
            )
        } else {
            Text(Markdown.inline(text))
                .font(.system(size: fontSize, weight: weight))
                .strikethrough(strikethrough)
                .foregroundStyle(secondary ? Color.secondary : Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func blockView(_ block: MDBlock) -> some View {
        switch block {
        case .heading(let level, let text):
            inlineText(
                text,
                fontSize: Markdown.headingSize(level),
                weight: level <= 2 ? .bold : .semibold,
                bold: level <= 2,
                estimatedHeight: Markdown.headingSize(level) * 1.7
            )
            .padding(.top, level == 1 ? 8 : 2)

        case .paragraph(let text):
            inlineText(text, fontSize: 17, weight: .regular, estimatedHeight: 24)

        case .quote(let text):
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor.opacity(0.5))
                    .frame(width: 3)
                inlineText(text, fontSize: 16, weight: .regular, secondary: true, estimatedHeight: 22)
            }

        case .tasks(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: items[index].done ? "checkmark.square.fill" : "square")
                            .foregroundStyle(items[index].done ? Color.accentColor : Color.secondary)
                        inlineText(
                            items[index].text,
                            fontSize: 17,
                            weight: .regular,
                            secondary: items[index].done,
                            strikethrough: items[index].done,
                            estimatedHeight: 24
                        )
                    }
                }
            }
            .padding(.leading, 4)

        case .bullet(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•").font(.body)
                        inlineText(items[index], fontSize: 17, weight: .regular, estimatedHeight: 24)
                    }
                }
            }
            .padding(.leading, 4)

        case .ordered(let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(items.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.body.monospacedDigit())
                            .foregroundStyle(.secondary)
                        inlineText(items[index], fontSize: 17, weight: .regular, estimatedHeight: 24)
                    }
                }
            }
            .padding(.leading, 4)

        case .code(let language, let text):
            VStack(alignment: .leading, spacing: 6) {
                if let language {
                    Text(language)
                        .font(.caption.smallCaps())
                        .foregroundStyle(.secondary)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(text.isEmpty ? " " : text)
                        .font(.system(.callout, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(10)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))

        case .table(let header, let rows):
            ScrollView(.horizontal, showsIndicators: false) {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        ForEach(header.indices, id: \.self) { index in
                            Text(Markdown.inline(header[index]))
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    Divider()
                    ForEach(rows.indices, id: \.self) { rowIndex in
                        GridRow {
                            ForEach(header.indices, id: \.self) { columnIndex in
                                Text(Markdown.inline(cellText(rows[rowIndex], columnIndex)))
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(10)
            }
            .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))

        case .math(let tex):
            if mathRendering == .plain {
                Text(tex)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            } else {
                MathFormulaBlock(tex: tex)
            }

        case .divider:
            Divider()
                .padding(.vertical, 2)
        }
    }

    private func cellText(_ row: [String], _ index: Int) -> String {
        index < row.count ? row[index] : ""
    }
}

struct MarkdownPreview: View {
    let text: String

    var body: some View {
        ScrollView {
            MarkdownBlocksView(blocks: MarkdownParser.blocks(from: text))
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
        }
        .background(Color(uiColor: .systemBackground))
    }
}
