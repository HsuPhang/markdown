import SwiftUI
import UIKit

struct MarkdownTextView: UIViewRepresentable {
    @ObservedObject var state: EditorState
    var layoutDirection: LayoutDirection = .leftToRight

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        view.textColor = .label
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .interactive
        view.autocorrectionType = .no
        view.autocapitalizationType = .sentences
        view.smartQuotesType = .no
        view.smartDashesType = .no
        view.smartInsertDeleteType = .no
        view.textContainerInset = UIEdgeInsets(top: 16, left: 8, bottom: 80, right: 8)
        view.text = state.text
        // 切换编辑/预览模式会重建 UITextView，这里恢复光标，避免回到开头。
        let length = (state.text as NSString).length
        let location = min(max(0, state.selection.location), length)
        let caretLength = min(max(0, state.selection.length), length - location)
        view.selectedRange = NSRange(location: location, length: caretLength)
        applyLayoutDirection(layoutDirection, to: view)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        applyLayoutDirection(layoutDirection, to: view)
        // 输入法正在组词时不要整体替换文本，否则会把 marked text 清掉。
        if view.text != state.text, view.markedTextRange == nil {
            view.text = state.text
        }
        if let pending = state.pendingSelection {
            state.pendingSelection = nil
            let length = (view.text as NSString).length
            if pending.location <= length {
                let safeLength = min(pending.length, length - pending.location)
                view.selectedRange = NSRange(location: pending.location, length: safeLength)
            }
        }
    }

    /// 维吾尔文需要从右到左排版，UITextView 不会自动继承 SwiftUI 的布局方向。
    private func applyLayoutDirection(_ direction: LayoutDirection, to view: UITextView) {
        let attribute: UISemanticContentAttribute = direction == .rightToLeft ? .forceRightToLeft : .unspecified
        if view.semanticContentAttribute != attribute {
            view.semanticContentAttribute = attribute
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var state: EditorState

        init(state: EditorState) {
            self.state = state
        }

        func textViewDidChange(_ textView: UITextView) {
            state.text = textView.text
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            state.selection = textView.selectedRange
        }
    }
}
