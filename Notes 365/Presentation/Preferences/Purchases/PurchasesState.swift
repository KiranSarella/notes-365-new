//
//  PurchasesState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 28/11/22.
//

import SwiftUI
import StoreKit

class PurchasesState: ObservableObject {
    
    var purchasesBusiness = PurchasesBusiness()
    
    @Published var isPurchased: Bool = false
    
    @Published private(set) var status: Product.SubscriptionInfo.Status?
    @Published private(set) var product: Product?
    
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
        (status, product) = await purchasesBusiness.getupdatedSubscriptionStatus()
    }
    
}
