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
    
    var listDisplayState: ListSourceType
//    @Binding var notebookM: Notebook
//    var notebookM: Notebook
    @Bindable var editorState: NotebookEditorState

    @State var autoSaveTimer: Timer.TimerPublisher = Timer.publish(every: 10, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil
    
    var isDeleted: Bool {
        listDisplayState == .deletedItems
    }
    
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
                MarkdownEditorView(fileName: editorState.notebook!.name, isDeleted: isDeleted, contentEditedDate: $editorState.contentEditedDate, theme: $editorState.theme, baseContent: $editorState.baseContent, handler: { getText in
                    // attach ref.
                    editorState.getTextHandler = getText
                })
                .onAppear(perform: {
                    self.instantiateTimer()
                })
                .onDisappear(perform: {
                    Task {
                        self.cancelTimer()
                        await editorState.saveContentChanges()
                    }
                })
            }
        }
//        .navigationTitle(notebookM?.name ?? "")
        .onAppear {
            Task {
                // new notebook steps
                await editorState.loadContent()
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
//        .onChange(of: editorState.notebook) { newValue in
//            Task {
//                // existing notebook steps
//                // save existing changes if required
//                await editorState.saveContentChanges()
//                
//                // new notebook steps
//                await editorState.loadContent(for: newValue)
//                editorState.getNewContent = {
//                    return await MainActor.run {
//                        editorState.getTextHandler!()
//                    }
//                }
//            }
//        }
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
