import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = DocumentStore()
    @State private var selection: MDDocument?

    @State private var nameAlertKind: NameAlertKind?
    @State private var inputName = ""
    @State private var renameTarget: MDDocument?
    @State private var nameExistsAlert = false

    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.colorScheme) private var colorScheme

    enum NameAlertKind {
        case create
        case rename
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(store.documents) { document in
                    DocumentRow(document: document)
                        .tag(document)
                        .contextMenu {
                            Button {
                                renameTarget = document
                                inputName = document.title
                                nameAlertKind = .rename
                            } label: {
                                Label(localization.text(.rename), systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                delete(document)
                            } label: {
                                Label(localization.text(.delete), systemImage: "trash")
                            }
                        }
                }
                .onDelete(perform: deleteAt)
            }
            .overlay {
                if store.documents.isEmpty {
                    VStack(spacing: 12) {
                        AppIconView(size: 64)
                        Text(localization.text(.noDocumentsTitle))
                            .font(.headline)
                        Text(localization.text(.noDocumentsDescription))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("MarkPad")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    languageMenu
                    Button {
                        inputName = ""
                        nameAlertKind = .create
                    } label: {
                        Label(localization.text(.newDocument), systemImage: "square.and.pencil")
                    }
                }
            }
        } detail: {
            if let selection {
                EditorView(store: store, document: selection)
            } else {
                VStack(spacing: 14) {
                    AppIconView(size: 88)
                    Text(localization.text(.selectDocumentTitle))
                        .font(.headline)
                    Text(localization.text(.selectDocumentDescription))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(28)
            }
        }
        .task {
            store.reload()
            if selection == nil {
                selection = store.documents.first
            }
        }
        .onAppear {
            AppIconManager.sync(with: colorScheme)
        }
        .onChange(of: colorScheme) { _, newValue in
            AppIconManager.sync(with: newValue)
        }
        .alert(alertTitle, isPresented: alertBinding) {
            TextField(localization.text(.fileName), text: $inputName)
            Button(localization.text(.confirm)) { handleName() }
            Button(localization.text(.cancel), role: .cancel) {
                nameAlertKind = nil
                renameTarget = nil
            }
        }
        .alert(localization.text(.nameExists), isPresented: $nameExistsAlert) {
            Button(localization.text(.confirm), role: .cancel) {}
        }
    }

    private var languageMenu: some View {
        Menu {
            Picker(localization.text(.interfaceLanguage), selection: $localization.selection) {
                Text(localization.text(.followSystem))
                    .tag(AppLanguage.system)
                ForEach(AppLanguage.allCases.filter { $0 != .system }) { language in
                    Text(language.displayName)
                        .tag(language)
                }
            }
        } label: {
            Label(localization.text(.language), systemImage: "globe")
        }
    }

    private var alertTitle: String {
        localization.text(nameAlertKind == .rename ? .renameDocument : .newDocument)
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { nameAlertKind != nil },
            set: { isPresented in
                if !isPresented {
                    nameAlertKind = nil
                    renameTarget = nil
                }
            }
        )
    }

    private func handleName() {
        switch nameAlertKind {
        case .create:
            let created = store.create(
                name: inputName,
                content: localization.text(.newDocumentContent),
                fallbackName: localization.text(.untitledDocument)
            )
            if let created {
                selection = created
            }
        case .rename:
            if let target = renameTarget {
                let trimmed = inputName.trimmingCharacters(in: .whitespacesAndNewlines)
                let duplicate = store.documents.contains { document in
                    document != target
                        && document.title.compare(trimmed, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
                }
                if !trimmed.isEmpty, duplicate {
                    nameAlertKind = nil
                    renameTarget = nil
                    // 等前一个输入框真正消失后再弹提示，避免两个 alert 同时呈现。
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        nameExistsAlert = true
                    }
                    return
                }
                if let renamed = store.rename(target, to: inputName), selection == target {
                    selection = renamed
                }
            }
        case nil:
            break
        }
        nameAlertKind = nil
        renameTarget = nil
    }

    private func delete(_ document: MDDocument) {
        if selection == document {
            selection = nil
        }
        store.delete(document)
    }

    private func deleteAt(_ offsets: IndexSet) {
        let targets = offsets.compactMap { index -> MDDocument? in
            index < store.documents.count ? store.documents[index] : nil
        }
        for target in targets {
            delete(target)
        }
    }
}

struct DocumentRow: View {
    let document: MDDocument

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(document.title)
                    .font(.headline)
                Text(document.modified.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        } icon: {
            Image(systemName: "doc.text")
                .foregroundStyle(.tint)
        }
    }
}

/// 主屏图标：iOS 不会按深浅色自动换主图标，
/// 只能通过备用图标 API 在运行时把主屏图标切到深色版本。
@MainActor
enum AppIconManager {
    static let darkIconName = "AppIcon-Dark"

    static func sync(with colorScheme: ColorScheme) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        let target: String? = colorScheme == .dark ? darkIconName : nil
        guard UIApplication.shared.alternateIconName != target else { return }
        UIApplication.shared.setAlternateIconName(target)
    }
}

/// 按系统外观自动切换浅色 / 深色 App 图标。
struct AppIconView: View {
    var size: CGFloat = 56

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if let image = UIImage(named: colorScheme == .dark ? "AppIcon-Dark" : "AppIcon-Light") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "doc.text")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.24)
                    .foregroundStyle(.tint)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.23, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: size * 0.23, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        }
        .accessibilityHidden(true)
    }
}
