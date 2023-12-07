//
//  MonthCalendar.swift
//  Tertiary
//
//  Created by Kiran Sarella on 09/07/21.
//

import SwiftUI

struct MonthCalendarView: View {
    @Binding var monthDate: MonthDate
    @Binding var selectedMonthDate: MonthDate?
    var body: some View {
        VStack {
            MonthHeaderView(monthDate: $monthDate, selectedMonthDate: $selectedMonthDate)
            MonthGridView(monthDate: $monthDate, selectedMonthDate: $selectedMonthDate)
        }
    }
}

struct MonthHeaderView: View {
    @Binding var monthDate: MonthDate
    @Binding var selectedMonthDate: MonthDate?
    var calendar = Calendar(identifier: .gregorian)
    var body: some View {
        CalendarNavigatorView(label: monthDate.start.string(withFormat: "YYYY"), previous: {
            guard let newDate = calendar.date(byAdding: .year, value: -1, to: monthDate.start) else { return }
            monthDate = MonthDate(date: newDate)
        }, today: {
            monthDate = MonthDate(date: DateTime.now())
            selectedMonthDate = monthDate
        }, next: {
            guard let newDate = calendar.date(byAdding: .year, value: 1, to: monthDate.start) else { return }
            monthDate = MonthDate(date: newDate)
        })
        .frame(height: 60)
    }
}

struct MonthGridView: View {
    @Binding var monthDate: MonthDate
    @Binding var selectedMonthDate: MonthDate?
    var columns = Array(repeating: GridItem(), count: 3)
    var monthSymbols = Calendar.current.shortMonthSymbols
    @State var monthGridDates = [MonthGridDate]()
    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(monthGridDates) { date in
                    ZStack {
                        Button {
                            monthDate = date.monthDate
                            selectedMonthDate = monthDate
                        } label: {
                            Text("\(date.monthSymbol)")
                                .padding()
                                .foregroundColor(date.isCurrentMonth ? CalendarState.todayTint : .primary)
                        }
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: isSelectedMonth(date.monthNumber) ? 1 : 0)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .onAppear {
            refreshMonthGrid(monthDate: monthDate)
        }
        .onChange(of: monthDate, { oldValue, newValue in
            refreshMonthGrid(monthDate: newValue)
        })
    }

}
