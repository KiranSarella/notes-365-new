//
//  MonthCalendarState.swift
//  Notes 365
//
//  Created by kiran ipc on 25/11/23.
//

import Foundation
import SwiftUI

@Observable
class MonthCalendarState {
    
    
}

extension MonthGridView {
    
    func refreshMonthGrid(monthDate: MonthDate) {
        var monthDatesList = [MonthGridDate]()
        let year = monthDate.start.string(withFormat: "YYYY")
        for monthIndex in monthSymbols.indices {
            let monthSymbol = monthSymbols[monthIndex]
            let month = monthIndex + 1
            let day = 1
            let dateStr = "\(year)-\(month)-\(day)"
            let monthStartDate = dateStr.toUTCDate(withFormat: "yyyy-MM-dd")!
            monthDatesList.append(MonthGridDate(date: monthStartDate, symbol: monthSymbol, number: month))
        }
        monthGridDates = monthDatesList
    }
    
    func getMonthStartDate(for month: Int, year: String) -> Date {
        let month = month
        let day = 1
        let dateStr = "\(year)-\(month)-\(day)"
        let monthStartDate = dateStr.toUTCDate(withFormat: "yyyy-MM-dd")!
        return monthStartDate
    }
    
    func isCurrentMonth(_ month: Int) -> Bool {
        // check same year
        // check same month
        let today = Date()
        if monthDate.start.getYear() == today.getYear() &&
            month == today.getMonth() {
            return true
        }
        return false
    }
    
    func isSelectedMonth(_ month: Int) -> Bool {
        // selected date's year, month should match to UI month, year
        if selectedMonthDate?.start.getYear() == monthDate.start.getYear() &&
            selectedMonthDate?.start.getMonth() == month {
            return true
        }
        return false
    }
}
