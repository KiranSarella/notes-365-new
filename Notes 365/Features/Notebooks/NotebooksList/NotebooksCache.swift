//
//  NotebooksCache.swift
//  Notes 365
//
//  Created by kiran ipc on 21/07/23.
//

import Foundation

class NotebooksCache {
    static let shared = NotebooksCache()
    var flatNotebooks = [String: Notebook]()
}
