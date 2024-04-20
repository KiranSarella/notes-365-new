//
//  MarkdownEditorView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/04/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct SmartEditor: View {
    var fileName: String
    var isReadonly: Bool
    var searchText: String?
    @FocusState private var isTextFieldFocused: Bool
    @State private var editorView = UIEditorView()
    @State private var editorType = EditorType.smart
    @State private var showSymbols = false
    @Binding var contentEditedDate: Date?
    @Binding var input: String
    @State private var showingPDFExporter = false
    @State private var pdfFileData: PDFFile = PDFFile(data: Data())
    
    @State private var showingTextExporter = false
    @State private var textFileData: TextFile = TextFile(data: Data())
    
    @AppStorage("showingIndexView") var showingIndexView = false
    @State var state: SmartEditorViewState = SmartEditorViewState()
    @State var refreshIndexEvent: Int = 0
    
    
    var body: some View {
        VStack(alignment: .leading) {
            // formatting bar view
            FormattingOptionsView(editorView: $editorView, contentEditedDate: $contentEditedDate)
                .padding(.horizontal)
                .backgroundStyle(.regularMaterial)
                .background(.background)
                .disabled(isReadonly)
            
            
            EditorViewRepresentable(text: input, editorView: editorView, contentEditedDate: $contentEditedDate,  isEditable: !isReadonly)
                .font(Font.body)
                .focused($isTextFieldFocused)
                .lineSpacing(EditorSettings.lineSpacing)    // bcz paragraph spacing is not working
                .onAppear {
                    if let searchText = searchText, !searchText.isEmpty  {
                        Task {
                            try? await Task.sleep(nanoseconds: 1_000_000_00)
                            editorView.findAction(with: searchText)
                        }
                    }
                }
                .inspector(isPresented: $showingIndexView) {
                    TableOfContentsView(items: $state.headingsNested, headingSelection: $state.headingSelection, refreshIndexEvent: $refreshIndexEvent)
                        .inspectorColumnWidth(420)
                        .toolbar(content: {
                            ToolbarItem {
                                Button {
                                    showingIndexView.toggle()
                                    if showingIndexView {
                                        populateTableOfContents()
                                    }
                                } label: {
                                    if showingIndexView {
                                        Image(systemName: "list.bullet.rectangle.fill")
                                    } else {
                                        Image(systemName: "list.bullet.rectangle")
                                    }
                                    
                                }
                            }
                        })
                        .onAppear {
                            Task {
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                populateTableOfContents()
                            }
                        }
                }
            
        }
        .ignoresSafeArea(edges: [.bottom])
        .onChange(of: input, { oldValue, newValue in
            isTextFieldFocused = false
            showSymbols = false
            self.contentEditedDate = nil
            editorView.text = newValue
        })
        .onChange(of: state.headingSelection) { oldValue, newValue in
            guard let newValue = newValue else { return }
            let obj = state.headingsRange.first { h in
                h.id == newValue
            }
            
            if let obj = obj {
                Task { @MainActor in
                    editorView.textView.scrollRangeToVisible(obj.range)
                }
            }
            
            state.headingSelection = nil
        }
        .onChange(of: refreshIndexEvent, { oldValue, newValue in
            populateTableOfContents()
        })
        .onDisappear {
            isTextFieldFocused = false
        }
        .toolbar {
            // mode change
            ToolbarItem {
                Toggle("", isOn: $showSymbols)
                    .toggleStyle(.switch)
                    .help(showSymbols == false ? "Show Symbols" : "Hide Symbols")
                    .onChange(of: showSymbols, { oldValue, newValue in
                        if newValue {
                            editorType = .markdown
                        } else {
                            editorType = .smart
                        }
                        editorView.editorType = editorType
                    })
            }
            // menu options
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingIndexView.toggle()
//                        populateContents()
                    } label: {
                        HStack {
                            if showingIndexView {
                                Text("Hide Table of Contents")
                            } else {
                                Text("Show Table of Contents")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    Button {
                        editorView.findAction()
                    } label: {
                        HStack {
                            Text("Find & Replace")
                            // Image(systemName: "magnifyingglass")
                        }
                    }
                    .foregroundColor(.primary)
                    Button {
                        if let pdfData = editorView.generatePDFData() {
                            pdfFileData = PDFFile(data: pdfData)
                            showingPDFExporter = true
                        } else {
                            logger.info("pdf export failed")
                        }
                    } label: {
                        Text("Export to PDF")
                    }
                    .foregroundColor(.primary)
                    
//                    Button {
//                        let data =  Data(editorView.text.utf8)
//                        textFileData = TextFile(data: data)
//                        showingTextExporter = true
//                    } label: {
//                        Text("Export to Text")
//                    }
//                    .foregroundColor(.primary)
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .navigationBarTitleDisplayMode(.inline)
//        .fileExporter(isPresented: $showingTextExporter, document: textFileData, contentType: .text, defaultFilename: fileName) { result in
//            switch result {
//            case .success(let url):
//                logger.debug("Saved to \(url)")
//            case .failure(let error):
//                logger.error("\(error)")
//            }
//        }
        .fileExporter(isPresented: $showingPDFExporter, document: pdfFileData, contentType: .pdf, defaultFilename: fileName) { result in
            switch result {
            case .success(let url):
                logger.debug("Saved to \(url)")
            case .failure(let error):
                logger.error("\(error)")
            }
        }
        
        
//        .inspectorColumnWidth(min: 600, ideal: 600, max: 600)
        
//
        
    }
}


struct HeadingRange: Hashable {
    let id: UUID = UUID()
    let line: String
    let range: NSRange
}

extension SmartEditor {
    
    func populateTableOfContents() {
        
        if editorView.text.isEmpty {
            self.state.headingsNested.removeAll()
            self.state.headingsRange.removeAll()
            return
        }
        
        logger.debug("\(#function)")
        
        
        var headings = [HeadingRange]()
        
        let pattern = headingsPattern
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let fullrange = editorView.textView.textStorage.fullRange()
        
        regex.enumerateMatches(in: editorView.textView.attributedText.string, options: [], range: fullrange) {
            match, flags, stop in
            let range = NSRange(location: match!.range.location, length: match!.range.length)
            let line = (editorView.textView.text as NSString).substring(with: range)
            
            headings.append(HeadingRange(line: line, range: range))
        }
        
        var items = [ContentItem]()
        
        for heading in headings {
            let id = heading.id
            let line = heading.line
            let range = heading.range
            if line.hasPrefix("# ") {
                let line = String(line.dropFirst(2))
                let item = ContentItem(id: id, name: line, level: .h1, range: range)
                items.append(item)
            } else if line.hasPrefix("## ") {
                let line = String(line.dropFirst(3))
                let item = ContentItem(id: id, name: line, level: .h2, range: range)
                items.append(item)
            } else if line.hasPrefix("### ") {
                let line = String(line.dropFirst(4))
                let item = ContentItem(id: id, name: line, level: .h3, range: range)
                items.append(item)
            } else if line.hasPrefix("#### ") {
                let line = String(line.dropFirst(5))
                let item = ContentItem(id: id, name: line, level: .h4, range: range)
                items.append(item)
           }
        }
        
        self.state.headingsRange = Set(headings)
        //        self.state.headings = items
        
        // convert to sections
        var sections = [[ContentItem]]()
        var nested = [ContentItem]()
        for item in items {
            // for each new h1 heading, should start new section
            if item.level == .h1 {
                // append if previous list items
                if !nested.isEmpty {
                    sections.append(nested)
                }
                // start new list
                nested = [ContentItem]()
            }
            nested.append(item)
        }
        if !nested.isEmpty {
            sections.append(nested)
        }

        self.state.headingsNested = sections
        
        
    }
    
}


class ContentItem: Identifiable {
    let id: UUID
    let name: String
    let range: NSRange
    let level: MarkdownHeading
    var children = [ContentItem]()

    var isExpanded = true
    
    init(id: UUID, name: String, level: MarkdownHeading, range: NSRange) {
        self.id = id
        self.name = name
        self.level = level
        self.range = range
    }
    
    var containsChildren: Bool {
        children.isEmpty == false
    }
}

extension ContentItem: Hashable, Equatable {
    static func == (lhs: ContentItem, rhs: ContentItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


//
//struct IndexGroupView: View {
//    @Binding var item: ContentItem
//    @State var isExpanded = true
//    
//    var body: some View {
//        
//        DisclosureGroup(isExpanded: $isExpanded) {
//            NestedView(items: $item.children)
//        } label: {
//            Text(item.name)
//                .listRowBackground(Color.clear)
//                .foregroundColor(item.level.indexColor)
//                .fontWeight(item.level.indexWeight)
//        }
//        .listRowBackground(Color.clear)
//    }
//}
//
//struct NestedView: View {
//    @Binding var items: [ContentItem]
//    
//    var body: some View {
//        ForEach($items, id: \.id) { $item in
//            if item.containsChildren {
//                IndexGroupView(item: $item)
//            } else {
//                Text(item.name)
//                    .listRowBackground(Color.clear)
//                    .foregroundColor(item.level.indexColor)
//                    .fontWeight(item.level.indexWeight)
//            }
//        }
//    }
//}
