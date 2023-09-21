//
//  Mode.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation


public enum SidebarItem: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
    
    case timeline
    case notebooks
//    case themes
//    case formatingSymbols
//    case feedback
    
}

public enum Mode: String, CaseIterable, Identifiable {
    case timeline = "Timeline"
    case noteBooks = "Notebooks"
    
    public var id: String { self.name }
    
    var name: String {
        switch self {
        case .timeline: return "Timeline"
        case .noteBooks: return "Notebooks"
        }
    }
    
    var image: String {
        switch self {
        case .timeline: return "rectangle.stack" //"square.stack" //"line.horizontal.3"
        case .noteBooks: return "books.vertical"
        }
    }
    
    static func getMode(id: String?) -> Mode? {
        guard let id = id else { return nil }
        return Mode(rawValue: id)
    }
    
}

//
//extension Mode: Comparable {
//
//    public static func < (lhs: Mode, rhs: Mode) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//}
