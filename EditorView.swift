import SwiftUI
import UIKit

enum EditorMode: String, CaseIterable, Identifiable {
    case edit
    case split
    case preview

    var id: String { rawValue }

    var titleKey: L10nKey {
        switch self {
        case .edit: return .editMode
        case .split: return .splitMode
        case .preview: return .previewMode
        }
    }
}

struct ExportItems: Identifiable {
    let id = UUID()
    let markdown: URL
    let pdf: URL?
}

struct EditorView: View {
    let store: DocumentStore
    let document: MDDocument

    @StateObject private var state = EditorState()
    @State private var mode: EditorMode = .split
    @State private var didSetInitialMode = false
    @State private var exportItems: ExportItems?
    @State private var saveTask: Task<Void, Never>?
    @State private var loadedDocument: MDDocument?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 0) {
            if showsEditor {
                ShortcutBar(state: state)
            }
            content
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task(id: document) {
            loadDocument()
        }
        .onChange(of: state.text) { _, newValue in
            scheduleSave(newValue)
        }
        .onChange(of: horizontalSizeClass) { _, newValue in
            if newValue == .compact, mode == .split {
                mode = .edit
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                saveNow()
            }
        }
        .onDisappear {
            saveNow()
        }
        .sheet(item: $exportItems) { items in
            ExportSheet(items: items)
        }
    }

    private var showsEditor: Bool {
        mode != .preview
    }

    @ViewBuilder
    private var content: some View {
        if mode == .split && horizontalSizeClass == .regular {
            HStack(spacing: 0) {
                editorPane
                Divider()
                MarkdownPreview(text: state.text)
            }
        } else if mode == .preview {
            MarkdownPreview(text: state.text)
        } else {
            editorPane
        }
    }

    private var editorPane: some View {
        MarkdownTextView(state: state, layoutDirection: localization.layoutDirection)
            .background(Color(uiColor: .secondarySystemBackground))
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker(localization.text(.viewMode), selection: $mode) {
                ForEach(availableModes) { item in
                    Text(localization.text(item.titleKey)).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(minWidth: 200, maxWidth: 360)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                exportAll()
            } label: {
                Label(localization.text(.export), systemImage: "square.and.arrow.up")
            }
        }
    }

    private var availableModes: [EditorMode] {
        if horizontalSizeClass == .regular {
            return EditorMode.allCases
        }
        return [.edit, .preview]
    }

    private func exportAll() {
        saveNow()
        let pdf = PDFExport.makePDF(
            text: state.text,
            title: document.title,
            layoutDirection: localization.layoutDirection
        )
        exportItems = ExportItems(markdown: document.url, pdf: pdf)
    }

    private func loadDocument() {
        saveTask?.cancel()
        flushPrevious(unless: document)

        if let content = store.read(document) {
            state.text = content
            loadedDocument = document
        } else {
            state.text = ""
            loadedDocument = nil
        }
        state.resetSelectionToStart()

        if !didSetInitialMode {
            mode = horizontalSizeClass == .regular ? .split : .edit
            didSetInitialMode = true
        }

        store.reload()
    }

    /// 切换文档前，把上一篇未落盘的修改写回它自己的文件。
    private func flushPrevious(unless newDocument: MDDocument) {
        guard let previous = loadedDocument, previous != newDocument else { return }
        guard FileManager.default.fileExists(atPath: previous.url.path) else { return }
        store.write(state.text, to: previous)
    }

    private func scheduleSave(_ text: String) {
        guard loadedDocument == document else { return }
        saveTask?.cancel()
        let targetDocument = document
        let targetStore = store
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            if Task.isCancelled { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                targetStore.write(text, to: targetDocument)
            }
        }
    }

    private func saveNow() {
        saveTask?.cancel()
        guard let loadedDocument else { return }
        store.write(state.text, to: loadedDocument)
    }
}

struct ExportSheet: View {
    let items: ExportItems

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.tint)

                VStack(spacing: 4) {
                    Text(items.markdown.lastPathComponent)
                        .font(.headline)
                    Text(localization.text(items.pdf != nil ? .pdfReady : .pdfFailed))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    ShareLink(item: items.markdown) {
                        Label(localization.text(.shareMarkdown), systemImage: "doc.text")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    if let pdf = items.pdf {
                        ShareLink(item: pdf) {
                            Label(localization.text(.sharePDF), systemImage: "doc.richtext")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(28)
            .navigationTitle(localization.text(.export))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.text(.done)) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
