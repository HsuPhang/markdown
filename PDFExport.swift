import SwiftUI
import UIKit

@MainActor
enum PDFExport {
    static func makePDF(text: String, title: String, layoutDirection: LayoutDirection = .leftToRight) -> URL? {
        let width: CGFloat = 595

        // ImageRenderer 不会渲染 WKWebView，导出 PDF 时公式退化为 TeX 源码。
        let content = MarkdownBlocksView(blocks: MarkdownParser.blocks(from: text), mathRendering: .plain)
            .padding(.horizontal, 40)
            .padding(.vertical, 48)
            .frame(width: width, alignment: .leading)
            .background(Color.white)
            .environment(\.layoutDirection, layoutDirection)
            .environment(\.colorScheme, .light)

        let imageRenderer = ImageRenderer(content: content)
        imageRenderer.scale = 2
        imageRenderer.isOpaque = true

        guard let cgImage = imageRenderer.cgImage else { return nil }

        let pixelWidth = CGFloat(cgImage.width)
        let pixelsPerPoint = pixelWidth / width
        let contentHeight = CGFloat(cgImage.height) / pixelsPerPoint
        let pageHeight = width * 1.414
        let pageCount = max(1, Int(ceil(contentHeight / pageHeight)))

        let fileName = sanitized(title) + ".pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let bounds = CGRect(x: 0, y: 0, width: width, height: pageHeight)

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: bounds)

        do {
            try pdfRenderer.writePDF(to: url) { context in
                let image = UIImage(cgImage: cgImage)
                for page in 0..<pageCount {
                    context.beginPage()
                    let offset = CGFloat(page) * pageHeight
                    image.draw(in: CGRect(x: 0, y: -offset, width: width, height: contentHeight))
                }
            }
            return url
        } catch {
            return nil
        }
    }

    static func sanitized(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:")
        let parts = name.components(separatedBy: invalid).filter { !$0.isEmpty }
        let joined = parts.joined(separator: "-").trimmingCharacters(in: .whitespaces)
        return joined.isEmpty ? "Markdown" : joined
    }
}
