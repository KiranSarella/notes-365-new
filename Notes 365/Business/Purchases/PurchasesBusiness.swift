//
//  PurchasesBusiness.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/11/22.
//

import Foundation
import StoreKit

class PurchasesBusiness {
  
    var store: Store = Store.shared
    
    func subscriptionsExists() -> Bool {
        store.subscriptions.count > 0
    }
    
    var isSubscribed: Bool {
        return store.purchasedSubscriptions.count != 0
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        try await store.purchase(product)
    }
    
    
    @MainActor
    func getupdatedSubscriptionStatus() async -> (Product.SubscriptionInfo.Status?, Product?) {
        await StoreHelper.getupdatedSubscriptionStatus(store)
    }
    
}
