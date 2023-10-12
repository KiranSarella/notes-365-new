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
            // current month, prev, next actions
            MonthHeaderView(monthDate: $monthDate, selectedMonthDate: $selectedMonthDate)
            // grid view
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
            // update navigation
            monthDate = MonthDate(date: newDate)
        }, today: {
            // today
            monthDate = MonthDate(date: Date())
            // make selection
            selectedMonthDate = monthDate
        }, next: {
            guard let newDate = calendar.date(byAdding: .year, value: 1, to: monthDate.start) else { return }
            // update navigation
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
    
    @State private var monthGridDates = [MonthGridDate]()
    
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
    
    func refreshMonthGrid(monthDate: MonthDate) {
        var monthDatesList = [MonthGridDate]()
        
        let year = monthDate.start.string(withFormat: "YYYY")
        for monthIndex in monthSymbols.indices {
            let monthSymbol = monthSymbols[monthIndex]
            let month = monthIndex + 1
            let day = 1
            // "yyyy-MM-dd"
            let dateStr = "\(year)-\(month)-\(day)"
            let monthStartDate = dateStr.toUTCDate(withFormat: "yyyy-MM-dd")!
            monthDatesList.append(MonthGridDate(date: monthStartDate, symbol: monthSymbol, number: month))
        }
        
        monthGridDates = monthDatesList
    }
    
    func getMonthStartDate(for month: Int, year: String) -> Date {
        
        let month = month
        let day = 1
        
        // "yyyy-MM-dd"
        let dateStr = "\(year)-\(month)-\(day)"
        let monthStartDate = dateStr.toUTCDate(withFormat: "yyyy-MM-dd")!
        
        return monthStartDate
    }
    
    private func isCurrentMonth(_ month: Int) -> Bool {
        // check same year
        // check same month
        let today = Date()
        
        if monthDate.start.getYear() == today.getYear() &&
            month == today.getMonth() {
            return true
        }
        
        return false
    }
    
    private func isSelectedMonth(_ month: Int) -> Bool {
        // selected date's year, month should match to UI month, year
        if selectedMonthDate?.start.getYear() == monthDate.start.getYear() &&
            selectedMonthDate?.start.getMonth() == month {
            return true
        }
        
        return false
    }
}
