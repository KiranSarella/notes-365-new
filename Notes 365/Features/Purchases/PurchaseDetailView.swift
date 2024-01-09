//
//  PurchaseDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI
import StoreKit

struct PurchaseDetailView: View {
    
    @State var activePlan = false
    @State var planName: String = ""
    @State var productType: Product.ProductType?
    @State var expirationDate: Date?
    var renewMessage: String {
        if let expirationDate = expirationDate {
            return "Renews \(expirationDate.string(format: "MMM, dd yyyy"))"
        }
        return ""
    }
    var cancelNote: String {
        if let expirationDate = expirationDate {
            return "If you cancel now, you can still access your subscription until \(expirationDate.string(format: "MMM, dd"))."
        }
        return ""
    }
    
    func updateActivePlan(transaction: StoreKit.Transaction) {
        productType = transaction.productType
        
        if transaction.productID == "LIFETIME001" {
            planName = "Lifetime Plan"
        } else if transaction.productID == "YEARLY001" {
            planName = "Yearly Plan"
            expirationDate = transaction.expirationDate
        }
        
        activePlan = true
    }

    
    func refreshPurchasedProducts() async {
        logger.info("\(#function)")
        // Iterate through the user's purchased products.
        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                // Check the type of product for the transaction
                // and provide access to the content as appropriate.
                logger.info("\(transaction.debugDescription)")
                updateActivePlan(transaction: transaction)
            case .unverified(let unverifiedTransaction, let verificationError):
                // Handle unverified transactions based on your
                // business model.
                logger.info("\(unverifiedTransaction.debugDescription)")
                logger.error("\(verificationError)")
            }
        }
    }
    
    var body: some View {
        List {
            
            if activePlan {
                Section("Active Plan") {
                    Label(planName, systemImage: "creditcard")
                        .listRowSeparator(.hidden, edges: .all)
                    
                    if productType == .autoRenewable {
                        Label(renewMessage, systemImage: "calendar")
                            .listRowSeparator(.hidden, edges: .all)
                    }
                }
                
                Section {
                    Button("Cancel Subscription", role: .destructive) {
                        
                    }
                } footer: {
                    Text(cancelNote)
                }
            } else {
                Section {
                    Text("No active plans")
                }
            }
            
           
            Section("All Plans") {
                ProductView(id: "LIFETIME001")
                ProductView(id: "YEARLY001")
            }
            
            
            Section {
                HStack {
                    Spacer()
                    RestorePurchasesButton()
                    Spacer()
                }
            }
            
            Section {
               
            } footer: {
                HStack {
                    Spacer()
                    Button("About Subscriptions & Privacy") {
                        
                    }
                }
            }
            
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .onInAppPurchaseCompletion { (product: Product, result: Result<Product.PurchaseResult, Error>) in
            if case .success(.success(let verificationResult)) = result {
                logger.info("onInAppPurchaseCompletion: \(verificationResult.debugDescription)")
                logger.info("onInAppPurchaseCompletion: \(product.debugDescription)")
//                updateActivePlan(transaction: transaction)
//                await BirdBrain.shared.process(transaction: transaction)
//                dismiss()
                
                let transaction: StoreKit.Transaction
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
        }
        .onAppear {
            Task {
                await refreshPurchasedProducts()
            }
        }
    }
}

struct RestorePurchasesButton: View {
    @State private var isRestoring = false
    
    var body: some View {
        Button("Restore Purchases") {
            isRestoring = true
            Task.detached {
                defer { isRestoring = false }
                try await AppStore.sync()
            }
        }
        .disabled(isRestoring)
    }
    
}
