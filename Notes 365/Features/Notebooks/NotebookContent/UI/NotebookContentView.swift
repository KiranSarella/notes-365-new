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
    @Bindable var editorState: NotebookContentState
    @Environment(\.dismiss) var dismiss
    
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
                
                SmartEditor(fileName: "", isReadonly: isReadOnly, contentEditedDate: $editorState.contentEditedDate, input: $editorState.input, output: $editorState.output)
                .onAppear(perform: {
//                    self.editorState.startAutoSaveTimer()
//                    self.instantiateTimer()
                })
                .onChange(of: editorState.output) { oldValue, newValue in
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
                await editorState.loadContent()
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
