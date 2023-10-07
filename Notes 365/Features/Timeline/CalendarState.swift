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
        
        if date.isSameDayAs(Date()) {
            return "Today"
        } else if date.isSameDayAs(Date().dayBefore) {
            return "Yesterday"
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return date.formatted(date: .abbreviated, time: .omitted)
            } else {
                return date.formatted(date: .complete, time: .omitted)
            }
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
    
    var selectedDate: Date = Date() {
        didSet {
            switch calenderType {
            case .day:
                dayDate = DayDate(date: selectedDate)
            case .week:
                break
            case .month:
                break
            }
        }
    }    // todays date by default
    
    var calenderType: CalendarType = .day {
        didSet {
            switch oldValue {
            case .day:
                switch calenderType {
                case .day:
                    break
                case .week:
                    // convert day to week
                    weekDate = WeekDate(date: dayDate.date)
                case .month:
                    // convert day to month
                    monthDate = MonthDate(date: dayDate.date)
                }
            case .week:
                switch calenderType {
                case .day:
                    // convert week to day
                    dayDate = DayDate(date: weekDate.start)
                case .week:
                    break
                case .month:
                    // convert week to month
                    // TODO: get week navigation date, from get month
                    // choose active month date from (start or end)
                    
                    if weekDate.start.getMonth() == navigationDate.getMonth() {
                        monthDate = MonthDate(date: weekDate.start)
                    } else {
                        monthDate = MonthDate(date: weekDate.end)
                    }
                    
                    
                }
            case .month:
                switch calenderType {
                case .day:
                    // convert month to day
                    dayDate = DayDate(date: monthDate.start)
                case .week:
                    // convert month to week
                    weekDate = WeekDate(date: monthDate.start)
                case .month:
                    break
                }
            }
        }
    }
    
    var dayDate: DayDate = DayDate(date: Date())
    var weekDate: WeekDate = WeekDate(date: Date())
    var monthDate: MonthDate = MonthDate(date: Date())
    
    var dayDateItem: DayDateItem.ID = DayDateItem(date: Date.now, canShow: true).id
    
    var navigationDate: Date = Date()
    
    init() {
        // set current day
        dayDate = DayDate(date: Date())
        // set current week
        weekDate = WeekDate(date: Date())
        // set current month
        monthDate = MonthDate(date: Date())
    }
    
    static let todayTint = Color.accentColor
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
