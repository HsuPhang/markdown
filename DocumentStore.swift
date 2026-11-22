import Foundation
import Combine

struct MDDocument: Identifiable, Hashable {
    let url: URL

    var id: URL { url }

    var title: String { url.deletingPathExtension().lastPathComponent }

    var modified: Date {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
    }
}

final class DocumentStore: ObservableObject {
    @Published var documents: [MDDocument] = []
    @Published var errorMessage: String?

    private let fm = FileManager.default

    var folderURL: URL {
        let base = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("MarkPad", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func reload() {
        let keys: [URLResourceKey] = [.contentModificationDateKey]
        let items = (try? fm.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles])) ?? []
        documents = items
            .filter { $0.pathExtension.lowercased() == "md" }
            .map { MDDocument(url: $0) }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    func create(name: String, content: String, fallbackName: String) -> MDDocument? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let requested = trimmed.isEmpty ? fallbackName : trimmed
        var base = sanitizedTitle(requested)
        if base.isEmpty { base = sanitizedTitle(fallbackName) }
        if base.isEmpty { base = "Untitled" }

        var url = folderURL.appendingPathComponent(base + ".md")
        var index = 2
        while fm.fileExists(atPath: url.path) {
            url = folderURL.appendingPathComponent("\(base) \(index).md")
            index += 1
        }
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            reload()
            return MDDocument(url: url)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func read(_ document: MDDocument) -> String? {
        do {
            return try String(contentsOf: document.url, encoding: .utf8)
        } catch {
            var encoding = String.Encoding.utf8
            if let text = try? String(contentsOf: document.url, usedEncoding: &encoding) {
                return text
            }
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func write(_ text: String, to document: MDDocument) {
        // 文件可能已被删除或重命名，不能凭内存里的文本把它重新创建出来。
        guard fm.fileExists(atPath: document.url.path) else { return }
        do {
            try text.write(to: document.url, atomically: true, encoding: .utf8)
            Task { @MainActor in reload() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func rename(_ document: MDDocument, to name: String) -> MDDocument? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let base = sanitizedTitle(trimmed)
        guard !base.isEmpty else { return nil }
        guard base != document.title else { return document }

        let target = folderURL.appendingPathComponent(base + ".md")
        guard target != document.url else { return document }
        guard !fm.fileExists(atPath: target.path) else {
            errorMessage = "已存在同名文档"
            return nil
        }

        do {
            try fm.moveItem(at: document.url, to: target)
            reload()
            return MDDocument(url: target)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func delete(_ document: MDDocument) {
        do {
            try fm.removeItem(at: document.url)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 去掉文件名里不能用作路径的字符，避免创建/重命名静默失败。
    private func sanitizedTitle(_ raw: String) -> String {
        var name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.lowercased().hasSuffix(".md") {
            name = String(name.dropLast(3))
        }
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        name = name.components(separatedBy: invalid).joined(separator: "-")
        while name.hasPrefix(".") {
            name.removeFirst()
        }
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
