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


class DayCalendarState: ObservableObject {
    
    @Published var dateTitle: String = Date().string(withFormat: "MMMM, YYYY")
    @Published var dayitems = [DayDateItem]()
    @Published var selectedDate: Date
    
    private(set) var displayingDate: Date
    
    
    private var calendar = Calendar.current
    
    init() {
        displayingDate = Date()
        selectedDate = displayingDate
        
        updateDisplay()
    }
    
    func setDisplayDate(_ newDate: Date) {
        displayingDate = newDate
        selectedDate = displayingDate
        updateDisplay()
    }
    
    func isSelected(_ dayItem: DayDateItem) -> Bool {
        if !dayItem.canShow {
            return false
        }
        
        return dayItem.date.isSameDayAs(selectedDate)
    }
    
    
    func updateDisplay() {
        // title
        dateTitle = displayingDate.string(withFormat: "MMMM, YYYY")
        // date items
        
        // for given date get
        let dates = getCalenderDates(displayingDate)
        var newItems = [DayDateItem]()
        for date in dates {
            let isSameMonth = (displayingDate.getMonth() == date.getMonth())
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
        
        print("dates count", dates.count)
        return dates
    }
    
    // MARK: - navigation
    func setToday() {
        displayingDate = Date()
        selectedDate = displayingDate
        updateDisplay()
    }
    
    func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: displayingDate) else { return }
        displayingDate = newDate
        updateDisplay()
    }
    
    func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: displayingDate) else { return }
        displayingDate = newDate
        updateDisplay()
    }

}
