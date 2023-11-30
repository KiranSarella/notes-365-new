//
//  ContentSearchProvider.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import Foundation

protocol ContentSearchStorageProvider {
    func fetchSearchResults(for text: String) throws -> [NotebookContentB]
}
