//
//  WeekCalendar.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI
//import AttributedText

struct WeekCalendarView: View {

    @Binding var weekDate: WeekDate
    @State private var navigationDate: Date = Date()
    @State private var selectedWeek: Week = getWeek(Date())
    
    var calendar = Calendar(identifier: .gregorian)
   
    var body: some View {
        
        VStack {
            // current month, prev, next actions
            WeekHeaderView(weekDate: $weekDate,
                           navigationDate: $navigationDate,
                           selectedWeek: $selectedWeek,
                           calendar: calendar)
            .frame(height: 50)
            
            // grid view 7 x 7
            // 7 columns
            // titles: sun, mon...
            // detail rows: 6
            WeekGridView(weekDate: $weekDate, navigationDate: $navigationDate, selectedWeek: $selectedWeek)
        }
        .padding()
        .onAppear {
            navigationDate = weekDate.end   // taken .end date to show correct month visually.
            selectedWeek = getWeek(weekDate.start)
        }
        .onChange(of: navigationDate) { newValue in
            CalendarState.shared.navigationDate = newValue
        }
    }

}

struct WeekHeaderView: View {
    
    @Binding var weekDate: WeekDate
    @Binding var navigationDate: Date
    @Binding var selectedWeek: Week
    var calendar: Calendar
    
    var body: some View {
        HStack {
            Text(navigationDate.string(withFormat: "MMMM, YYYY"))
                .font(.system(size: 14, weight: Font.Weight.semibold, design: Font.Design.rounded))
                .padding(.leading, 9)
            Spacer()
            // previous
            Button {
                guard let newDate = calendar.date(byAdding: .month, value: -1, to: navigationDate) else { return }
                navigationDate = newDate
            } label: {
                Label(
                    title: { Text("Previous") },
                    icon: { Image(systemName: "chevron.left") }
                )
                    .labelStyle(IconOnlyLabelStyle())
                //                        .padding(.horizontal)
                    .frame(maxHeight: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            // today
            Button {
                weekDate = WeekDate(date: Date())
                navigationDate = Date()
                selectedWeek = getWeek(weekDate.start)
            } label: {
                Label(
                    title: { Text("Today") },
                    icon: { Image(systemName: "smallcircle.fill.circle") }
                )
                    .labelStyle(IconOnlyLabelStyle())
                    .frame(maxHeight: .infinity)
                    .help("this week")
//                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
            // next
            Button {
                guard let newDate = calendar.date(byAdding: .month, value: 1, to: navigationDate) else { return }
                navigationDate = newDate
            } label: {
                Label(
                    title: { Text("Next") },
                    icon: { Image(systemName: "chevron.right") }
                )
                    .labelStyle(IconOnlyLabelStyle())
                    .padding(.trailing, 5)
                    .frame(maxHeight: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
}

//struct WeekCalendar_Previews: PreviewProvider {
//    static var previews: some View {
//        WeekCalendar()
//    }
//}


struct WeekGridView: View {
    
    @Binding var weekDate: WeekDate
    @Binding var navigationDate: Date
    @Binding var selectedWeek: Week
    
    var weekdaySymbols = [" "] + Calendar.current.shortWeekdaySymbols   // [" "] is required
    var calendar = Calendar(identifier: .gregorian)
    
    var body: some View {
        VStack {
            // days
            HStack() {
                ForEach(weekdaySymbols, id: \.self) { weekdaySymbol in
                    Text(String(weekdaySymbol.first!))
                        .padding(.bottom, 4)
                        .font(.system(size: 10, weight: Font.Weight.light, design: Font.Design.rounded))
                        .frame(maxWidth: .infinity)
                }
            }
            // weeks grid
            ForEach(getWeekDates(navigationDate), id: \.self) { week in
                
               WeekView(weekDate: $weekDate,
                        navigationDate: $navigationDate,
                        selectedWeek: $selectedWeek,
                        week: week)
            }
            Spacer()
        }
        .buttonStyle(.plain)
        .frame(height: 220)
    }
}

struct WeekView: View {
    
    @Binding var weekDate: WeekDate
    @Binding var navigationDate: Date
    @Binding var selectedWeek: Week
    
    var week: Week
    
    private func isSelectedWeek(_ week: Week) -> Bool {
        selectedWeek == week
    }
    
    private func highlightColor(_ week: Week) -> Color {
        week == selectedWeek ? .blue : .clear
    }
    
    var body: some View {
        ZStack() {
            HStack() {
                Text("\(week.weekNumber)")
                    .frame(maxWidth: .infinity)
//                    .font(.system(size: 10))
                    .font(.system(size: 11, weight: .heavy, design: .monospaced).italic())
                    
                    .foregroundColor(Color.red)
                ForEach(week.weekDays, id: \.self) { date in
                    if date.getMonth() == navigationDate.getMonth() {
                        Text("\(date.getDay())")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 10))
                            .foregroundColor(week.isCurrentWeek() ? CalendarState.todayTint : .primary)
                    } else {
                        Text("\(date.getDay())")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 10))
                            .opacity(0.3)
                    }
                }
            }
            .padding(.init(top: 2, leading: 5, bottom: 2, trailing: 5))
            RoundedRectangle(cornerRadius: 8)
//                .stroke(highlightColor(week), lineWidth: 1)
                .stroke(Color.blue, lineWidth: isSelectedWeek(week) ? 1 : 0)
                .frame(height: 30)
                .background(Color.red.opacity(0.01))
                .onTapGesture {
                    // accept tap only when week belongs to current month
                    if week.weekDays.first!.getMonth() == navigationDate.getMonth() ||
                        week.weekDays.last!.getMonth() == navigationDate.getMonth() {
                        
                        let selectedDate = week.weekDays.first!
                        weekDate = WeekDate(date: selectedDate)
                        
                        selectedWeek = week
                    }
                }
            
        }
    }
}




func getWeekDates(_ inputDate: Date) -> [Week] {
    
    let calendar = Calendar.current
    
    let calendarDates = getCalenderDates(forMonth: inputDate)
    
    
    
    var weeks = [Week]()
    
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
        
        weeks.append(Week(weekNumber: weekNumber, weekDays: dates))
    }
    
    return weeks
}


func getWeek(_ inputDate: Date) -> Week {
    
    let calendar = Calendar.current
    let calendarDates = getCalenderDates(forMonth: inputDate)
    let inputWeekNumber = calendar.component(.weekOfYear, from: inputDate)
    
    var week: Week!
    
    for row in 0..<6 {
        
        let startIndex = 7 * row
        let endIndex = startIndex + 7
        
        let dates = Array(calendarDates[startIndex..<endIndex])
        
        let weekNumber = calendar.component(.weekOfYear, from: dates[3])    // take center one as a weeknumber
        
        if weekNumber == inputWeekNumber {
            week = Week(weekNumber: weekNumber, weekDays: dates)
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
    
    let monthEndDate = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end)
    
    while date < endDate {
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        dates.append(date)
    }
    
    return dates
}
