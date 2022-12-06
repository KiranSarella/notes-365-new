//
//  PurchasesState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/11/22.
//

import SwiftUI
import StoreKit

@MainActor
class PurchasesState: ObservableObject {
    
    var purchasesBusiness = PurchasesBusiness()
    
    @Published var isPurchased: Bool = false
    @Published var purchasedProduct: Product?
    @Published private(set) var subscriptionStatus: Product.SubscriptionInfo.Status?
    
    @Published private(set) var product: Product?

    init() {
        let subscriptions = purchasesBusiness.getSubscriptions()
        if let subscrition = subscriptions.first {
            product = subscrition
            
            Task {
                isPurchased = (try? await purchasesBusiness.store.isPurchased(subscrition)) ?? false
            }
        }
    }
    
    
    
    func subscriptionsExists() -> Bool {
        purchasesBusiness.subscriptionsExists()
    }
    
    func buy() async throws {
        guard let product = product else { return }
        do {
            if try await purchasesBusiness.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
            }
        } catch StoreError.failedVerification {
            throw StoreError.failedVerification
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        (subscriptionStatus, purchasedProduct) = await purchasesBusiness.getupdatedSubscriptionStatus()
    }
    
}
