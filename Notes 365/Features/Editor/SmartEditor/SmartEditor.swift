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
    
    @State var presentIndexView = true
    @State var headings = [ContentItem]()
    
    
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
                .inspector(isPresented: $presentIndexView) {
                    IndexView(items: $headings)
                        .inspectorColumnWidth(500)
                        .onAppear {
                            
                            Task {
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                populateContents()
                            }
                            
                        }
//                        .inspectorColumnWidth(min: 350, ideal: 360, max: 600)
                }
            
//            ZStack {
//                
//                
//                HStack {
//                    Spacer()
//                    VStack {
//                        IndexView()
//                            .frame(width: 400, height: 800)
//                            .background(Color.black.opacity(0.7))
//                            .clipShape(RoundedRectangle(cornerRadius: 30))
//                            .padding(20)
//                        
//                        Spacer()
//                    }
//                        
//                }
//            }
            
            
        }
        .ignoresSafeArea(edges: [.bottom])
        .onChange(of: input, { oldValue, newValue in
            isTextFieldFocused = false
            showSymbols = false
            self.contentEditedDate = nil
            editorView.text = newValue
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
                        presentIndexView.toggle()
//                        populateContents()
                    } label: {
                        HStack {
                            if presentIndexView {
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


extension SmartEditor {
    
    func populateContents() {
        
        if input.isEmpty {
            return
        }
        
        logger.debug("\(#function)")
        
        var h1Text = [String]()
        var h2Text = [String]()
        var h3Text = [String]()
        
        var headings = [String]()
        
        let pattern = headingsPattern
        let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let fullrange = editorView.textView.textStorage.fullRange()
        
        regex.enumerateMatches(in: editorView.textView.attributedText.string, options: [], range: fullrange) {
            match, flags, stop in
            let range = NSRange(location: match!.range.location, length: match!.range.length)
            let line = (editorView.textView.text as NSString).substring(with: range)
            
            headings.append(line)
        }
        
        dump(headings)
        
        
        var items = [ContentItem]()
        
        let trimRegex = try! NSRegularExpression(pattern: headingsTrimPattern, options: [.anchorsMatchLines])
        
        
        for line in headings {
            if line.hasPrefix("# ") {
                let line = String(line.dropFirst(2))
                let item = ContentItem(name: line)
                items.append(item)
                
            } else if line.hasPrefix("## ") {
                let line = String(line.dropFirst(3))
                let item = ContentItem(name: line)
                items.last?.children
                    .append(item)
                
            } else if line.hasPrefix("### ") {
                let line = String(line.dropFirst(4))
                let item = ContentItem(name: line)
                items.last?.children
                    .last?.children
                    .append(item)
            } else if line.hasPrefix("#### ") {
                let line = String(line.dropFirst(5))
               let item = ContentItem(name: line)
               items.last?.children
                   .last?.children
                   .last?.children
                   .append(item)
           } else if line.hasPrefix("##### ") {
               let line = String(line.dropFirst(6))
               let item = ContentItem(name: line)
               items.last?.children
                   .last?.children
                   .last?.children
                   .last?.children
                   .append(item)
           } else if line.hasPrefix("###### ") {
               let line = String(line.dropFirst(7))
               let item = ContentItem(name: line)
               items.last?.children
                   .last?.children
                   .last?.children
                   .last?.children
                   .last?.children
                   .append(item)
           }
            
        }
        
        self.headings = items
 
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
    let id: UUID = UUID()
    var name: String = ""
    var children = [ContentItem]()

    var isExpanded = true
    
    init(name: String) {
        self.name = name
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
    @State var selection: ContentItem.ID? = nil
    
        var body: some View {
            List(selection: $selection) {
                ForEach($items, id: \.id) { $item in
                    
//                    Section(content: {
//                        if item.containsChildren {
//                            NestedView(items: $item.children)
//                        }
//                    }, header: {
//                        Text(item.name)
//                            .font(.title)
//                    })
                    
                    Section {
                        if item.containsChildren {
                            DisclosureGroup(item.name) {
                                NestedView(items: $item.children)
                            }
                            .listRowBackground(Color.clear)
                        } else {
                            Text(item.name)
                                .listRowBackground(Color.clear)
                        }
                    }
                    
                   
                }
            }
            .listStyle(PlainListStyle())
            .onChange(of: selection) { oldValue, newValue in
                guard let newValue = newValue else { return }
                
//                logger.debug("selection: \(newValue.name)")
//                
//                selection = nil
            }
            .background(ThemeState.shared.theme.dynamicCanvasColor)
            .foregroundColor(Color.secondary)
            .lineLimit(2)
            
        }
}

struct IndexGroupView: View {
    
    @Binding var item: ContentItem
    @State var isExpanded = true
    
    var body: some View {
        DisclosureGroup(item.name, isExpanded: $isExpanded) {
            NestedView(items: $item.children)
        }
        .listRowBackground(Color.clear)
    }
}

struct NestedView: View {
    @Binding var items: [ContentItem]
    
    var body: some View {
        ForEach($items, id: \.id) { $item in
            if item.containsChildren {
                DisclosureGroup(item.name) {
                    NestedView(items: $item.children)
                }
                .listRowBackground(Color.clear)
            } else {
                Text(item.name)
                    .listRowBackground(Color.clear)
            }
        }
    }
}



struct MyDisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                    Spacer()
                    Text(configuration.isExpanded ? "hide" : "show")
                        .foregroundColor(.accentColor)
                        .font(.caption.lowercaseSmallCaps())
                        .animation(nil, value: configuration.isExpanded)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}
