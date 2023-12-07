//
//  TimelineStateTwo.swift
//  MyNotes
//
//  Created by Kiran Sarella on 21/10/21.
//

import Foundation
import SwiftUI

func getWeekStartEndDates(date: Date) -> (Date, Date) {
    
    guard
        let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: date)
    else { fatalError() }
    
    let startDate = weekInterval.start
    let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
    
    return (startDate, endDate)
}

func getWeekDates(startDate: Date) -> [Date] {
    
    guard
        let weekInterval = Calendar.current.dateInterval(of: .weekOfMonth, for: startDate)
    else { fatalError() }
    
    // form first day date
    let firstDay = weekInterval.start
    
    var weekDates = [firstDay]
    
    // form 2nd to 7th day dates
    for i in 1...6 {
        let nextDayDate = Calendar.current.date(byAdding: .day, value: i, to: firstDay)!
        weekDates.append(nextDayDate)
    }
    
    return weekDates
}

// MARK: - Day
public struct DayDate: Identifiable {
    public let id = UUID()
    let date: Date
    
    var formattedDate: String {
        
        if date.isSameDayAs(DateTime.now()) {
            return "Today"
        } else if date.isSameDayAs(DateTime.now().dayBefore) {
            return "Yesterday"
        } else {
            return "Day \(date.getDayNumber()), \(date.getYear())"
//            if UIDevice.current.userInterfaceIdiom == .phone {
//                return date.formatted(date: .abbreviated, time: .omitted)
//            } else {
//                return date.formatted(date: .complete, time: .omitted)
//            }
        }
    }
}

extension DayDate: Equatable {}
extension DayDate: Hashable {}

// MARK: - Week
public struct WeekDate {
    let start: Date
    let end: Date
    
    let days: [Date]
    
    
    init(date: Date) {
        (start, end) = date.getWeekStartEndDates()
        days = getWeekDates(startDate: start)
    }
    
    var weekNumberHeading: String {
        "Week \(start.getWeekNumber()), \(start.getYear())"
    }
}

extension WeekDate: Equatable {}
extension WeekDate: Hashable {}

// MARK: - Month
public struct MonthGridDate: Identifiable {
    
    public var id = UUID()
    
    let monthNumber: Int
    let monthSymbol: String
    let monthDate: MonthDate
    var isCurrentMonth = false
    
    init(date: Date, symbol: String, number: Int) {
        
        monthDate = MonthDate(date: date)
        monthNumber = number
        monthSymbol = symbol
        isCurrentMonth = Date.isCurrentMonth(date)
    }
    
}

extension MonthGridDate: Equatable {}
extension MonthGridDate: Hashable {}

public struct MonthDate {

    let start: Date
    let end: Date
    
    init(date: Date) {
        (start, end) = date.getMonthStartEndDates()
    }
    
}

extension MonthDate: Equatable {}
extension MonthDate: Hashable {}

@Observable
class CalendarState {
    // navigation related
//    var navigationDate: Date = Date()
    
    var calenderType: CalendarType = .day
    
    
    var dayDate: DayDate = DayDate(date: DateTime.now())
    var weekDate: WeekDate = WeekDate(date: DateTime.now())
    var monthDate: MonthDate = MonthDate(date: DateTime.now())
    
    var selectedDayDate: DayDate?
    var selectedWeekDate: WeekDate?
    var selectedMonthDate: MonthDate?
    
    // selection related
    var dayDateItem: DayDateItem.ID = DayDateItem(date: DateTime.now(), canShow: true).id
    
//    var selectedDate: Date = Date() {
//        didSet {
//            switch calenderType {
//            case .day:
//                dayDate = DayDate(date: selectedDate)
//            case .week:
//                break
//            case .month:
//                break
//            }
//        }
//    }    // todays date by default
//    
    
    init() {
        // set current day
        dayDate = DayDate(date: DateTime.now())
        // set current week
        weekDate = WeekDate(date: DateTime.now())
        // set current month
        monthDate = MonthDate(date: DateTime.now())
    }
    
    static let todayTint = Color.accentColor
    
    var oldCalenderType: CalendarType = .day
    
    func getOldNavigationDate(_ oldValue: CalendarType) -> Date {
        print(#function, oldValue)
        switch oldValue {
        case .day:
            return dayDate.date
        case .week:
            // convert week to day
            return weekDate.end
        case .month:
            // convert month to day
            return monthDate.start
        }
    }
    
    func updateNavigation(_ oldValue: CalendarType, _ newValue: CalendarType) {
        
        switch newValue {
        case .day:
            dayDate = DayDate(date: getOldNavigationDate(oldValue))
        case .week:
            weekDate = WeekDate(date: getOldNavigationDate(oldValue))
            print(#function , weekDate.start)
        case .month:
            monthDate = MonthDate(date: getOldNavigationDate(oldValue))
        }
    }
    
    
}

extension CalendarState {
    
    func previousStep() {
        
        switch calenderType {
        case .day:
            dayDate = DayDate(date: Calendar.current.date(byAdding: .day, value: -1, to: dayDate.date)!)
        case .week:
            weekDate = WeekDate(date: Calendar.current.date(byAdding: .day, value: -7, to: weekDate.start)!)
        case .month:
            monthDate = MonthDate(date: Calendar.current.date(byAdding: .month, value: -1, to: monthDate.start)!)
        }
        
    }
    
    func nextStep() {
        
        switch calenderType {
        case .day:
            dayDate = DayDate(date: Calendar.current.date(byAdding: .day, value: 1, to: dayDate.date)!)
        case .week:
            weekDate = WeekDate(date: Calendar.current.date(byAdding: .day, value: 7, to: weekDate.start)!)
        case .month:
            monthDate = MonthDate(date: Calendar.current.date(byAdding: .month, value: 1, to: monthDate.start)!)
        }
    }
}
