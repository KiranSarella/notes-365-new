//
//  PathHelper.swift
//  Notes 365
//
//  Created by Kiran Sarella on 17/11/22.
//

import Foundation

func whereIsMySQLite() -> String? {
    let path = FileManager
        .default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .last?
        .absoluteString
        .replacingOccurrences(of: "file://", with: "")
        .removingPercentEncoding
    
    print(path ?? "Not found")
    
    return path
}

