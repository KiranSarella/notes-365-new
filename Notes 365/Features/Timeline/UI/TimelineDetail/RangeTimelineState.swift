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
    var atleastOneDayExists = false
    var currentDayLoaded = false
    
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
        atleastOneDayExists = false
        statusMessage = "Loading.."
    }
    
    func loadNextDay() {
        logger.info("loadNextDay")
        if givenDays.count == 0 {
            canLoadMore = false
            logger.info("all loaded.")
            if !daysContentExists.contains(true) {
                statusMessage = "No Content"
                logger.info("no content")
            }
        } else {
            currentLoadingDate = givenDays.removeFirst()
            currentDayLoaded = false
            showingDays.append(currentLoadingDate)
        }
    }
    
    func tryLoadMore() {
        logger.info("tryLoadMore - currentDayLoaded: \(self.currentDayLoaded)")
        // have to maintain queue? - what if day content is single line?
        if currentDayLoaded == false {
            return
        }
        loadNextDay()
    }
    
}
