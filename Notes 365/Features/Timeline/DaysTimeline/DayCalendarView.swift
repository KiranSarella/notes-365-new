//
//  DayCalender.swift
//  Tertiary
//
//  Created by Kiran Sarella on 02/07/21.
//

import SwiftUI

/*
struct DayCalendarView: View {

    @Binding var dayDate: DayDate
    @State private var navigationDate: Date = Date()
    
    var calendar = Calendar(identifier: .gregorian)
    
    var body: some View {
        
        VStack {
            // current month, prev, next actions
            HeaderView(dayDate: $dayDate, navigationDate: $navigationDate)
            // grid view 7 x 7
            // 7 columns
            // titles: sun, mon...
            // detail rows: 6
            DayGridView(dayDate: $dayDate, navigationDate: $navigationDate)
        }
        .padding()
        .onAppear {
            navigationDate = dayDate.date
        }
    }
}

fileprivate struct HeaderView: View {
    
    @Binding var dayDate: DayDate
    @Binding var navigationDate: Date
     
    var calendar = Calendar(identifier: .gregorian)
     
    var body: some View {
        
        CalendarNavigatorView(label: navigationDate.string(withFormat: "MMMM, YYYY"), previous: {
            guard let newDate = calendar.date(byAdding: .month, value: -1, to: navigationDate) else { return }
            navigationDate = newDate
        }, today: {
            navigationDate = Date()
            dayDate = DayDate(date: navigationDate)
        }, next: {
            guard let newDate = calendar.date(byAdding: .month, value: 1, to: navigationDate) else { return }
            navigationDate = newDate
        })
        .frame(height: 50)
    }
}

fileprivate struct DayGridView: View {
    
    var columns = Array(repeating: GridItem(), count: 7)
    var weekdaySymbols = Calendar.current.shortWeekdaySymbols
    @Binding var dayDate: DayDate
    @Binding var navigationDate: Date
    @State private var dates: [Date] = []
    
    var body: some View {
        
        VStack {
            LazyVGrid(columns: columns) {
                // mon, tue,..
                ForEach(weekdaySymbols, id: \.self) { weekdaySymbol in
                    Text(String(weekdaySymbol.first!))
                        .padding(.bottom, 4)
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                // grid numbers
                ForEach(dates, id: \.self) { date in
                    // get day number from date
                    // check if month is selected month
                    if date.getMonth() == navigationDate.getMonth() {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentColor, lineWidth: date.isSameDayAs(dayDate.date) ? 1 : 0)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(date.isSameDayAs(dayDate.date) ? Color.blue : Color.clear)
//                                )
                            Button {
                                dayDate = DayDate(date: date)
                            } label: {
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    NavigationLink("\(date.getDay())", value: DayDate(date: date))
                                        .padding(4)
                                        .font(.system(size: 12))
                                        .foregroundColor(isToday(date.getDay()) ? CalendarState.todayTint : .primary)
                                } else {
                                    Text("\(date.getDay())")
                                        .padding(4)
                                        .font(.system(size: 12))
                                        .foregroundColor(isToday(date.getDay()) ? CalendarState.todayTint : .primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        Text("\(date.getDay())")
                            .padding(.bottom, 4)
                            .foregroundColor(.clear)
                    }
                }.buttonStyle(PlainButtonStyle())
                Spacer()
            }
            Spacer()
        }
        .onAppear(perform: {
            dates = getCalenderDates(navigationDate)
        })
        .onChange(of: navigationDate, perform: { newValue in
            dates = getCalenderDates(newValue)
        })
        .frame(height: 220)
        .navigationDestination(for: DayDate.self) { newDate in
            DayDetailView()
                .onAppear {
                    dayDate = newDate
                    CalendarState.shared.dayDate = dayDate
                }
        }
    }
    
    private func isToday(_ day: Int) -> Bool {
        // check same year
        // check same month
        let today = Date()
        
        if navigationDate.getYear() == today.getYear() && navigationDate.getMonth() == today.getMonth() && today.getDay() == day {
            return true
        }
        
        return false
    }
}
*/


//func getCalenderDates(_ inputDate: Date) -> [Date] {
//    
//    guard
//        let monthInterval = Calendar.current.dateInterval(of: .month, for: inputDate),
//        let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start)
//    else { fatalError() }
//    
//    let startDate = monthFirstWeek.start
//    let endDate = Calendar.current.date(byAdding: .day, value: 41, to: monthFirstWeek.start)!
//    
//    var nextDate = startDate
//    
//    var dates = [startDate]
//    
//    while nextDate < endDate {
//        nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate)!
//        dates.append(nextDate)
//    }
//    
//    print("dates count", dates.count)
//    return dates
//}

