import Foundation
import Combine

final class EditorState: ObservableObject {
    @Published var text: String = ""
    @Published var selection: NSRange = NSRange(location: 0, length: 0)
    /// 当前视图模式，交给「视图」菜单读写。
    @Published var mode: EditorMode = .edit

    var pendingSelection: NSRange?

    func insert(prefix: String, suffix: String = "") {
        let ns = text as NSString
        let range = clamped(selection)
        let selected = ns.substring(with: range)
        let replacement = prefix + selected + suffix
        let updated = ns.replacingCharacters(in: range, with: replacement)
        text = updated

        let caret = range.location + (prefix as NSString).length
        setSelection(NSRange(location: caret, length: (selected as NSString).length))
    }

    func insertLinePrefix(_ prefix: String) {
        let ns = text as NSString
        let range = clamped(selection)
        var lineStart = range.location
        while lineStart > 0 {
            if ns.character(at: lineStart - 1) == 10 { break }
            lineStart -= 1
        }
        let updated = ns.replacingCharacters(in: NSRange(location: lineStart, length: 0), with: prefix)
        text = updated
        setSelection(NSRange(location: range.location + (prefix as NSString).length, length: range.length))
    }

    /// 把光标所在行设为指定级别的标题，`level` 为 0 时还原为正文。
    func applyHeading(level: Int) {
        let ns = text as NSString
        let range = clamped(selection)

        var lineStart = range.location
        while lineStart > 0, ns.character(at: lineStart - 1) != 10 {
            lineStart -= 1
        }

        var cursor = lineStart
        var existing = 0
        while cursor < ns.length, ns.character(at: cursor) == 35, existing < 6 {
            existing += 1
            cursor += 1
        }

        var removeLength = 0
        if existing > 0 {
            removeLength = existing
            if cursor < ns.length, ns.character(at: cursor) == 32 {
                removeLength += 1
            }
        }

        let prefix = level <= 0 ? "" : String(repeating: "#", count: min(level, 6)) + " "
        let updated = ns.replacingCharacters(in: NSRange(location: lineStart, length: removeLength), with: prefix)
        text = updated

        let contentOffset = max(0, range.location - lineStart - removeLength)
        let caret = lineStart + prefix.utf16.count + contentOffset
        let maxLength = max(0, (updated as NSString).length - caret)
        setSelection(NSRange(location: caret, length: min(range.length, maxLength)))
    }

    func setSelection(_ range: NSRange) {
        selection = range
        pendingSelection = range
    }

    func resetSelectionToStart() {
        pendingSelection = NSRange(location: 0, length: 0)
        selection = NSRange(location: 0, length: 0)
    }

    private func clamped(_ range: NSRange) -> NSRange {
        let length = (text as NSString).length
        let location = min(max(0, range.location), length)
        let maxLength = length - location
        let clampedLength = min(max(0, range.length), maxLength)
        return NSRange(location: location, length: clampedLength)
    }
}
