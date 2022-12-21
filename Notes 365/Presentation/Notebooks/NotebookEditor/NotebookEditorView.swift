//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI

struct NotebookEditorView: View {
    
//    @Environment(\.scenePhase) var scenePhase
    
    @Binding var notebookM: NotebookM?
    @StateObject private var editorState = NotebookEditorState()
    @FocusState private var isTextFieldFocused: Bool
    @State private var editorView = EditorView()

    private let autoSaveTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // 1 min
    
    var body: some View {
        VStack {
            if notebookM == nil {
                Text("No notebook selected")
            } else {
                VStack(alignment: .leading) {
                    // formatting bar view
                    FormattingOptionsView(editorView: $editorView, contentEdited: $editorState.contentEdited)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .backgroundStyle(.regularMaterial)
                        .background(.background)
                        .padding(.bottom, -7)
                    
                    if editorState.isFetchingData {
                        Text("loading..")
                    } else {
                        EditorUI(theme: editorState.theme, text: editorState.baseContent, editorView: $editorView, contentEdited: $editorState.contentEdited)
                        .font(Font.body)
                        .focused($isTextFieldFocused)
                        .onChange(of: isTextFieldFocused) { isFocused in
                            if isFocused {
                                // began editing...
                                print(isTextFieldFocused)
                                editorState.setBaseVersion(notebookM!.notebook)
                            } else {
                                // ended editing...
                                //                            print(isTextFieldFocused)
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    editorState.notebook = notebookM!.notebook
                    editorState.loadContent()
                    
                    editorView.textView.string = editorState.baseContent
                    
                    editorState.getNewContent = {
                        return editorView.textView.string
                    }
                })
                .onDisappear(perform: {
                    isTextFieldFocused = false
                    editorState.saveContentChanges()
                })
                .onChange(of: editorState.theme, perform: { newValue in
                    editorView.updateTheme(theme: editorState.theme)
                })
                .navigationTitle(notebookM?.name ?? "")
                .toolbar {
                    Toggle("Mode", isOn: $editorState.showSymbols)
                        .toggleStyle(.switch)
                        .help(editorState.showSymbols == false ? "Show Symbols" : "Hide Symbols")
                        .onChange(of: editorState.showSymbols) { newValue in
                            if newValue {
                                editorState.editorType = .markdown
                            } else {
                                editorState.editorType = .smart
                            }
                            
                            editorView.editorType = editorState.editorType
                        }
                }
                .pickerStyle(SegmentedPickerStyle())
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
            }
        }
        .onAppear {
            editorState.getNotebook = {
                return notebookM?.notebook
            }
        }
        .onChange(of: notebookM) { newValue in
            // save existing changes if required
            editorState.saveContentChanges()
            isTextFieldFocused = false
            
            guard let newValue = newValue else { return }
            editorState.notebook = newValue.notebook
            
            editorState.loadContent()
            editorView.textView.string = editorState.baseContent
        }
        .onReceive(autoSaveTimer, perform: { _ in
            editorState.saveContentChanges()
        })
//        .onChange(of: scenePhase) { phase in
//            switch phase {
//            case .background:
//                print("App is in background")
//            case .active:
//                print("App is Active")
//            case .inactive:
//                print("App is Inactive")
//            @unknown default:
//                print("New App state not yet introduced")
//            }
//        }
    }
    
}

