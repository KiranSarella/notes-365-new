//
//  HorizontalCalendarViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 27/11/23.
//

import Foundation
import SwiftUI


@Observable
class HorizontalCalendarViewState {
    let timelineBusiness = BusinessFactory.timelineInteractor()
    var dateRanges = [TimelineDateRange]()
    var selectedDateRange: TimelineDateRange?
    var loadedDate: Date = DateTime.now()
//    var disableSelection = false
    
    init() {
        
    }
    
    func constructDateRanges() -> [TimelineDateRange] {
        logger.info("constructDateRanges")
        var ranges = [TimelineDateRange]()
        ranges.append(TimelineDateRange(title: "Today", type: .today, date: DateTime.now()))
        // add previous 7 days by default
        ranges.append(TimelineDateRange(title: "Previous 7 Days", type: .previousSevenDays, date: DateTime.now().dayBefore))
        logger.debug("\(ranges.last?.title ?? "")")
        // add current month by default
        var currenMonth = DateTime.now().startOfMonth()
        ranges.append(TimelineDateRange(title: "This Month", type: .month, date: currenMonth))
        logger.info("\(ranges.last?.title ?? "")")
        // populate previous 6 months
        currenMonth = currenMonth.monthBefore
        var count = 6
        while count > 0 {
            ranges.append(TimelineDateRange(title: currenMonth.monthName, type: .month, date: currenMonth))
            logger.debug("\(ranges.last?.title ?? "")")
            currenMonth = currenMonth.monthBefore
            count -= 1
        }
        return ranges
    }
    
    func isSelected(input: TimelineDateRange) -> Bool {
        guard let selectedDateRange = selectedDateRange else { return false }
        return selectedDateRange == input
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
}
