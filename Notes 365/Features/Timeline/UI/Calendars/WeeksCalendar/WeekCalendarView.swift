//
//  WeekCalendar.swift
//  Tertiary
//
//  Created by Kiran Sarella on 03/07/21.
//

import SwiftUI

struct WeekCalendarView: View {
    @Binding var weekDate: WeekDate
    @Binding var selectedWeekDate: WeekDate?
    var calendar = Calendar(identifier: .gregorian)
    var body: some View {
        VStack {
            WeekHeaderView(weekDate: $weekDate,
                           selectedWeekDate: $selectedWeekDate,
                           calendar: calendar)
            .frame(height: 50)
            WeekGridView(weekDate: $weekDate, selectedWeekDate: $selectedWeekDate)
        }
        .onAppear {
            print(weekDate.start)
        }
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
            weekDate = WeekDate(date: newDate)
        }, today: {
            weekDate = WeekDate(date: Date())
            selectedWeekDate = weekDate
        }, next: {
            guard let newDate = calendar.date(byAdding: .month, value: 1, to: weekDate.end) else { return }
            weekDate = WeekDate(date: newDate)
        })
    }
}

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

