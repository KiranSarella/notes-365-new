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
    @State private var editorView = EditorView()
    @State private var editorType = EditorType.smart
    @State private var showSymbols = false
    @Binding var contentEditedDate: Date?
    @Binding var input: String
    @Binding var output: String
    @State private var showingPDFExporter = false
    @State private var pdfFileData: PDFFile = PDFFile(data: Data())
    @State private var selectedRange: NSRange = NSRange()
    
    var body: some View {
        VStack(alignment: .leading) {
            // formatting bar view
            FormattingOptionsView(editorView: $editorView, contentEditedDate: $contentEditedDate, selectedRange: $selectedRange)
                .padding(.horizontal)
                .backgroundStyle(.regularMaterial)
                .background(.background)
                .disabled(isReadonly)
            
            EditorViewUI(output: $output, text: $input, editorView: $editorView, contentEditedDate: $contentEditedDate, selectedRange: $selectedRange, isEditable: !isReadonly)
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
        }
//        .onAppear {
//            markdownEditorState.fileName = self.fileName
//        }
//        .onChange(of: markdownEditorState.fileName, { oldValue, newValue in
//            editorView.fileName = newValue
//        })
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
                            print("pdf export failed")
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
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
}


//struct MarkdownEditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        MarkdownEditorView()
//    }
//}
