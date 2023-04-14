//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI
import Combine

struct NotebookEditorView: View {
    
//        @Environment(\.scenePhase) var scenePhase
    @Binding var notebookM: NotebookM
    @ObservedObject var editorState: NotebookEditorState

    @State var autoSaveTimer: Timer.TimerPublisher = Timer.publish(every: 5, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil
    
    var body: some View {
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
//        .navigationTitle(notebookM?.name ?? "")
        .onAppear {
            Task {
                // new notebook steps
                await editorState.loadContent(for: notebookM.notebook)
                editorState.getNewContent = {
                    return await MainActor.run {
                        editorState.getTextHandler!()
                    }
                }
            }
        }
        .onChange(of: notebookM) { newValue in
            Task {
                // existing notebook steps
                // save existing changes if required
                await editorState.saveContentChanges()
                
                // new notebook steps
                await editorState.loadContent(for: newValue.notebook)
                editorState.getNewContent = {
                    return await MainActor.run {
                        editorState.getTextHandler!()
                    }
                }
            }
        }
        .onReceive(autoSaveTimer, perform: { _ in
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
    
    
}


// MARK: - Auto Save timer
extension NotebookEditorView {
    
    func instantiateTimer() {
        self.autoSaveTimer = Timer.publish(every: 5, on: .main, in: .common)
        self.connectedTimer = self.autoSaveTimer.connect()
    }
    
    func cancelTimer() {
        self.connectedTimer?.cancel()
    }
}
