//
//  PurchasesState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/11/22.
//

import SwiftUI
import StoreKit


class PurchasesState: ObservableObject {
    
    @Published var isPurchased: Bool = false
    
    func subscriptionsExists() -> Bool {
        store.subscriptions.count > 0
    }
    
    var product: Product {
        store.subscriptions.first!
    }
    
    //    var isSubscribed: Bool {
    //        store.purchasedSubscriptions.count != 0
    //    }
    
}
