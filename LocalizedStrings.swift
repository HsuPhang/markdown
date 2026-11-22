import Foundation

/// 界面文案的键。新增语言时只需要补全对应的字典。
enum L10nKey: String, CaseIterable {
    // 文档
    case newDocument
    case rename
    case delete
    case noDocumentsTitle
    case noDocumentsDescription
    case selectDocumentTitle
    case selectDocumentDescription
    case renameDocument
    case fileName
    case confirm
    case cancel
    case untitledDocument
    case nameExists
    case newDocumentContent
    case newDocumentName

    // 编辑器
    case editMode
    case splitMode
    case previewMode
    case viewMode
    case export
    case characterCount

    // 顶部快捷分类
    case formatCategory
    case headingsCategory
    case listsCategory
    case insertCategory

    // 命令
    case bold
    case italic
    case strikethrough
    case inlineCode
    case link
    case image
    case headingFormat
    case bodyText
    case bulletList
    case numberedList
    case taskList
    case quote
    case table
    case codeBlock
    case divider
    case columnOne
    case columnTwo
    case tableContent
    case imageAlt

    // 其他
    case done
    case language
    case followSystem
    case interfaceLanguage
    case pdfReady
    case pdfFailed
    case shareMarkdown
    case sharePDF
}

enum L10n {
    static let simplifiedChinese: [L10nKey: String] = [
        .newDocument: "新建文档",
        .rename: "重命名",
        .delete: "删除",
        .noDocumentsTitle: "还没有文档",
        .noDocumentsDescription: "点右上角的新建按钮开始写第一篇",
        .selectDocumentTitle: "选择一篇文档",
        .selectDocumentDescription: "从左侧列表选一篇，或者新建一篇",
        .renameDocument: "重命名文档",
        .fileName: "文件名",
        .confirm: "确定",
        .cancel: "取消",
        .untitledDocument: "未命名文档",
        .nameExists: "已存在同名文档",
        .newDocumentContent: "# 新文档\n\n",
        .newDocumentName: "新文档",
        .editMode: "编辑",
        .splitMode: "分栏",
        .previewMode: "预览",
        .viewMode: "视图模式",
        .export: "导出",
        .characterCount: "%d 字",
        .formatCategory: "格式",
        .headingsCategory: "标题",
        .listsCategory: "列表",
        .insertCategory: "插入",
        .bold: "加粗",
        .italic: "斜体",
        .strikethrough: "删除线",
        .inlineCode: "行内代码",
        .link: "链接",
        .image: "图片",
        .headingFormat: "标题 %d",
        .bodyText: "正文",
        .bulletList: "无序列表",
        .numberedList: "有序列表",
        .taskList: "任务列表",
        .quote: "引用",
        .table: "表格",
        .codeBlock: "代码块",
        .divider: "分隔线",
        .columnOne: "列 1",
        .columnTwo: "列 2",
        .tableContent: "内容",
        .imageAlt: "说明",
        .done: "完成",
        .language: "语言",
        .followSystem: "跟随系统",
        .interfaceLanguage: "界面语言",
        .pdfReady: "已同时生成 PDF 副本",
        .pdfFailed: "PDF 生成失败，仅可分享 Markdown 文件",
        .shareMarkdown: "分享 Markdown 文件",
        .sharePDF: "分享 PDF",
    ]

    static let traditionalChinese: [L10nKey: String] = [
        .newDocument: "新增文件",
        .rename: "重新命名",
        .delete: "刪除",
        .noDocumentsTitle: "尚無文件",
        .noDocumentsDescription: "點右上角的新增按鈕開始寫第一篇",
        .selectDocumentTitle: "選擇一份文件",
        .selectDocumentDescription: "從左側列表選一份，或新增一份",
        .renameDocument: "重新命名文件",
        .fileName: "檔名",
        .confirm: "確定",
        .cancel: "取消",
        .untitledDocument: "未命名文件",
        .nameExists: "已存在同名文件",
        .newDocumentContent: "# 新文件\n\n",
        .newDocumentName: "新文件",
        .editMode: "編輯",
        .splitMode: "分割",
        .previewMode: "預覽",
        .viewMode: "檢視模式",
        .export: "匯出",
        .characterCount: "%d 字",
        .formatCategory: "格式",
        .headingsCategory: "標題",
        .listsCategory: "列表",
        .insertCategory: "插入",
        .bold: "粗體",
        .italic: "斜體",
        .strikethrough: "刪除線",
        .inlineCode: "行內程式碼",
        .link: "連結",
        .image: "圖片",
        .headingFormat: "標題 %d",
        .bodyText: "內文",
        .bulletList: "項目符號列表",
        .numberedList: "編號列表",
        .taskList: "待辦清單",
        .quote: "引用",
        .table: "表格",
        .codeBlock: "程式碼區塊",
        .divider: "分隔線",
        .columnOne: "欄 1",
        .columnTwo: "欄 2",
        .tableContent: "內容",
        .imageAlt: "說明",
        .done: "完成",
        .language: "語言",
        .followSystem: "跟隨系統",
        .interfaceLanguage: "介面語言",
        .pdfReady: "已同時產生 PDF 副本",
        .pdfFailed: "PDF 產生失敗，僅能分享 Markdown 檔案",
        .shareMarkdown: "分享 Markdown 檔案",
        .sharePDF: "分享 PDF",
    ]

    static let english: [L10nKey: String] = [
        .newDocument: "New Document",
        .rename: "Rename",
        .delete: "Delete",
        .noDocumentsTitle: "No Documents Yet",
        .noDocumentsDescription: "Tap the new document button in the top-right corner to start writing.",
        .selectDocumentTitle: "Select a Document",
        .selectDocumentDescription: "Pick one from the list on the left, or create a new one.",
        .renameDocument: "Rename Document",
        .fileName: "File Name",
        .confirm: "OK",
        .cancel: "Cancel",
        .untitledDocument: "Untitled Document",
        .nameExists: "A document with this name already exists.",
        .newDocumentContent: "# New Document\n\n",
        .newDocumentName: "New Document",
        .editMode: "Edit",
        .splitMode: "Split",
        .previewMode: "Preview",
        .viewMode: "View Mode",
        .export: "Export",
        .characterCount: "%d characters",
        .formatCategory: "Format",
        .headingsCategory: "Headings",
        .listsCategory: "Lists",
        .insertCategory: "Insert",
        .bold: "Bold",
        .italic: "Italic",
        .strikethrough: "Strikethrough",
        .inlineCode: "Inline Code",
        .link: "Link",
        .image: "Image",
        .headingFormat: "Heading %d",
        .bodyText: "Body Text",
        .bulletList: "Bulleted List",
        .numberedList: "Numbered List",
        .taskList: "Task List",
        .quote: "Quote",
        .table: "Table",
        .codeBlock: "Code Block",
        .divider: "Divider",
        .columnOne: "Column 1",
        .columnTwo: "Column 2",
        .tableContent: "Content",
        .imageAlt: "Alt Text",
        .done: "Done",
        .language: "Language",
        .followSystem: "Follow System",
        .interfaceLanguage: "Interface Language",
        .pdfReady: "A PDF copy was also created.",
        .pdfFailed: "PDF creation failed. Only the Markdown file can be shared.",
        .shareMarkdown: "Share Markdown File",
        .sharePDF: "Share PDF",
    ]

    static let japanese: [L10nKey: String] = [
        .newDocument: "新規書類",
        .rename: "名前を変更",
        .delete: "削除",
        .noDocumentsTitle: "書類がありません",
        .noDocumentsDescription: "右上の新規作成ボタンから最初の書類を書き始めましょう",
        .selectDocumentTitle: "書類を選択",
        .selectDocumentDescription: "左のリストから選ぶか、新規作成してください",
        .renameDocument: "書類名を変更",
        .fileName: "ファイル名",
        .confirm: "OK",
        .cancel: "キャンセル",
        .untitledDocument: "無題の書類",
        .nameExists: "同じ名前の書類がすでにあります",
        .newDocumentContent: "# 新しい書類\n\n",
        .newDocumentName: "新しい書類",
        .editMode: "編集",
        .splitMode: "分割",
        .previewMode: "プレビュー",
        .viewMode: "表示モード",
        .export: "書き出し",
        .characterCount: "%d 文字",
        .formatCategory: "書式",
        .headingsCategory: "見出し",
        .listsCategory: "リスト",
        .insertCategory: "挿入",
        .bold: "太字",
        .italic: "斜体",
        .strikethrough: "取り消し線",
        .inlineCode: "インラインコード",
        .link: "リンク",
        .image: "画像",
        .headingFormat: "見出し %d",
        .bodyText: "本文",
        .bulletList: "箇条書き",
        .numberedList: "番号付きリスト",
        .taskList: "タスクリスト",
        .quote: "引用",
        .table: "表",
        .codeBlock: "コードブロック",
        .divider: "区切り線",
        .columnOne: "列 1",
        .columnTwo: "列 2",
        .tableContent: "内容",
        .imageAlt: "代替テキスト",
        .done: "完了",
        .language: "言語",
        .followSystem: "システムに従う",
        .interfaceLanguage: "表示言語",
        .pdfReady: "PDF のコピーも作成しました",
        .pdfFailed: "PDF を作成できませんでした。Markdown ファイルのみ共有できます",
        .shareMarkdown: "Markdown ファイルを共有",
        .sharePDF: "PDF を共有",
    ]

    static let vietnamese: [L10nKey: String] = [
        .newDocument: "Tài liệu mới",
        .rename: "Đổi tên",
        .delete: "Xóa",
        .noDocumentsTitle: "Chưa có tài liệu",
        .noDocumentsDescription: "Nhấn nút tạo tài liệu ở góc trên bên phải để bắt đầu viết.",
        .selectDocumentTitle: "Chọn một tài liệu",
        .selectDocumentDescription: "Chọn từ danh sách bên trái hoặc tạo tài liệu mới.",
        .renameDocument: "Đổi tên tài liệu",
        .fileName: "Tên tệp",
        .confirm: "OK",
        .cancel: "Hủy",
        .untitledDocument: "Tài liệu chưa đặt tên",
        .nameExists: "Đã có tài liệu cùng tên.",
        .newDocumentContent: "# Tài liệu mới\n\n",
        .newDocumentName: "Tài liệu mới",
        .editMode: "Chỉnh sửa",
        .splitMode: "Chia đôi",
        .previewMode: "Xem trước",
        .viewMode: "Chế độ xem",
        .export: "Xuất",
        .characterCount: "%d ký tự",
        .formatCategory: "Định dạng",
        .headingsCategory: "Tiêu đề",
        .listsCategory: "Danh sách",
        .insertCategory: "Chèn",
        .bold: "In đậm",
        .italic: "In nghiêng",
        .strikethrough: "Gạch ngang",
        .inlineCode: "Mã nội tuyến",
        .link: "Liên kết",
        .image: "Hình ảnh",
        .headingFormat: "Tiêu đề %d",
        .bodyText: "Nội dung",
        .bulletList: "Danh sách dấu đầu dòng",
        .numberedList: "Danh sách đánh số",
        .taskList: "Danh sách công việc",
        .quote: "Trích dẫn",
        .table: "Bảng",
        .codeBlock: "Khối mã",
        .divider: "Đường phân cách",
        .columnOne: "Cột 1",
        .columnTwo: "Cột 2",
        .tableContent: "Nội dung",
        .imageAlt: "Văn bản thay thế",
        .done: "Xong",
        .language: "Ngôn ngữ",
        .followSystem: "Theo hệ thống",
        .interfaceLanguage: "Ngôn ngữ giao diện",
        .pdfReady: "Đã tạo thêm bản sao PDF.",
        .pdfFailed: "Không thể tạo PDF. Chỉ có thể chia sẻ tệp Markdown.",
        .shareMarkdown: "Chia sẻ tệp Markdown",
        .sharePDF: "Chia sẻ PDF",
    ]

    static let korean: [L10nKey: String] = [
        .newDocument: "새 문서",
        .rename: "이름 변경",
        .delete: "삭제",
        .noDocumentsTitle: "문서가 없습니다",
        .noDocumentsDescription: "오른쪽 위의 새 문서 버튼을 눌러 첫 문서를 작성하세요.",
        .selectDocumentTitle: "문서 선택",
        .selectDocumentDescription: "왼쪽 목록에서 선택하거나 새로 만드세요.",
        .renameDocument: "문서 이름 변경",
        .fileName: "파일 이름",
        .confirm: "확인",
        .cancel: "취소",
        .untitledDocument: "제목 없는 문서",
        .nameExists: "같은 이름의 문서가 이미 있습니다.",
        .newDocumentContent: "# 새 문서\n\n",
        .newDocumentName: "새 문서",
        .editMode: "편집",
        .splitMode: "분할",
        .previewMode: "미리보기",
        .viewMode: "보기 모드",
        .export: "내보내기",
        .characterCount: "%d 자",
        .formatCategory: "서식",
        .headingsCategory: "제목",
        .listsCategory: "목록",
        .insertCategory: "삽입",
        .bold: "굵게",
        .italic: "기울임꼴",
        .strikethrough: "취소선",
        .inlineCode: "인라인 코드",
        .link: "링크",
        .image: "이미지",
        .headingFormat: "제목 %d",
        .bodyText: "본문",
        .bulletList: "글머리 기호 목록",
        .numberedList: "번호 매기기 목록",
        .taskList: "할 일 목록",
        .quote: "인용",
        .table: "표",
        .codeBlock: "코드 블록",
        .divider: "구분선",
        .columnOne: "열 1",
        .columnTwo: "열 2",
        .tableContent: "내용",
        .imageAlt: "대체 텍스트",
        .done: "완료",
        .language: "언어",
        .followSystem: "시스템 설정 따르기",
        .interfaceLanguage: "인터페이스 언어",
        .pdfReady: "PDF 사본도 생성했습니다.",
        .pdfFailed: "PDF를 생성하지 못했습니다. Markdown 파일만 공유할 수 있습니다.",
        .shareMarkdown: "Markdown 파일 공유",
        .sharePDF: "PDF 공유",
    ]

    static let spanish: [L10nKey: String] = [
        .newDocument: "Documento nuevo",
        .rename: "Cambiar nombre",
        .delete: "Eliminar",
        .noDocumentsTitle: "Aún no hay documentos",
        .noDocumentsDescription: "Toca el botón de documento nuevo en la esquina superior derecha para empezar a escribir.",
        .selectDocumentTitle: "Selecciona un documento",
        .selectDocumentDescription: "Elige uno de la lista de la izquierda o crea uno nuevo.",
        .renameDocument: "Cambiar nombre del documento",
        .fileName: "Nombre del archivo",
        .confirm: "Aceptar",
        .cancel: "Cancelar",
        .untitledDocument: "Documento sin título",
        .nameExists: "Ya existe un documento con ese nombre.",
        .newDocumentContent: "# Documento nuevo\n\n",
        .newDocumentName: "Documento nuevo",
        .editMode: "Editar",
        .splitMode: "Dividir",
        .previewMode: "Vista previa",
        .viewMode: "Modo de vista",
        .export: "Exportar",
        .characterCount: "%d caracteres",
        .formatCategory: "Formato",
        .headingsCategory: "Encabezados",
        .listsCategory: "Listas",
        .insertCategory: "Insertar",
        .bold: "Negrita",
        .italic: "Cursiva",
        .strikethrough: "Tachado",
        .inlineCode: "Código en línea",
        .link: "Enlace",
        .image: "Imagen",
        .headingFormat: "Encabezado %d",
        .bodyText: "Texto normal",
        .bulletList: "Lista con viñetas",
        .numberedList: "Lista numerada",
        .taskList: "Lista de tareas",
        .quote: "Cita",
        .table: "Tabla",
        .codeBlock: "Bloque de código",
        .divider: "Separador",
        .columnOne: "Columna 1",
        .columnTwo: "Columna 2",
        .tableContent: "Contenido",
        .imageAlt: "Texto alternativo",
        .done: "Listo",
        .language: "Idioma",
        .followSystem: "Seguir el sistema",
        .interfaceLanguage: "Idioma de la interfaz",
        .pdfReady: "También se creó una copia en PDF.",
        .pdfFailed: "No se pudo crear el PDF. Solo se puede compartir el archivo Markdown.",
        .shareMarkdown: "Compartir archivo Markdown",
        .sharePDF: "Compartir PDF",
    ]

    static let tibetan: [L10nKey: String] = [
        .newDocument: "ཡིག་ཆ་གསར་པ",
        .rename: "མིང་བསྒྱུར",
        .delete: "བསུབ་པ",
        .noDocumentsTitle: "ད་དུང་ཡིག་ཆ་མེད",
        .noDocumentsDescription: "གཡས་མཐོའི་ཡིག་ཆ་གསར་པའི་མཐེབ་ནོན་ནས་དང་པོའི་ཡིག་ཆ་འབྲི་རོགས",
        .selectDocumentTitle: "ཡིག་ཆ་ཞིག་འདེམས་རོགས",
        .selectDocumentDescription: "གཡོན་ཕྱོགས་ཐོ་ནས་ཞིག་འདེམས་པའམ་གསར་པ་ཞིག་བཟོ་རོགས",
        .renameDocument: "ཡིག་ཆའི་མིང་བསྒྱུར",
        .fileName: "ཡིག་ཆའི་མིང",
        .confirm: "ཆོག",
        .cancel: "དོར་བ",
        .untitledDocument: "མིང་མེད་ཡིག་ཆ",
        .nameExists: "མིང་འདྲ་བའི་ཡིག་ཆ་ཡོད་ཟིན",
        .newDocumentContent: "# ཡིག་ཆ་གསར་པ\n\n",
        .newDocumentName: "ཡིག་ཆ་གསར་པ",
        .editMode: "རྩོམ་སྒྲིག",
        .splitMode: "དབྱེ་བ",
        .previewMode: "སྔོན་ལྟ",
        .viewMode: "ལྟ་སྟངས",
        .export: "ཕྱིར་འདྲེན",
        .characterCount: "%d ཡིག་འབྲུ",
        .formatCategory: "རྣམ་གཞག",
        .headingsCategory: "མཚན་བཏགས",
        .listsCategory: "ཐོ་ཁོངས",
        .insertCategory: "འཇུག་པ",
        .bold: "སྦོམ་ཡིག",
        .italic: "འཁྱོག་ཡིག",
        .strikethrough: "བརྐོས་ཐིག",
        .inlineCode: "ཨང་རྟགས་ཆུང་བ",
        .link: "སྦྲེལ་ཐིག",
        .image: "པར་རིས",
        .headingFormat: "མཚན་བཏགས %d",
        .bodyText: "ཡིག་གཞི",
        .bulletList: "ཐིག་ཐོ",
        .numberedList: "ཨང་གྲངས་ཐོ",
        .taskList: "ལས་དོན་ཐོ",
        .quote: "བཤད་ཚིག",
        .table: "ཐིག་གོང",
        .codeBlock: "ཨང་རྟགས་ཚན",
        .divider: "བར་ཐིག",
        .columnOne: "ཐིག་ 1",
        .columnTwo: "ཐིག་ 2",
        .tableContent: "ནང་དོན",
        .imageAlt: "འགྲེལ་བཤད",
        .done: "གྲུབ་སོང",
        .language: "སྐད་ཡིག",
        .followSystem: "རིམ་ལུགས་ལ་རྗེས་འབྲང",
        .interfaceLanguage: "ངོས་སྒོའི་སྐད་ཡིག",
        .pdfReady: "PDF འདྲ་བཤུས་ཀྱང་བཟོས་ཟིན",
        .pdfFailed: "PDF བཟོ་མ་ཐུབ། Markdown ཡིག་ཆ་ཁོ་ན་བརྗེ་ཐུབ",
        .shareMarkdown: "Markdown ཡིག་ཆ་བརྗེ་བ",
        .sharePDF: "PDF བརྗེ་བ",
    ]

    static let uyghur: [L10nKey: String] = [
        .newDocument: "يېڭى ھۆججەت",
        .rename: "ئىسمىنى ئۆزگەرتىش",
        .delete: "ئۆچۈرۈش",
        .noDocumentsTitle: "ھازىرچە ھۆججەت يوق",
        .noDocumentsDescription: "ئوڭ ئۈستىدىكى يېڭى ھۆججەت كۇنۇپكىسىنى بېسىپ تۇنجى ھۆججىتىڭىزنى يېزىڭ",
        .selectDocumentTitle: "بىر ھۆججەت تاللاڭ",
        .selectDocumentDescription: "سول تەرەپتىكى تىزىملىكتىن تاللاڭ ياكى يېڭىسىنى قۇرۇڭ",
        .renameDocument: "ھۆججەت ئىسمىنى ئۆزگەرتىش",
        .fileName: "ھۆججەت ئىسمى",
        .confirm: "جەزملەش",
        .cancel: "بىكار قىلىش",
        .untitledDocument: "ئىسىمسىز ھۆججەت",
        .nameExists: "ئوخشاش ئىسىملىك ھۆججەت مەۋجۇت",
        .newDocumentContent: "# يېڭى ھۆججەت\n\n",
        .newDocumentName: "يېڭى ھۆججەت",
        .editMode: "تەھرىرلەش",
        .splitMode: "ئايرىش",
        .previewMode: "ئالدىن كۆرۈش",
        .viewMode: "كۆرۈنۈش ھالىتى",
        .export: "چىقىرىش",
        .characterCount: "%d ھەرپ",
        .formatCategory: "فورمات",
        .headingsCategory: "ماۋزۇلار",
        .listsCategory: "تىزىملىكلەر",
        .insertCategory: "قىستۇرۇش",
        .bold: "توم",
        .italic: "يانتۇ",
        .strikethrough: "ئۆچۈرۈش سىزىقى",
        .inlineCode: "قۇر ئىچى كودى",
        .link: "ئۇلانما",
        .image: "رەسىم",
        .headingFormat: "ماۋزۇ %d",
        .bodyText: "ئاساسىي تېكىست",
        .bulletList: "نۇقتىلىق تىزىملىك",
        .numberedList: "نومۇرلۇق تىزىملىك",
        .taskList: "ۋەزىپە تىزىملىكى",
        .quote: "نەقىل",
        .table: "جەدۋەل",
        .codeBlock: "كود بۆلىكى",
        .divider: "ئايرىغۇچ",
        .columnOne: "1-ئىستون",
        .columnTwo: "2-ئىستون",
        .tableContent: "مەزمۇن",
        .imageAlt: "تەسۋىر",
        .done: "تامام",
        .language: "تىل",
        .followSystem: "سىستېمىغا ئەگىشىش",
        .interfaceLanguage: "كۆرۈنمە يۈز تىلى",
        .pdfReady: "PDF كۆچۈرمىسىمۇ قۇرۇلدى",
        .pdfFailed: "PDF قۇرۇلمىدى، پەقەت Markdown ھۆججىتىنى ھەمبەھىرلىگىلى بولىدۇ",
        .shareMarkdown: "Markdown ھۆججىتىنى ھەمبەھىرلەش",
        .sharePDF: "PDF ھەمبەھىرلەش",
    ]

    /// 彝文（ꆈꌠꉙ）目前只覆盖少量已确认的术语，其余条目回退到简体中文。
    static let yi: [L10nKey: String] = [
        .language: "ꉙ",
        .newDocumentName: "ꁱꂷ",
    ]
}

extension AppLanguage {
    var table: [L10nKey: String] {
        switch self {
        case .system: return [:]
        case .simplifiedChinese: return L10n.simplifiedChinese
        case .traditionalChinese: return L10n.traditionalChinese
        case .english: return L10n.english
        case .japanese: return L10n.japanese
        case .vietnamese: return L10n.vietnamese
        case .korean: return L10n.korean
        case .tibetan: return L10n.tibetan
        case .uyghur: return L10n.uyghur
        case .yi: return L10n.yi
        case .spanish: return L10n.spanish
        }
    }

    func string(for key: L10nKey) -> String {
        if let value = table[key] { return value }
        if self == .yi, let value = L10n.simplifiedChinese[key] { return value }
        return L10n.english[key] ?? key.rawValue
    }
}
