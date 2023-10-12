//
//  WeekCalendar.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

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

struct WeekCalendarView: View {

    @Binding var weekDate: WeekDate
    @Binding var selectedWeekDate: WeekDate?
    
    var calendar = Calendar(identifier: .gregorian)
   
    var body: some View {
        VStack {
            // current month, prev, next actions
            WeekHeaderView(weekDate: $weekDate,
                           selectedWeekDate: $selectedWeekDate,
                           calendar: calendar)
            .frame(height: 50)
            
            // grid view 7 x 7
            // 7 columns
            // titles: sun, mon...
            // detail rows: 6
            WeekGridView(weekDate: $weekDate, selectedWeekDate: $selectedWeekDate)
        }
        .onAppear {
            print(weekDate.start)
        }
//        .padding()
    }

}

struct WeekHeaderView: View {
    
    @Binding var weekDate: WeekDate
    @Binding var selectedWeekDate: WeekDate?
    var calendar: Calendar
    
    var body: some View {
        
        CalendarNavigatorView(label: weekDate.end.string(withFormat: "MMMM, YYYY"), previous: {
            // previous is navigation
            guard let newDate = calendar.date(byAdding: .month, value: -1, to: weekDate.end) else { return }
            // update navigation
//            withAnimation {
                weekDate = WeekDate(date: newDate)
//            }
        }, today: {
            // today is selection
//            withAnimation {
                weekDate = WeekDate(date: Date())
//            }
            // make selection
            selectedWeekDate = weekDate
        }, next: {
            // next is navigation
            guard let newDate = calendar.date(byAdding: .month, value: 1, to: weekDate.end) else { return }
//            withAnimation {
                weekDate = WeekDate(date: newDate)
//            }
        })
    }
    
}

//struct WeekCalendar_Previews: PreviewProvider {
//    static var previews: some View {
//        WeekCalendar()
//    }
//}


struct WeekGridView: View {
    
    @Binding var weekDate: WeekDate
    @Binding var selectedWeekDate: WeekDate?
    
    var weekdaySymbols = [" "] + Calendar.current.shortWeekdaySymbols   // [" "] is required
    var calendar = Calendar(identifier: .gregorian)
    
    var body: some View {
        VStack {
            // days
            HStack() {
                ForEach(weekdaySymbols, id: \.self) { weekdaySymbol in
                    Text(String(weekdaySymbol.first!))
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(EdgeInsets(top: 20, leading: 5, bottom: 0, trailing: 5))
            // weeks grid
            ForEach(getWeekDates(weekDate.end), id: \.self) { week in
               WeekView(weekDate: $weekDate,
                        selectedWeekDate: $selectedWeekDate,
                        week: week)
            }
            Spacer()
        }
        .buttonStyle(.plain)
//        .frame(height: 220)
    }
}

struct WeekView: View {
    
    @Binding var weekDate: WeekDate
    @Binding var selectedWeekDate: WeekDate?
    
    var week: WeekGrid
    
    private func isSelectedWeek(_ week: WeekGrid) -> Bool {
        selectedWeekDate == week.weekDate
    }
    
    private func highlightColor(_ week: WeekGrid) -> Color {
        week.weekDate == selectedWeekDate ? .accentColor : .clear
    }
    
    var isValidSelection: Bool {
        if week.weekDays.first!.getMonth() == weekDate.end.getMonth() ||
            week.weekDays.last!.getMonth() == weekDate.end.getMonth() {

//            let selectedDate = week.weekDays.first!
//            weekDate = WeekDate(date: selectedDate)
//            selectedWeek = week
//
            return true
        }
        
        return false
    }
    
    fileprivate func weekGridRowView() -> some View {
        return HStack() {
            Text("\(week.weekNumber)")
                .frame(maxWidth: .infinity)
                .fontWeight(.heavy)
                .foregroundColor(Color.red)
            ForEach(week.weekDays, id: \.self) { date in
//                if date.getMonth() == navigationDate.getMonth() {
                    Text("\(date.getDay())")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(week.isCurrentWeek() ? CalendarState.todayTint : .primary)
//                } else {
//                    Text("\(date.getDay())")
//                        .frame(maxWidth: .infinity)
////                        .font(.system(size: 12))
//                        .opacity(0.4)
//                }
            }
        }
        .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
    }
    
    var body: some View {
        ZStack() {
            weekGridRowView()
            RoundedRectangle(cornerRadius: 8)
            .stroke(Color.accentColor, lineWidth: isSelectedWeek(week) ? 1 : 0)
            .frame(height: 30)
            .background(Color.red.opacity(0.01))
            .onTapGesture {
                // accept tap only when week belongs to current month
                if week.weekDays.first!.getMonth() == weekDate.end.getMonth() ||
                    week.weekDays.last!.getMonth() == weekDate.end.getMonth() {

                    let selectedDate = week.weekDays.first!
                    weekDate = WeekDate(date: selectedDate)
                    selectedWeekDate = week.weekDate
                }
            }
        }
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
