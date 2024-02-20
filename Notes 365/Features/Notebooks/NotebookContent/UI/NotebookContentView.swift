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
    @Bindable var state: NotebookContentState // state is outside, bcz to save any changes after immediatly closed
    
    var body: some View {
        VStack(alignment: .leading) {
            if state.isFetchingData {
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
                SmartEditor(fileName: fileName, isReadonly: isReadOnly, searchText: searchText, contentEditedDate: $state.contentEditedDate, input: $state.input)
                .onAppear(perform: {
                    self.state.startAutoSaveTimer()
                })
                .onChange(of: EditorOutputBuffer.shared.output) { oldValue, newValue in
                    print(newValue)
                    state.contentEditedDate = DateTime.now()
                }
            }
        }
        .onAppear {
            Task {
                // new notebook steps
                state.loadContent(for: notebookId)
                state.fileName = fileName
                if isReadOnly == false {
                    state.notifyNotebookOpen()
                }
            }
        }
        .onDisappear {
            Task {
                state.invalidateAutoSaveTimer()
                state.saveChangesIfModified()
//                self.editorState.cancelAutoSaveTimer()
//                await editorState.saveContentChanges()
            }
        }
    }
    
    
}
