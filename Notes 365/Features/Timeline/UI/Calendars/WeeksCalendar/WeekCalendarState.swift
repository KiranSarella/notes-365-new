//
//  WeekCalendarState.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation
import SwiftUI

@Observable
class WeekCalendarState {
    
    
}


/// take .end date to show correct month visually.
public struct WeekGrid: Hashable {
    let weekNumber: Int
    let weekDays: [Date]
    
    func isCurrentWeek() -> Bool {
        // check same year
        // check same month
        // today should be in between weekdates
        let today = Date()
        
        let start = self.weekDays.first!
        let end = self.weekDays.last!
        
        if start.getYear() == today.getYear() &&
            start.getMonth() == today.getMonth() {
            // today should be in between that week dates
            if today >= start && today <= end {
                return true
            }
        }
        
        return false
    }
    
    var weekDate: WeekDate {
        WeekDate(date: weekDays.first!)
    }
}

func getWeekDates(_ inputDate: Date) -> [WeekGrid] {
    let calendar = Calendar.current
    let calendarDates = getCalenderDates(forMonth: inputDate)
    var weeks = [WeekGrid]()
    for row in 0..<6 {
        let startIndex = 7 * row
        let endIndex = startIndex + 7
        // if first date is within that month then only take that week
        if calendarDates[startIndex].getMonth() > inputDate.getMonth() && calendarDates[startIndex].getYear() == inputDate.getYear() {
            break
        }
        let dates = Array(calendarDates[startIndex..<endIndex])
        let weekNumber = calendar.component(.weekOfYear, from: dates[3])
//        let weekNumber = calendar.component(.weekOfYear, from: dates[0])
        weeks.append(WeekGrid(weekNumber: weekNumber, weekDays: dates))
    }
    return weeks
}


func getWeek(_ inputDate: Date) -> WeekGrid {
    
    let calendar = Calendar.current
    let calendarDates = getCalenderDates(forMonth: inputDate)
    let inputWeekNumber = calendar.component(.weekOfYear, from: inputDate)
    
    var week: WeekGrid!
    
    for row in 0..<6 {
        
        let startIndex = 7 * row
        let endIndex = startIndex + 7
        
        let dates = Array(calendarDates[startIndex..<endIndex])
        
        let weekNumber = calendar.component(.weekOfYear, from: dates[3])    // take center one as a weeknumber
        
        if weekNumber == inputWeekNumber {
            week = WeekGrid(weekNumber: weekNumber, weekDays: dates)
            break
        }
    }
    
    return week
}

func getCalenderDates(forMonth date: Date) -> [Date] {
    
    guard
        let monthInterval = Calendar.current.dateInterval(of: .month, for: date),
        let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start)
    else { fatalError() }
    
    let startDate = monthFirstWeek.start
    let endDate = Calendar.current.date(byAdding: .day, value: 41, to: monthFirstWeek.start)!   // 6 * 7 gripd
    
    var date = startDate
    
    var dates = [date]
    
//    _ = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end)
    
    while date < endDate {
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        dates.append(date)
    }
    
    return dates
}
