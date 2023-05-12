//
//  MarkdownEditorView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/04/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct MarkdownEditorView: View {
    
    var fileName: String
    @StateObject var markdownEditorState = MarkdownEditorViewState()
    @FocusState private var isTextFieldFocused: Bool
    @State private var editorView = EditorView()
    
    @State private var editorType = EditorType.smart
    @State private var showSymbols = false
    
    @Binding var contentEditedDate: Date?
    @Binding var theme: MarkdownTheme
    @Binding var baseContent: String
    
    var handler: (( @escaping () -> String) -> ())
    
    @State private var showingExporter = false
    
    @State private var pdfFileData: PDFFile = PDFFile(data: Data())
    
    var body: some View {
        
        VStack(alignment: .leading) {
            // formatting bar view
            FormattingOptionsView(editorView: $editorView, contentEditedDate: $contentEditedDate)
                .padding(.horizontal)
                .backgroundStyle(.regularMaterial)
                .background(.background)
            
            EditorViewUI(theme: theme, text: baseContent, editorView: $editorView, contentEditedDate: $contentEditedDate)
                .font(Font.body)
                .focused($isTextFieldFocused)
        }
        .onAppear {
            
            markdownEditorState.fileName = self.fileName
            
            handler({
                return editorView.text
            })
        }
        .onChange(of: markdownEditorState.fileName, perform: { newValue in
            editorView.fileName = newValue
        })
        .onChange(of: theme, perform: { newValue in
            editorView.updateTheme(theme: theme)
        })
        .onChange(of: baseContent, perform: { newValue in
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
                    .onChange(of: showSymbols) { newValue in
                        if newValue {
                            editorType = .markdown
                        } else {
                            editorType = .smart
                        }
    
                        editorView.editorType = editorType
                    }
            }
            // menu options
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        if let pdfData = editorView.generatePDFData() {
                            pdfFileData = PDFFile(data: pdfData)
                            showingExporter = true
                        } else {
                            print("pdf export failed")
                        }
                    } label: {
                        Text("Export to PDF")
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
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .navigationBarTitleDisplayMode(.inline)
        .fileExporter(isPresented: $showingExporter, document: pdfFileData, contentType: .pdf, defaultFilename: fileName) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
}

struct PDFFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.pdf]
    
    // by default our document is empty
    var data: Data
    
    // a simple initializer that creates new, empty documents
    init(data: Data) {
        self.data = data
    }
    
    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = data
        } else {
            self.data = Data()
        }
    }
    
    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

//struct MarkdownEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        MarkdownEditorView()
//    }
//}
