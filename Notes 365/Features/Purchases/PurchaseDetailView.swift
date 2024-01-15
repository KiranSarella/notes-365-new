//
//  PurchaseDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI
import StoreKit

struct PurchaseDetailView: View {
    @Environment(\.openURL) private var openURL
    @State var state = PurchaseDetailState()
    
    var renewMessage: String {
        if let expirationDate = state.expirationDate {
            return "Renews \(String(describing: expirationDate.string(format: "MMM, dd yyyy")))"
        }
        return ""
    }
    var cancelNote: String {
        if let expirationDate = state.expirationDate {
            return "If you cancel now, you can still access your subscription until \(expirationDate.string(format: "MMM, dd"))."
        }
        return ""
    }
    
    var body: some View {
        List {
            if state.activePlan {
                Section("Active Plan") {
                    Label(state.planName, systemImage: "creditcard")
                        .listRowSeparator(.hidden, edges: .all)
                    
                    if state.productType == .autoRenewable {
                        Label(renewMessage, systemImage: "calendar")
                            .listRowSeparator(.hidden, edges: .all)
                    }
                }
                if state.productType == .autoRenewable {
                    Section {
                        Button("Cancel Subscription", role: .destructive) {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } footer: {
                        Text(cancelNote)
                    }
                }
                
            } else {
                Section {
                    Text("No active plan")
                }
            }
           
            Section("All Plans") {
                ProductView(id: "LIFETIME001")
                ProductView(id: "YEARLY002")
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
                    Button {
                        if let url = URL(string: "https://www.notes365.app/privacy") {
                            openURL(url)
                        }
                    } label: {
                        Text("Privacy Policy")
                            .padding()
                    }
                    
                    Button {
                        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                            openURL(url)
                        }
                    } label: {
                        Text("Terms of Use")
                    }
                }
            }
            
        }
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .onInAppPurchaseCompletion { (product: Product, result: Result<Product.PurchaseResult, Error>) in
            await PremiumUserState.shared.handleInAppPurchase(product: product, result: result)
//            guard case .success(let verificationResult) = purchaseResult,
//                  case .success(_) = verificationResult else {
//                return
//            }
//            showingSubscriptionStore = false
        }
        .onAppear {
            Task {
                await PremiumUserState.shared.refreshPurchasedProducts()
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

@Observable
class PurchaseDetailState {
    var activePlan = false
    var planName: String = ""
    var productType: Product.ProductType?
    var expirationDate: Date?
    
    var premiumStateObserver: NSObjectProtocol?
    
    init() {
        observeChanges()
    }
    
    deinit {
        premiumStateObserver = nil
    }
    
    func observeChanges() {
        premiumStateObserver = NotificationCenter.default.addObserver(forName: .premiumStateChange, object: nil, queue: .main) { notification in
            Task {
                await self.updateDetail()
            }
        }
    }
    
    func updateDetail() async {
        planName = await PremiumUserState.shared.planName
        productType = await PremiumUserState.shared.productType
        expirationDate = await PremiumUserState.shared.expirationDate
        activePlan = await PremiumUserState.shared.isPurchased
        logger.debug("\(#function)")
        logger.debug("\(self.planName) \(self.activePlan)")
    }
    
    func cleanActivePlan() {
        activePlan = false
        planName = ""
        productType = nil
        expirationDate = nil
        logger.debug("\(#function)")
    }
    
}
