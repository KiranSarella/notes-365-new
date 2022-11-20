//
//  PurchaseSettingsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 08/07/22.
//

import SwiftUI
import StoreKit

struct PurchaseSettingsView: View {
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject var store: Store
    
    /*
     1. purchase screen
     2. purchase status screen
     3. subscription was expired screen
     */
    
    var product: Product {
        store.subscriptions.first!
    }
    
//    var isSubscribed: Bool {
//        store.purchasedSubscriptions.count != 0
//    }
    
    @State var isPurchased: Bool = false
    
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    @State var status: Product.SubscriptionInfo.Status?
    
    var body: some View {
        
        VStack {
            
        VStack {
            
//            if isPurchased {
                
                if let status = status {
                    
                    StatusInfoView(product: product,
                                   status: status)
                }
                
//                Text("you are subscribed to \(store.purchasedSubscriptions.first!.displayName) - \(store.purchasedSubscriptions.first!.displayPrice)")
                
//                Text("\(store.purchasedSubscriptions.first!.subscription)")
                
//            }
        else {
                
//                if let subscriptionState = store.subscriptionGroupStatus {
//                    switch subscriptionState {
//                    case .expired:
//                        Text("Your current subscription was expired.")
//                    case .inBillingRetryPeriod:
//                        Text("Your current subscription was in billing retry period.")
//                    case .inGracePeriod:
//                        Text("Your current subscription was in grace period.")
//                    case .revoked:
//                        Text("Your current subscription was revoked.")
//                    default:
//                        EmptyView()
//                    }
//                }
//
//                Text("Currently you can create only five notebooks.")
//                    .font(.caption)
//                    .padding(.bottom, 60)
//
                Text("Get Full Access")
                    .font(.title)
            
            HStack {
                Text("create unlimited number of notebooks.")
                    .font(.body)
                Text("3 notebooks")
                    .strikethrough()
                    .font(.caption)
            }
                
                
                
                
                Group {
                    
                    Text("\(product.displayPrice) / \(product.displayName)")
                    
                    Button {
                        
                        Task {
                            await buy()
                        }
                        
                    } label: {
                        Text("Buy")
                        .padding()
                        .padding(.bottom, 60)
                    }
                    
                    Button {
                        Task {
                            //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                            //Call this function only in response to an explicit user action, such as tapping a button.
                            try? await AppStore.sync()
                        }
                    } label: {
                        Text("Restore Purchases")
                            .foregroundColor(.blue)
                        
                    }.buttonStyle(.plain)
                    
                }.padding()
                    .alert(isPresented: $isShowingError, content: {
                        Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
                    })
                
//                Spacer()
            }
        }
        .frame(minHeight: 300)
        .padding(40)
        .onAppear(perform: {
            Task {
                isPurchased = (try? await store.isPurchased(product)) ?? false
                //When this view appears, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        })
        .onChange(of: store.purchasedSubscriptions) { _ in
            Task {
                //When `purchasedSubscriptions` changes, get the latest subscription status.
                await updateSubscriptionStatus()
            }
        }
        
            Spacer()
            
            // terms, privacy links
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
                        .padding()
                }
                
                
            }
            .padding()
            #if os(macOS)
            .buttonStyle(.link)
            #endif            
        }
        
    }
    
    func buy() async {
        do {
            if try await store.purchase(product) != nil {
                withAnimation {
                    isPurchased = true
                }
            }
        } catch StoreError.failedVerification {
            errorTitle = "Your purchase could not be verified by the App Store."
            isShowingError = true
        } catch {
            print("Failed purchase for \(product.id): \(error)")
        }
    }
    
    @MainActor
    func updateSubscriptionStatus() async {
        do {
            //This app has only one subscription group, so products in the subscriptions
            //array all belong to the same group. The statuses that
            //`product.subscription.status` returns apply to the entire subscription group.
            guard let product = store.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }
            
            var highestStatus: Product.SubscriptionInfo.Status? = nil
            var highestProduct: Product? = nil
            
            //Iterate through `statuses` for this subscription group and find
            //the `Status` with the highest level of service that isn't
            //in an expired or revoked state. For example, a customer may be subscribed to the
            //same product with different levels of service through Family Sharing.
            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    continue
                default:
                    let renewalInfo = try store.checkVerified(status.renewalInfo)
                    
                    //Find the first subscription product that matches the subscription status renewal info by comparing the product IDs.
                    guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
                        continue
                    }
                    
                    guard let currentProduct = highestProduct else {
                        highestStatus = status
                        highestProduct = newSubscription
                        continue
                    }
                    
                    let highestTier = store.tier(for: currentProduct.id)
                    let newTier = store.tier(for: renewalInfo.currentProductID)
                    
                    if newTier > highestTier {
                        highestStatus = status
                        highestProduct = newSubscription
                    }
                }
            }
            
            status = highestStatus
//            currentSubscription = highestProduct
        } catch {
            print("Could not update subscription status \(error)")
        }
    }
}
