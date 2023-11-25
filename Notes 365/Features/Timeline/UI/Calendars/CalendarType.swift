//
//  CalendarType.swift
//  Notes 365
//
//  Created by Kiran Sarella on 12/11/22.
//

import Foundation

public enum CalendarType: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    
    public var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
    
    static func getCalendarType(id: String?) -> CalendarType? {
        guard let id = id else { return nil }
        return CalendarType(rawValue: id)
    }
}
