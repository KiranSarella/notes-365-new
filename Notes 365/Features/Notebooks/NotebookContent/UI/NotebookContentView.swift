//
//  DetailView.swift
//  Tertiary
//
//  Created by Kiran Sarella on 25/06/21.
//

import SwiftUI
import Combine

struct NotebookContentView: View {
    var isReadOnly: Bool
    var notebookId: UUID
    var fileName: String
    var searchText: String?
    @Bindable var notebookContentState: NotebookContentState
    
    var body: some View {
        VStack(alignment: .leading) {
            if notebookContentState.isFetchingData {
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
                SmartEditor(fileName: fileName, isReadonly: isReadOnly, searchText: searchText, contentEditedDate: $notebookContentState.contentEditedDate, input: $notebookContentState.input, output: $notebookContentState.output)
                .onAppear(perform: {
                    self.notebookContentState.startAutoSaveTimer()
                })
                .onChange(of: notebookContentState.output) { oldValue, newValue in
                    print(newValue)
                    notebookContentState.contentEditedDate = DateTime.now()
                }
            }
        }
        .onAppear {
            Task {
                // new notebook steps
                notebookContentState.loadContent(for: notebookId)
//                editorState.getNewContent = {
//                    return await MainActor.run {
//                        editorState.getTextHandler!()
//                    }
//                }
            }
        }
        .onDisappear {
            Task {
                notebookContentState.invalidateAutoSaveTimer()
                notebookContentState.saveChangesIfModified()
//                self.editorState.cancelAutoSaveTimer()
//                await editorState.saveContentChanges()
            }
        }
    }
    
    
}
