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
    @Bindable var editorState: NotebookEditorState

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
                    self.editorState.startAutoSaveTimer()
//                    self.instantiateTimer()
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
                self.editorState.cancelAutoSaveTimer()
                await editorState.saveContentChanges()
            }
        }
    }
    
    
}
