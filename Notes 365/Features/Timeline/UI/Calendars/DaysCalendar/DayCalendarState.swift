//
//  DayCalendarState.swift
//  Notes 365
//
//  Created by kiran ipc on 19/05/23.
//

import SwiftUI

struct DayDateItem: Identifiable {
    let id = UUID()
    private(set) var day: Int = 0
    private(set) var isToday: Bool = false
    var canShow: Bool = false
    var date: Date
    
    init(date: Date, canShow: Bool) {
        self.date = date
        self.day = date.getDay()
        self.isToday = (date.isSameDayAs(Date.now))
        self.canShow = canShow
    }
}

extension DayDateItem: Hashable {}

@Observable
class DayCalendarState {
    var dateTitle: String = Date().string(withFormat: "MMMM, YYYY")
    var dayitems = [DayDateItem]()
    var dayDate: DayDate
    var selectedDayDate: DayDate?
    var displayCounte: Int = 0
    private var calendar = Calendar.current
    
    init() {
        dayDate = DayDate(date: Date())
        selectedDayDate = nil
    }
    
    func isSelected(_ dayItem: DayDateItem) -> Bool {
        if !dayItem.canShow { return false }
        guard let selectedDayDate = selectedDayDate else { return false }
        return dayItem.date.isSameDayAs(selectedDayDate.date)
    }
    
    func updateDisplay() {
        // title
        dateTitle = dayDate.date.string(withFormat: "MMMM, YYYY")
        // date items
        // for given date get
        let dates = getCalenderDates(dayDate.date)
        var newItems = [DayDateItem]()
        for date in dates {
            let isSameMonth = (dayDate.date.getMonth() == date.getMonth())
            let item = DayDateItem(date: date, canShow: isSameMonth)
            newItems.append(item)
        }
        dayitems = newItems
    }
    
    private func getCalenderDates(_ inputDate: Date) -> [Date] {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: inputDate),
            let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { fatalError() }
        let startDate = monthFirstWeek.start
        let endDate = Calendar.current.date(byAdding: .day, value: 41, to: monthFirstWeek.start)!
        var nextDate = startDate
        var dates = [startDate]
        while nextDate < endDate {
            nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate)!
            dates.append(nextDate)
        }
        return dates
    }
    
    // MARK: - navigation
    func setToday() {
        dayDate = DayDate(date: Date())
        selectedDayDate = dayDate
        updateDisplay()
    }
    
    func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: dayDate.date) else { return }
        dayDate = DayDate(date: newDate)
        updateDisplay()
    }
    
    func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: dayDate.date) else { return }
        dayDate = DayDate(date: newDate)
        updateDisplay()
    }

    // MARK: - Selection
    func makeSelection(_ dayDateItem: DayDateItem) {
        dayDate = DayDate(date: dayDateItem.date)
        selectedDayDate = dayDate
    }
}
