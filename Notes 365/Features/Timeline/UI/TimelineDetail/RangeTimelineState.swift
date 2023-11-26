//
//  RangeTimelineState.swift
//  Notes 365
//
//  Created by kiran ipc on 26/11/23.
//

import SwiftUI



struct CurrentDateLoadingState {
    let date: Date
    let timmelinesCount: Int
}

extension CurrentDateLoadingState: Equatable {
    
}

@Observable
class RangeTimelineState {
    var givenDays = [Date]()
    var showingDays = [Date]()
    var currentLoadingDate = Date()
    var currentDateLoadingState = CurrentDateLoadingState(date: Date(), timmelinesCount: 0)
    var daysContentExists:Set<Bool> = []
    var canLoadMore = false
    var statusMessage: String?
    
    
    func startloading(days: [Date]) {
        resetFields()
        givenDays = days
        loadNextDay()
    }
    
    func resetFields() {
        showingDays = [Date]()
        currentLoadingDate = Date()
        daysContentExists = []
        canLoadMore = false
        statusMessage = "Loading.."
    }
    
    func loadNextDay() {
        logger.info("loadNextDay")
        if givenDays.count == 0 {
            canLoadMore = false
            if !daysContentExists.contains(true) {
                statusMessage = "No Content"
            }
        } else {
            currentLoadingDate = givenDays.removeFirst()
            showingDays.append(currentLoadingDate)
        }
    }
    
//    func tryLoadMore() {
//        logger.info("tryLoadMore - currentDayLoaded: \(self.currentDayLoaded)")
//        // have to maintain queue? - what if day content is single line?
//        if currentDayLoaded == false {
//            return
//        }
//        loadNextDay()
//    }
    
}
