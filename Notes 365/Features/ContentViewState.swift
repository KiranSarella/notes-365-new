//
//  ContentViewState.swift
//  Notes 365
//
//  Created by kiran ipc on 19/02/24.
//

import SwiftUI

@Observable
class ContentViewState {
    
    func checkAndObservePurchasesChanges() {
        Task {
            logger.info("Starting tasks to observe transaction updates")
            // Begin observing StoreKit transaction updates in case a
            // transaction happens on another device.
            await PremiumUserState.shared.observeTransactionUpdates()
            // Check if we have any unfinished transactions where we
            await PremiumUserState.shared.checkForUnfinishedTransactions()
            logger.info("Finished checking for unfinished transactions")
            // refresh premium status
            await PremiumUserState.shared.refreshPurchasedProducts()
        }
    }
}
