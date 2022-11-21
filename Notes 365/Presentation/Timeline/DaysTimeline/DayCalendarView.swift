//
//  DayCalender.swift
//  Tertiary
//
//  Created by Kiran Sarella on 02/07/21.
//

import SwiftUI

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
                navigationDate = Date()
                dayDate = DayDate(date: navigationDate)
            } label: {
                Label(
                    title: { Text("Today") },
                    icon: { Image(systemName: "smallcircle.fill.circle") }
                )
                .labelStyle(IconOnlyLabelStyle())
                //                        .padding(.horizontal)
                .frame(maxHeight: .infinity)
                .help("today")
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
                    Text(weekdaySymbol)
                        .padding(.bottom, 4)
                        .font(.system(size: 10, weight: Font.Weight.light, design: Font.Design.rounded))
                }
                // grid numbers
                ForEach(dates, id: \.self) { date in
                    // get day number from date
                    // check if month is selected month
                    if date.getMonth() == navigationDate.getMonth() {
                        ZStack {
                            Button {
                                dayDate = DayDate(date: date)
                            } label: {
                                Text("\(date.getDay())")
                                    .padding(4)
                                    .font(.system(size: 10))
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: date.isSameDayAs(dayDate.date) ? 1 : 0)
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
    }
    
   
}



func getCalenderDates(_ inputDate: Date) -> [Date] {
    
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
    
    return dates
}

