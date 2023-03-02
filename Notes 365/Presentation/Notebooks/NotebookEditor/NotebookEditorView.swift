//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI
import Combine

struct NotebookEditorView: View {
    
//    @Environment(\.scenePhase) var scenePhase
    
    @Binding var notebookM: NotebookM?
    @ObservedObject var editorState: NotebookEditorState
    @FocusState private var isTextFieldFocused: Bool
    @State private var editorView = EditorView()

    @State var autoSaveTimer: Timer.TimerPublisher = Timer.publish(every: 5, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil
    
    
//    private let autoSaveTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 1 min
    
    var body: some View {
        VStack {
            if notebookM == nil {
                Text("No notebook selected")
            } else {
                VStack(alignment: .leading) {
                    // formatting bar view
                    FormattingOptionsView(editorView: $editorView, contentEditedDate: $editorState.contentEditedDate)
//                        .frame(height: 40)
                        .padding(.horizontal)
                        .backgroundStyle(.regularMaterial)
                        .background(.background)
//                        .padding(.bottom, -7)
//                        .padding(.bottom, -7)
                    
                    if editorState.isFetchingData {
                        
                        Spacer()
                        HStack(alignment: .center) {
                            Spacer()
                            Text("loading..")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                        
                    } else {
                        EditorUI(theme: editorState.theme, text: editorState.baseContent, editorView: $editorView, contentEditedDate: $editorState.contentEditedDate)
                        .font(Font.body)
                        .focused($isTextFieldFocused)
                    }
                }
                .onAppear(perform: {
//                    if notebookM != nil {
//                        DispatchQueue.main.async {
//                            Task {
//                                await editorState.loadContent(for: notebookM!.notebook)
//                                editorView.text = editorState.baseContent
//                                editorState.getNewContent = {
//                                    return editorView.text
//                                }
//                            }
//                        }
//                    }
                    self.instantiateTimer()
                })
                .onDisappear(perform: {
                    isTextFieldFocused = false
                    editorState.saveContentChanges()
                    Task {
                        await editorState.notebook.closeDocument()
                    }
                    self.cancelTimer()
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
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            editorState.getNotebook = {
                return notebookM?.notebook
            }
        }
        .onChange(of: notebookM) { newValue in
            // existing notebook steps
            // save existing changes if required
            editorState.saveContentChanges()
            isTextFieldFocused = false
            editorState.baseVersionCreated = false
            
            // new notebook steps
            guard let newValue = newValue else { return }
            
            DispatchQueue.main.async {
                Task {
                    await editorState.loadContent(for: newValue.notebook)
                    editorView.text = editorState.baseContent
                    editorState.getNewContent = {
                        return editorView.text
                    }
                }
            }
            
            // base version verifiation on every time notebook editor appear
            // usefull if new day entered.
            editorState.configBaseVersionIfNecessary(newValue.notebook)
        }
        .onChange(of: editorState.baseContent, perform: { newValue in
            editorView.text = newValue
        })
        .onReceive(autoSaveTimer, perform: { _ in
            print("auto Save Timer")
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
    
    func instantiateTimer() {
        self.autoSaveTimer = Timer.publish(every: 5, on: .main, in: .common)
        self.connectedTimer = self.autoSaveTimer.connect()
        return
    }
    
    func cancelTimer() {
        self.connectedTimer?.cancel()
        return
    }
}

