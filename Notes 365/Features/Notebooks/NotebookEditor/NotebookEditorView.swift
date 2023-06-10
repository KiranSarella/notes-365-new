//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI
import Combine

//struct NotebookEditorWrapperView: View {
//    
//    var body: some View {
//        
//        
//    }
//}

struct NotebookEditorView: View {
    
    var notebookM: NotebookM
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
                MarkdownEditorView(fileName: notebookM.name, isDeleted: notebookM.isDeleted, contentEditedDate: $editorState.contentEditedDate, theme: $editorState.theme, baseContent: $editorState.baseContent, handler: { getText in
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
                    self.cancelTimer()
                })
            }
        }
//        .navigationTitle(notebookM?.name ?? "")
        .onAppear {
            Task {
                // new notebook steps
                await editorState.loadContent(for: notebookM.notebookRef)
                editorState.getNewContent = {
                    return await MainActor.run {
                        editorState.getTextHandler!()
                    }
                }
            }
        }
        .onDisappear {
            Task {
                await editorState.saveContentChanges()
            }
        }
        .onChange(of: notebookM) { newValue in
            Task {
                // existing notebook steps
                // save existing changes if required
                await editorState.saveContentChanges()
                
                // new notebook steps
                await editorState.loadContent(for: newValue.notebookRef)
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
