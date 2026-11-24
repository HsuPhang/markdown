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

    var iconName: String {
        switch self {
        case .edit: return "square.and.pencil"
        case .split: return "rectangle.split.2x1"
        case .preview: return "eye"
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
    @State private var didSetInitialMode = false
    @State private var exportItems: ExportItems?
    @State private var saveTask: Task<Void, Never>?
    @State private var loadedDocument: MDDocument?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var localization: LocalizationManager
    @AppStorage(AppSettings.spellCheckKey) private var spellCheckEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            content
                .id(state.mode)
                .transition(.blurReplace)
        }
        .animation(.easeInOut(duration: 0.28), value: state.mode)
        .overlay(alignment: .bottomTrailing) {
            floatingControls
                .padding(.trailing, 20)
                .padding(.bottom, 10)
        }
        .toolbar {
            if showsEditor {
                ToolbarItem(placement: .topBarTrailing) {
                    ShortcutBar(state: state, compact: true)
                }
            }
        }
        .focusedSceneValue(\.editorState, state)
        .focusedSceneValue(\.editorActions, editorActions)
        .task(id: document) {
            loadDocument()
        }
        .onChange(of: state.text) { _, newValue in
            scheduleSave(newValue)
        }
        .onChange(of: horizontalSizeClass) { _, newValue in
            if newValue == .compact, state.mode == .split {
                state.mode = .edit
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
        state.mode != .preview
    }

    @ViewBuilder
    private var content: some View {
        switch state.mode {
        case .edit:
            editorPane
        case .split:
            HStack(spacing: 0) {
                editorPane
                Divider()
                MarkdownPreview(text: state.text)
            }
        case .preview:
            MarkdownPreview(text: state.text)
        }
    }

    private var editorPane: some View {
        MarkdownTextView(
            state: state,
            layoutDirection: localization.layoutDirection,
            spellCheckEnabled: spellCheckEnabled
        )
        .background(Color(uiColor: .systemBackground))
    }

    /// 右下角悬浮按钮组：编辑 / 分栏 / 预览 / 分享。
    private var floatingControls: some View {
        VStack(spacing: 10) {
            ForEach(availableModes) { mode in
                modeButton(mode)
            }
            floatingShareButton
        }
    }

    private func modeButton(_ mode: EditorMode) -> some View {
        Button {
            state.mode = mode
        } label: {
            Image(systemName: mode.iconName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(state.mode == mode ? Color.accentColor : Color.primary)
                .frame(width: 50, height: 50)
                .contentShape(Circle())
                .background {
                    if state.mode == mode {
                        Circle().fill(Color.accentColor.opacity(0.16))
                    }
                }
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .accessibilityLabel(localization.text(mode.titleKey))
        .accessibilityAddTraits(state.mode == mode ? .isSelected : [])
    }

    /// 右下角悬浮分享按钮，三种模式下都可见。
    private var floatingShareButton: some View {
        Button {
            exportAll()
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 50, height: 50)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .accessibilityLabel(localization.text(.export))
    }

    private var availableModes: [EditorMode] {
        if horizontalSizeClass == .regular {
            return EditorMode.allCases
        }
        return [.edit, .preview]
    }

    private var editorActions: EditorActions {
        EditorActions(
            saveDocument: { saveNow() },
            exportDocument: { exportAll() },
            allowsSplit: horizontalSizeClass == .regular
        )
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
            state.mode = horizontalSizeClass == .regular ? .split : .edit
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
