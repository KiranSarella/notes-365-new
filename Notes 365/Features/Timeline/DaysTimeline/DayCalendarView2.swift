//
//  DayCalendarView2.swift
//  Notes 365
//
//  Created by kiran ipc on 19/05/23.
//

import SwiftUI

struct DayCalendarView2: View {
    
    @Binding var dayDate: DayDate
    @StateObject var dayState = DayCalendarState()
    
    var body: some View {
        VStack {
            // current month, prev, next actions
            HeaderView()
                .environmentObject(dayState)
            // grid view 7 x 7
            // 7 columns
            // titles: sun, mon...
            // detail rows: 6
            DayGridView()
                .environmentObject(dayState)
        }
        .padding()
        .onAppear {
            dayState.setDisplayDate(dayDate.date)
//            navigationDate = dayDate.date
        }
    }
}

fileprivate struct HeaderView: View {
    
    @EnvironmentObject var dayState: DayCalendarState
     
    var body: some View {
        
        CalendarNavigatorView(label: dayState.dateTitle, previous: {
            dayState.previousMonth()
        }, today: {
            dayState.setToday()
        }, next: {
            dayState.nextMonth()
        })
        .frame(height: 50)
    }
}

fileprivate struct DayGridView: View {
    
    var columns = Array(repeating: GridItem(), count: 7)
    var weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    @EnvironmentObject var dayState: DayCalendarState
    
   
    var body: some View {
        
        VStack {
            LazyVGrid(columns: columns) {
                // mon, tue,..
                ForEach(weekdaySymbols, id: \.self) { weekdaySymbol in
                    Text(String(weekdaySymbol.first!))
                        .padding(.bottom, 4)
                        .font(.system(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                // grid numbers
                ForEach(dayState.dayitems) { dayItem in
                    
                    Button {
                        if !dayItem.canShow {
                            return
                        }
                        dayState.selectedDate = dayItem.date
                    } label: {
                        DayGridItem(dayItem: dayItem, isSelected: dayState.isSelected(dayItem))
                    }

                }.buttonStyle(PlainButtonStyle())
                Spacer()
            }
            Spacer()
        }
        .onAppear(perform: {
//            dates = getCalenderDates(navigationDate)
        })
        .frame(height: 220)
    }
    
}

struct DayGridItem: View {
    
    let dayItem: DayDateItem
    let isSelected: Bool
    
    var textColor: Color {
        if dayItem.canShow == false {
            return .clear
        } else if dayItem.isToday {
            return CalendarState.todayTint
        } else {
            return .primary
        }
    }
    
    var body: some View {
        Text("  \(dayItem.day)  ")
            .font(.system(size: 14))
            .padding([.horizontal], 2)
            .padding([.vertical], 4)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 1 : 0)
                    .frame(width: 26, height: 26)
            )
    }
}
