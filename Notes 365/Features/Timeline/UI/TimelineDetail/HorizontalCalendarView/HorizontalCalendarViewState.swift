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
    
    init() {
        
    }
    
    func constructDateRanges() -> [TimelineDateRange] {
        logger.info("constructDateRanges")
        var ranges = [TimelineDateRange]()
        ranges.append(TimelineDateRange(title: "Today", type: .today, date: DateTime.now()))
        guard let firstEntryDate = timelineBusiness.getFirstAvailableTimelineDate() else {
            return ranges
        }
        logger.info("firstEntryDate: \(firstEntryDate)")
        if DateTime.now().dayBefore >= firstEntryDate {
            ranges.append(TimelineDateRange(title: "Previous 7 Days", type: .previousSevenDays, date: DateTime.now().dayBefore))
            logger.info("\(ranges.last?.title ?? "")")
        }
        
        var firstMonthDate = DateTime.now().startOfMonth()
        if firstMonthDate >= firstEntryDate {
            var count = 10
            while count > 0 && firstMonthDate >= firstEntryDate {
                ranges.append(TimelineDateRange(title: firstMonthDate.monthName, type: .month, date: firstMonthDate))
                logger.info("\(ranges.last?.title ?? "")")
                firstMonthDate = firstMonthDate.monthBefore
                count -= 1
            }
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
