//
//  DayCalendarView2.swift
//  Notes 365
//
//  Created by kiran ipc on 19/05/23.
//

import SwiftUI

struct DayCalendarView: View {
    @State private var dayState = DayCalendarState()
    @Binding var dayDate: DayDate
    @Binding var selectedDayDate: DayDate?
    
    var body: some View {
        VStack {
            HeaderView()
                .padding(.bottom, 4)
                .environment(dayState)
            DayGridView(dayDate: $dayDate)
                .environment(dayState)
        }
        .onAppear {
            dayState.dayDate = dayDate
            dayState.selectedDayDate = selectedDayDate
            dayState.updateDisplay()
        }
        .onChange(of: dayState.dayDate) { oldValue, newValue in
            dayDate = newValue
        }
        .onChange(of: dayState.selectedDayDate) { oldValue, newValue in
            selectedDayDate = newValue
        }
    }
}

fileprivate struct HeaderView: View {
    @Environment(DayCalendarState.self) var dayState
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
    @Environment(DayCalendarState.self) var dayState
    @Binding var dayDate: DayDate
    @State private var displayCounter: Int = 0
    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(weekdaySymbols, id: \.self) { weekdaySymbol in
                    Text(String(weekdaySymbol.first!))
                        .padding(.bottom, 4)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                // grid numbers
                ForEach(dayState.dayitems) { dayItem in
                    Button {
                        if !dayItem.canShow { return }
                        dayState.makeSelection(dayItem)
                    } label: {
                        DayGridItem(dayItem: dayItem, isSelected: dayState.isSelected(dayItem))
                    }
                }.buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
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
        Text("\(dayItem.day)")
            .padding([.horizontal], 2)
            .padding([.vertical], 6)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: isSelected ? 1 : 0)
                    .frame(width: 26, height: 26)
            )
    }
}

