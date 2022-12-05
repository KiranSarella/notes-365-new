//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI

struct NotebookEditorView: View {
    @Binding var notebookM: NotebookM?
    @StateObject private var editorState = NotebookEditorState()
    @FocusState private var isTextFieldFocused: Bool
    @State var currentTextStyleAction: (TextStyleKey?, Any, Bool) = (.none, false, false)
    let autoSaveTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // 1 min
    
    @State private var editorView = EditorView()
    
    var body: some View {
        VStack {
            if notebookM == nil {
                Text("No notebook selected")
            } else {
                VStack(alignment: .leading) {
                    // formatting bar view
                    FormattingOptionsView(editorView: $editorView, currentTextStyleAction: $currentTextStyleAction)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .backgroundStyle(.regularMaterial)
                        .background(.background)
                        .padding(.bottom, -7)
                    
                    if editorState.isFetchingData {
                        Text("loading..")
                    } else {
                        EditorUI(theme: editorState.theme, text: $editorState.contentStr, editorView: $editorView, currentTextStyleAction: currentTextStyleAction,
                        completion: { txt in
                            // 500000000 = 0.5 sec
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000)) {
                                editorState.txt = txt
                                editorState.contentEdited = true
                            }
                        }, actionCompleted: {
                            // 500000000 = 0.5 sec
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000)) {
                                currentTextStyleAction = (nil, false, false)
                            }
                        })
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
                    // notify
                    var change = currentTextStyleAction.2
                    change.toggle()
                    currentTextStyleAction = (.textUpdate, true, change)
                })
                .onDisappear(perform: {
                    isTextFieldFocused = false
                    editorState.saveContentChanges()
                })
                .onChange(of: editorState.theme, perform: { newValue in
                    var change = currentTextStyleAction.2
                    change.toggle()
                    currentTextStyleAction = (.theme, newValue, change)
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
                            var change = currentTextStyleAction.2
                            change.toggle()
                            currentTextStyleAction = (.editorType, editorState.editorType, change)
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
            editorState.contentEdited = false
            
            // notify
            var change = currentTextStyleAction.2
            change.toggle()
            currentTextStyleAction = (.textUpdate, true, change)
        }
        .onReceive(autoSaveTimer, perform: { _ in
//            print("autoSaveTimer")
            editorState.saveContentChanges()
//            saveContentChanges(userSelectionState: userSelectionState)
        })
    }
    
}

