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
                
                SmartEditor(fileName: "", isReadonly: isReadOnly, contentEditedDate: $notebookContentState.contentEditedDate, input: $notebookContentState.input, output: $notebookContentState.output)
                .onAppear(perform: {
                    self.notebookContentState.startAutoSaveTimer()
                })
                .onChange(of: notebookContentState.output) { oldValue, newValue in
                    print(newValue)
                }
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button {
//                            dismiss()
//                        } label: {
//                            Text("Done")
//                        }
//
//                    }
//                }
            }
        }
//        .navigationTitle(notebookM?.name ?? "")
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
//                self.editorState.cancelAutoSaveTimer()
//                await editorState.saveContentChanges()
            }
        }
    }
    
    
}
