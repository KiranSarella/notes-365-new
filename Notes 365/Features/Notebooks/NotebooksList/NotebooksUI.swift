//
//  NotebooksUI.swift
//  Notes 365
//
//  Created by kiran ipc on 17/11/23.
//

import SwiftUI

struct NotebooksUI: View {
    
    var controller: NotebooksController
    var viewModel: NotebooksViewModel
    
    var body: some View {
        Text(viewModel.text)
        Button {
            viewModel.text = "edited text"
            controller.validateFileName(string: viewModel.text)
        } label: {
            Text("validate")
        }
    }
}

//#Preview {
//    NotebooksUI(viewModel: NotebooksViewModel())
//}

