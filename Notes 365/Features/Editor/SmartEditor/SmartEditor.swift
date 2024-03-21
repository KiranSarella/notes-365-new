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
    
    @State var showingIndexView = true
    @State var headings = [ContentItem]()
    @State var headingSelection: ContentItem.ID? = nil
    @State var headingsRange = Set<HeadingRange>()
    
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
                    IndexView(items: $headings, headingSelection: $headingSelection)
                        .inspectorColumnWidth(440)
                        .toolbar(content: {
                            ToolbarItem {
                                Button {
                                    showingIndexView.toggle()
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
                                populateContents()
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
        .onChange(of: headingSelection) { oldValue, newValue in
            guard let newValue = newValue else { return }
            let obj = headingsRange.first { h in
                h.id == newValue
            }
            
            if let obj = obj {
                Task { @MainActor in
                    editorView.textView.scrollRangeToVisible(obj.range)
                }
            }
            
            headingSelection = nil
        }
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
                                Text("Hide Index")
                            } else {
                                Text("Show Index")
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
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .navigationBarTitleDisplayMode(.inline)
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
    
    func populateContents() {
        
        if input.isEmpty {
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
                let item = ContentItem(id: id, name: line, range: range)
                items.append(item)
                
            } else if line.hasPrefix("## ") {
                let line = String(line.dropFirst(3))
                let item = ContentItem(id: id, name: line, range: range)
                items.last?.children
                    .append(item)
                
            } else if line.hasPrefix("### ") {
                let line = String(line.dropFirst(4))
                let item = ContentItem(id: id, name: line, range: range)
                items.last?.children
                    .last?.children
                    .append(item)
            } else if line.hasPrefix("#### ") {
                let line = String(line.dropFirst(5))
                let item = ContentItem(id: id, name: line, range: range)
               items.last?.children
                   .last?.children
                   .last?.children
                   .append(item)
           } else if line.hasPrefix("##### ") {
               let line = String(line.dropFirst(6))
               let item = ContentItem(id: id, name: line, range: range)
               items.last?.children
                   .last?.children
                   .last?.children
                   .last?.children
                   .append(item)
           } else if line.hasPrefix("###### ") {
               let line = String(line.dropFirst(7))
               let item = ContentItem(id: id, name: line, range: range)
               items.last?.children
                   .last?.children
                   .last?.children
                   .last?.children
                   .last?.children
                   .append(item)
           }
            
        }
        
        self.headings = items
        self.headingsRange = Set(headings)
        
    }
    
}

//struct IndexView: View {
//    
//    let headings = ["Lorem Tellus", "Tortor Venenatis Condimentum Venenatis Venenatis", "Tortor Adipiscing", "Dapibus Purus", "Nibh Tortor", "Vestibulum"]
//    
//    
//    var body: some View {
//        List {
//            
//            Section {
//                ForEach(headings, id: \.self) { heading in
//                    Text(heading)
//                        .lineLimit(1)
////                        .listRowBackground(Color.clear)
//                        .foregroundStyle(Color.white)
////                        .font(.title2)
//                }
//            } header: {
//                Text("Chapter 1")
//                    .font(.largeTitle)
//                    .fontWeight(.heavy)
//            }
//            
//            Section {
//                ForEach(headings, id: \.self) { heading in
//                    Text(heading)
//                        .lineLimit(1)
////                        .listRowBackground(Color.clear)
////                        .font(.title2)
//                }
//            } header: {
//                Text("Chapter 2")
//                    .font(.largeTitle)
//                    .fontWeight(.heavy)
//            }
//            
//            
//            
//        }
////        .foregroundStyle(Color.white)
////        List(fileHierarchyData, children: \.children) { item in
////            Text(item.description)
////                .listRowBackground(Color.clear)
////                .foregroundStyle(Color.white)
////                .font(.title)
////        }
////        .listStyle(PlainListStyle())
////        .padding()
//    }
//}


class ContentItem: Identifiable {
    let id: UUID
    let name: String
    let range: NSRange
    
    var children = [ContentItem]()

    var isExpanded = true
    
    init(id: UUID, name: String, range: NSRange) {
        self.id = id
        self.name = name
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

//struct FileItemm: Hashable, Identifiable, CustomStringConvertible {
//        var id: UUID = UUID()
//        var name: String
//        var children: [FileItemm]? = nil
//        var description: String {
//            switch children {
//            case nil:
//                return "\(name)"
//            case .some(let children):
//                return children.isEmpty ? "\(name)" : "\(name)"
//            }
//        }
//    
//        var containsChildren: Bool {
//            children != nil && !(children?.isEmpty ?? false)
//        }
//}
//
//extension FileItemm: Equatable {
//    static func == (lhs: Self, rhs: Self) -> Bool {
//        lhs.id == rhs.id
//    }
//}

struct IndexView: View {
    @Binding var items: [ContentItem]
    @Binding var headingSelection: ContentItem.ID?
    let level: MarkdownHeading = .h1
    
        var body: some View {
            List(selection: $headingSelection) {
                ForEach($items, id: \.id) { $item in
                    
                    Section {
                        if item.containsChildren {
                            IndexGroupView(level: level, item: $item)
                        } else {
                            Text(item.name)
                                .listRowBackground(Color.clear)
                                .foregroundColor(level.indexColor)
                                .fontWeight(level.indexWeight)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .background(ThemeState.shared.theme.dynamicCanvasColor)
//            .foregroundColor(Color.secondary)
            .lineLimit(1)
            
        }
}

struct IndexGroupView: View {
    let level: MarkdownHeading
    @Binding var item: ContentItem
    @State var isExpanded = true
    
    var body: some View {
        
        DisclosureGroup(isExpanded: $isExpanded) {
            NestedView(level: level.next(), items: $item.children)
        } label: {
            Text(item.name)
                .listRowBackground(Color.clear)
                .foregroundColor(level.indexColor)
                .fontWeight(level.indexWeight)
        }
        .listRowBackground(Color.clear)
    }
}

struct NestedView: View {
    let level: MarkdownHeading
    @Binding var items: [ContentItem]
    
    var body: some View {
        ForEach($items, id: \.id) { $item in
            if item.containsChildren {
                IndexGroupView(level: level, item: $item)
            } else {
                Text(item.name)
                    .listRowBackground(Color.clear)
                    .foregroundColor(level.indexColor)
                    .fontWeight(level.indexWeight)
            }
        }
    }
}



//struct MyDisclosureStyle: DisclosureGroupStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        VStack {
//            Button {
//                withAnimation {
//                    configuration.isExpanded.toggle()
//                }
//            } label: {
//                HStack(alignment: .firstTextBaseline) {
//                    configuration.label
//                    Spacer()
//                    Text(configuration.isExpanded ? "hide" : "show")
//                        .foregroundColor(.accentColor)
//                        .font(.caption.lowercaseSmallCaps())
//                        .animation(nil, value: configuration.isExpanded)
//                }
//                .contentShape(Rectangle())
//            }
//            .buttonStyle(.plain)
//            if configuration.isExpanded {
//                configuration.content
//            }
//        }
//    }
//}

extension MarkdownHeading {
    
    // index related
    func next() -> MarkdownHeading {
        switch self {
        case .h1:
            return MarkdownHeading.h2
        case .h2:
            return MarkdownHeading.h3
        case .h3:
            return MarkdownHeading.h4
        case .h4:
            return MarkdownHeading.h5
        case .h5:
            return MarkdownHeading.h6
        case .h6:
            return MarkdownHeading.h6
        }
    }
    
    var indexColor: Color {
        switch self {
        case .h1:
            return Color.primary
        case .h2:
            return Color(hex: 0x941100)
        case .h3:
            return Color(hex: 0x929000)
        case .h4:
            return Color(hex: 0x009051)
        case .h5:
            return Color(hex: 0x005493)
        case .h6:
            return Color(hex: 0xe26c00)
        }
    }
    
    var indexWeight: Font.Weight {
        
        switch self {
        case .h1:
            return .black
        case .h2:
            return .bold
        case .h3:
            return .bold
        case .h4:
            return .bold
        case .h5:
            return .bold
        case .h6:
            return .bold
        }
    }

}
