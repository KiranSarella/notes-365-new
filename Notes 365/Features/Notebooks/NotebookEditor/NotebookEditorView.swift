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
//    @FocusState private var isTextFieldFocused: Bool
//    @State private var editorView = EditorView()

    @State var autoSaveTimer: Timer.TimerPublisher = Timer.publish(every: 5, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil
    
    
    
//    private let autoSaveTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // 1 min
    
    var body: some View {
        VStack {
            if notebookM == nil {
                Text("No notebook selected")
            } else {
                VStack(alignment: .leading) {
                    
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
                        
                        MarkdownEditorView(contentEditedDate: $editorState.contentEditedDate, theme: $editorState.theme, baseContent: $editorState.baseContent, handler: { getText in
                            // attach ref.
                            editorState.getTextHandler = getText
                            
//                            let text = getText()
                            
                        })
                            .onAppear(perform: {
                                self.instantiateTimer()
                            })
                            .onDisappear(perform: {
                                
                                Task {
                                    await editorState.saveContentChanges()
                                }
                                
                                //                    Task {
                                //                        await editorState.notebook.closeDocument()
                                //                    }
                                self.cancelTimer()
                            })
                    }
                }
                
                
            }
        }
//        .navigationTitle(notebookM?.name ?? "")
        .onAppear {
            editorState.getNotebook = {
                return notebookM?.notebook
            }
        }
        .onChange(of: notebookM) { newValue in
            // existing notebook steps
            // save existing changes if required
            Task {
                await editorState.saveContentChanges()
                
                editorState.baseVersionCreated = false
                
                
                // new notebook steps
                guard let newValue = newValue else { return }
                
                await editorState.loadContent(for: newValue.notebook)
                
                
                editorState.getNewContent = {
                    return await MainActor.run {
                        editorState.getTextHandler!()
//                        editorView.text
                    }
//                    return editorView.text
                }
                
                // base version verifiation on every time notebook editor appear
                // usefull if new day entered.
                editorState.configBaseVersionIfNecessary(newValue.notebook)
                
                
                
//                DispatchQueue.main.async {
//                    Task {
                
                        
//                    }
//                }
            }
            
           
            
        }
        
        .onReceive(autoSaveTimer, perform: { _ in
//            print("auto Save Timer")
            Task {
                await editorState.saveContentChanges()
            }
            
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

