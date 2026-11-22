import SwiftUI
import WebKit

/// 公式的渲染方式：预览里用 MathJax 真正排版，导出 PDF 时退化为 TeX 源码。
enum MathRendering {
    case rendered
    case plain
}

/// 把 Markdown 行内文本转成 HTML，并保留公式交给 MathJax 处理。
enum MathHTMLBuilder {
    /// 文本里是否含有行内公式。
    static func containsMath(_ text: String) -> Bool {
        if text.contains("\\(") { return true }
        // 要求 $ 后紧跟内容、结尾 $ 前不是空白，避免把价格之类的 "$5 到 $10" 误判成公式。
        return text.range(of: #"\$(?!\s)[^$\n]+?(?<!\s)\$"#, options: .regularExpression) != nil
    }

    static func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    /// 行内 Markdown -> HTML。公式先用占位符抽出来，避免被加粗/斜体规则改坏。
    static func inlineHTML(_ markdown: String) -> String {
        var text = markdown
        var formulas: [String] = []

        let pattern = #"\$\$[^$\n]+?\$\$|\$(?!\s)[^$\n]+?(?<!\s)\$|\\\(.+?\\\)"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let ns = text as NSString
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: ns.length))
            for match in matches.reversed() {
                let snippet = ns.substring(with: match.range)
                let token = "\u{1F}M\(formulas.count)\u{1F}"
                formulas.append(snippet)
                text = (text as NSString).replacingCharacters(in: match.range, with: token)
            }
        }

        var html = escape(text)
        html = replacing(#"\*\*(.+?)\*\*"#, with: "<strong>$1</strong>", in: html)
        html = replacing(#"~~(.+?)~~"#, with: "<del>$1</del>", in: html)
        html = replacing(#"`([^`\n]+)`"#, with: "<code>$1</code>", in: html)
        html = replacing(#"(?<!\*)\*([^*\n]+)\*(?!\*)"#, with: "<em>$1</em>", in: html)
        html = replacing(#"\[([^\]\n]+)\]\((https?://[^)\s]+)\)"#, with: #"<a href="$2">$1</a>"#, in: html)

        for (index, formula) in formulas.enumerated() {
            html = html.replacingOccurrences(of: "\u{1F}M\(index)\u{1F}", with: escape(formula))
        }
        return html
    }

    /// 生成给 WKWebView 的完整 HTML 文档。
    static func document(
        body: String,
        fontSize: CGFloat,
        bold: Bool,
        secondary: Bool,
        dark: Bool,
        alignment: String = "start",
        direction: String = "ltr"
    ) -> String {
        let textColor = secondary
            ? (dark ? "#98989D" : "#6C6C70")
            : (dark ? "#FFFFFF" : "#000000")
        let linkColor = dark ? "#6CB4FF" : "#0A84FF"
        let codeBackground = dark ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.06)"
        let weight = bold ? "600" : "400"

        return #"""
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
        html, body { margin: 0; padding: 0; background: transparent; }
        body {
            color: \#(textColor);
            font-family: -apple-system, "SF Pro Text", "Helvetica Neue", sans-serif;
            font-size: \#(fontSize)px;
            font-weight: \#(weight);
            line-height: 1.45;
            text-align: \#(alignment);
            overflow-wrap: break-word;
        }
        p { margin: 0; }
        code {
            font-family: ui-monospace, "SF Mono", Menlo, monospace;
            background: \#(codeBackground);
            padding: 1px 4px;
            border-radius: 4px;
            font-size: 0.92em;
        }
        a { color: \#(linkColor); text-decoration: none; }
        mjx-container { max-width: 100%; overflow-x: auto; overflow-y: hidden; color: \#(textColor) !important; }
        mjx-container[display="true"] { margin: 0.2em auto !important; }
        </style>
        <script>
        window.MathJax = {
            tex: {
                inlineMath: [['$', '$'], ['\\(', '\\)']],
                displayMath: [['$$', '$$'], ['\\[', '\\]']],
                processEscapes: true
            },
            svg: { fontCache: 'global' },
            options: { enableMenu: false }
        };
        </script>
        <script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"></script>
        </head>
        <body dir="\#(direction)">\#(body)
        <script>
        function postSize() {
            var h = Math.ceil(document.body.getBoundingClientRect().height);
            if (h > 0 && window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.size) {
                window.webkit.messageHandlers.size.postMessage(h);
            }
        }
        function typesetThenMeasure() {
            if (window.MathJax && MathJax.startup && MathJax.startup.promise) {
                MathJax.startup.promise.then(postSize).catch(postSize);
            } else {
                postSize();
            }
        }
        window.addEventListener('load', function () {
            typesetThenMeasure();
            setTimeout(postSize, 300);
            setTimeout(postSize, 1500);
        });
        try { new ResizeObserver(postSize).observe(document.body); } catch (e) {}
        </script>
        </body>
        </html>
        """#
    }

    private static func replacing(_ pattern: String, with template: String, in text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(location: 0, length: (text as NSString).length)
        return regex.stringByReplacingMatches(in: text, range: range, withTemplate: template)
    }
}

/// 自适应高度的网页视图：渲染 MathJax，并把内容高度回传给 SwiftUI。
struct MathHTMLView: View {
    let html: String
    var estimatedHeight: CGFloat = 40

    @State private var measuredHeight: CGFloat = 0

    var body: some View {
        MathWebView(html: html, measuredHeight: $measuredHeight)
            .frame(height: measuredHeight > 0 ? measuredHeight : estimatedHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 一段带行内公式的行内 Markdown 文本。
struct MathRichText: View {
    let markdown: String
    var fontSize: CGFloat = 17
    var bold: Bool = false
    var secondary: Bool = false
    var strikethrough: Bool = false
    var estimatedHeight: CGFloat = 26

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        let inline = MathHTMLBuilder.inlineHTML(markdown)
        return MathHTMLView(
            html: MathHTMLBuilder.document(
                body: strikethrough ? "<del>\(inline)</del>" : inline,
                fontSize: fontSize,
                bold: bold,
                secondary: secondary,
                dark: colorScheme == .dark,
                direction: layoutDirection == .rightToLeft ? "rtl" : "ltr"
            ),
            estimatedHeight: estimatedHeight
        )
    }
}

/// 独立成行的公式块（`$$ ... $$` 或 `\[ ... \]`）。
struct MathFormulaBlock: View {
    let tex: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        MathHTMLView(
            html: MathHTMLBuilder.document(
                body: "\\[" + MathHTMLBuilder.escape(tex) + "\\]",
                fontSize: 18,
                bold: false,
                secondary: false,
                dark: colorScheme == .dark,
                alignment: "center"
            ),
            estimatedHeight: 72
        )
    }
}

struct MathWebView: UIViewRepresentable {
    let html: String
    @Binding var measuredHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(measuredHeight: $measuredHeight)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "size")

        let view = WKWebView(frame: .zero, configuration: configuration)
        view.isOpaque = false
        view.backgroundColor = .clear
        view.underPageBackgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        view.scrollView.isScrollEnabled = false
        view.scrollView.bounces = false
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.isUserInteractionEnabled = false

        context.coordinator.loadedHTML = html
        context.coordinator.webView = view
        view.loadHTMLString(html, baseURL: nil)
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        guard context.coordinator.loadedHTML != html else { return }
        context.coordinator.loadedHTML = html
        view.loadHTMLString(html, baseURL: nil)
    }

    static func dismantleUIView(_ view: WKWebView, coordinator: Coordinator) {
        view.configuration.userContentController.removeScriptMessageHandler(forName: "size")
        view.stopLoading()
        view.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        @Binding var measuredHeight: CGFloat
        var loadedHTML: String?
        weak var webView: WKWebView?

        init(measuredHeight: Binding<CGFloat>) {
            _measuredHeight = measuredHeight
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "size", let number = message.body as? NSNumber else { return }
            let height = CGFloat(truncating: number)
            guard height > 0 else { return }
            guard abs(height - measuredHeight) > 0.5 else { return }
            DispatchQueue.main.async {
                self.measuredHeight = height
            }
        }
    }
}
