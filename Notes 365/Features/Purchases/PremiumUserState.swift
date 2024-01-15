//
//  PurchaseStatusState.swift
//  Notes 365
//
//  Created by kiran ipc on 09/01/24.
//

import Foundation
import StoreKit

extension Notification.Name {
    public static let premiumStateChange = Notification.Name("com.notes365.premiumStateChange")
}

actor PremiumUserState {
    static let shared = PremiumUserState()
    
    var isPurchased = false
    
    var purchasedTransaction: Transaction?
    var productType: Product.ProductType?
    var planName: String = ""
    var expirationDate: Date?
    
    private var updatesTask: Task<Void, Never>?
    
    func resetPurchase() {
        purchasedTransaction = nil
        isPurchased = false
        planName = ""
        productType = nil
        expirationDate = nil
    }
    
    func refreshPurchasedProducts() async {
        logger.info("\(#function)")
        resetPurchase()
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                logger.info("verified")
                // Check the type of product for the transaction
                // and provide access to the content as appropriate.
                updateActivePlan(transaction: transaction)
                logger.info("\(transaction.debugDescription)")
                break
            case .unverified(let unverifiedTransaction, let verificationError):
                logger.info("unverified")
                logger.error("\(verificationError)")
                // Handle unverified transactions based on your
                // business model.
                break
            }
        }
    }
    
    func checkForUnfinishedTransactions() async {
        logger.debug("Checking for unfinished transactions")
        for await transaction in Transaction.unfinished {
            let unsafeTransaction = transaction.unsafePayloadValue
            logger.log("""
            Processing unfinished transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
            Task.detached(priority: .background) {
                await self.process(transaction: transaction)
            }
        }
        logger.debug("Finished checking for unfinished transactions")
    }
    
    
    func observeTransactionUpdates() {
        self.updatesTask = Task { [weak self] in
            logger.debug("Observing transaction updates")
            for await update in Transaction.updates {
                guard let self else { break }
                await self.process(transaction: update)
            }
        }
    }
    
    func process(transaction verificationResult: VerificationResult<Transaction>) async {
        logger.info("\(#function)")
        do {
            let unsafeTransaction = verificationResult.unsafePayloadValue
            logger.log("""
            Processing transaction ID \(unsafeTransaction.id) for \
            \(unsafeTransaction.productID)
            """)
        }
        
        let transaction: Transaction
        switch verificationResult {
        case .verified(let t):
            logger.debug("""
            Transaction ID \(t.id) for \(t.productID) is verified
            """)
            transaction = t
        case .unverified(let t, let error):
            // Log failure and ignore unverified transactions
            logger.error("""
            Transaction ID \(t.id) for \(t.productID) is unverified: \(error)
            """)
            return
        }
        
        await transaction.finish()
        updateActivePlan(transaction: transaction)
    }
    
    func handleInAppPurchase(product: Product, result: Result<Product.PurchaseResult, Error>) {
        if case .success(.success(let verificationResult)) = result {
            logger.info("onInAppPurchaseCompletion: \(verificationResult.debugDescription)")
            logger.info("onInAppPurchaseCompletion: \(product.debugDescription)")
            Task {
                await process(transaction: verificationResult)
            }
        }
    }
    
    func updateActivePlan(transaction: StoreKit.Transaction) {
        // 1
        productType = transaction.productType
        // 2
        if transaction.productID == "LIFETIME001" {
            planName = "Lifetime Plan"
        } else if transaction.productID == "YEARLY002" {
            planName = "Individual Yearly Plan"
            expirationDate = transaction.expirationDate
        }
        // 3
        purchasedTransaction = transaction
        // 4
        isPurchased = true
        
        logger.debug("\(#function)")
        NotificationCenter.default.post(name: Notification.Name.premiumStateChange, object: nil, userInfo: nil)
    }
}
