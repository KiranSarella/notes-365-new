//
//  MonthCalendar.swift
//  Tertiary
//
//  Created by Kiran Sarella on 09/07/21.
//

import SwiftUI

struct MonthCalendarView: View {
    
    @Binding var monthDate: MonthDate
    @State private var navigationDate: Date = Date()
    
    var body: some View {
        VStack {
            // current month, prev, next actions
            MonthHeaderView(monthDate: $monthDate, navigationDate: $navigationDate)
            // grid view
            MonthGridView(monthDate: $monthDate, navigationDate: $navigationDate)
        }
        .padding()
        .onAppear {
            navigationDate = self.monthDate.start
        }
    }
    
}


struct MonthHeaderView: View {
    
    @Binding var monthDate: MonthDate
    @Binding var navigationDate: Date
    var calendar = Calendar(identifier: .gregorian)
    
    var body: some View {
        
        CalendarNavigatorView(label: navigationDate.string(withFormat: "YYYY"), previous: {
            guard let newDate = calendar.date(byAdding: .year, value: -1, to: navigationDate) else { return }
            navigationDate = newDate
        }, today: {
            navigationDate = Date()
            monthDate = MonthDate(date: navigationDate)
        }, next: {
            guard let newDate = calendar.date(byAdding: .year, value: 1, to: navigationDate) else { return }
            navigationDate = newDate
        })
        .frame(height: 60)
    }
}


struct MonthGridView: View {
    
    @Binding var monthDate: MonthDate
    @Binding var navigationDate: Date

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
                        } label: {
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                NavigationLink("\(date.monthSymbol)", value: date.monthDate)
                                    .padding()
                                    .foregroundColor(date.isCurrentMonth ? CalendarState.todayTint : .primary)
                            } else {
                                Text("\(date.monthSymbol)")
                                    .padding()
                                    .foregroundColor(date.isCurrentMonth ? CalendarState.todayTint : .primary)
                            }
                        }
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor, lineWidth: isSelectedMonth(date.monthNumber) ? 1 : 0)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .frame(height: 220)
        .navigationDestination(for: MonthDate.self) { newDate in
            MonthDetailView()
                .onAppear {
                    monthDate = newDate
                }
        }
        .onAppear {
            refreshMonthGrid(navigationDate: navigationDate)
        }
        .onChange(of: navigationDate) { newValue in
            refreshMonthGrid(navigationDate: newValue)
        }
    }
    
    func refreshMonthGrid(navigationDate: Date) {
        var monthDatesList = [MonthGridDate]()
        
        let year = navigationDate.string(withFormat: "YYYY")
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
        
        if navigationDate.getYear() == today.getYear() && month == today.getMonth() {
            return true
        }
        
        return false
    }
    
    private func isSelectedMonth(_ month: Int) -> Bool {
        
        // selected date's year, month should match to UI month, year
        if navigationDate.getYear() == monthDate.start.getYear() && monthDate.start.getMonth() == month {
            return true
        }
        
        return false
    }
}

//struct MonthCalendar_Previews: PreviewProvider {
//    static var previews: some View {
//        MonthCalendar()
//    }
//}
