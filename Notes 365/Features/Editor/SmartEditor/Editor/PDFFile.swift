//
//  PDFFile.swift
//  Notes 365
//
//  Created by kiran ipc on 20/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct PDFFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.pdf]
    // by default our document is empty
    var data: Data
    
    // a simple initializer that creates new, empty documents
    init(data: Data) {
        self.data = data
    }
    
    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = data
        } else {
            self.data = Data()
        }
    }
    
    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
