//
//  HorizontalCalendarViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation
import SwiftUI

enum TopFilterType {
    case dateRange
    case folder
    
    var icon: String {
        switch self {
        case .dateRange:
            "calendar"
        case .folder:
            "folder"
        }
    }
}

protocol TopFilterOption: Identifiable, Equatable {
    var id: UUID { get set }
    var title: String { get set }
    var filterType: TopFilterType { get set }
}

struct TimelineDateRange: TopFilterOption {
    var id = UUID()
    var title: String
    var filterType: TopFilterType
    
    let type: TimelineDateRangeType
    let date: Date
}

@Observable
class HorizontalCalendarViewState {
    let timelineBusiness = BusinessFactory.timelineInteractor()
//    var dateRanges = [TimelineDateRange]()
    var dateRanges = [any TopFilterOption]()
    var list = [any TopFilterOption]()
    var selectedDateRange: (any TopFilterOption)?
    var loadedDate: Date = DateTime.now()
//    var disableSelection = false
    
    init() {
        
    }
    
    func constructDateRanges() -> [TimelineDateRange] {
        logger.info("constructDateRanges")
        var ranges = [TimelineDateRange]()
        
        let today = TimelineDateRange(title: "Today", filterType: .dateRange, type: .today, date: DateTime.now())
        ranges.append(today)
        
        // add previous 7 days by default
        let sevenDays = TimelineDateRange(title: "Previous 7 Days", filterType: .dateRange, type: .previousSevenDays, date: DateTime.now().dayBefore)
        ranges.append(sevenDays)
        
        // add current month by default
        var currenMonth = DateTime.now().startOfMonth()
        let currentMonthRange = TimelineDateRange(title: "This Month", filterType: .dateRange, type: .month, date: currenMonth)
        ranges.append(currentMonthRange)
        
        // populate previous 6 months
        currenMonth = currenMonth.monthBefore
        var count = 6
        while count > 0 {
            let monthRange = TimelineDateRange(title: currenMonth.monthName, filterType: .dateRange, type: .month, date: currenMonth)
            ranges.append(monthRange)
            currenMonth = currenMonth.monthBefore
            count -= 1
        }
        return ranges
    }
    
    func isSelected(input: any TopFilterOption) -> Bool {
        guard let selectedDateRange = selectedDateRange else { return false }
        
        if let input = input as? TimelineDateRange {
            if let selectedDateRange = selectedDateRange as? TimelineDateRange {
                return selectedDateRange == input
            }
        }
        
        return false
//        return selectedDateRange == input
    }
    
    func getDates(for dateRange: TimelineDateRange) -> [Date] {
        switch dateRange.type {
        case .today:
            return [DateTime.now()]
        case .previousSevenDays:
            var today = DateTime.now()
            var dates = [Date]()
            for _ in 0..<7 {
                today = today.dayBefore
                dates.append(today)
            }
            return dates
        case .month:
            return dateRange.date.getDaysOfMonth()
        }
    }
    
    func topLevelFolders() -> [any TopFilterOption] {
        []
    }
}
