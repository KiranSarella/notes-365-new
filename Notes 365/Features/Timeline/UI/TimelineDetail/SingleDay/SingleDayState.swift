//
//  SingleDayState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//
import SwiftUI

struct DayTimelineModel: Identifiable {
    let id = UUID()
    let date: Date
    var timelines = [Timeline]()
    
    mutating func showTimelines(newValues: [Timeline]) {
        timelines = newValues
    }
}

struct DiscardTimelineInfo: Equatable {
//    let dayId: UUID
    let date: Date
    let fileId: UUID
    let changeId: String
}
