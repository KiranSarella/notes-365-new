//
//  ContentSearchInteractor.swift
//  Notes 365
//
//  Created by kiran ipc on 30/11/23.
//

import Foundation

protocol ContentSearchInteractor {
    func fetchSearchResults(for text: String) -> [NotebookContentB]?
}

extension ContentSearchBusiness: ContentSearchInteractor {
    
}
