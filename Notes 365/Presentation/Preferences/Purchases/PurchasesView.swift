//
//  PurchaseView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 08/07/22.
//

import SwiftUI
import StoreKit

struct PurchasesView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var store: Store
    @StateObject private var purchasesState = PurchasesState()
    @State private var errorTitle = ""
    @State private var isShowingError: Bool = false
    
    /*
     mainly three states
     - already purchased state
        - show detail view
        - or
        - retry to get purchased details (will tihs case exists?)
     - not purchased state
        - show available subscriptions view
        - or
        - retry subscriptions button view
     -
     
     */
    
    var body: some View {
        
        VStack {
            VStack {
                if purchasesState.isPurchased {
                    if let status = purchasesState.subscriptionStatus, let product = purchasesState.purchasedProduct {
                        StatusInfoView(product: product, status: status)
                    } else {
                        Button("Retry") {
                            Task {
                                if let product = purchasesState.product {
                                    purchasesState.isPurchased = (try? await store.isPurchased(product)) ?? false
                                }
                                // When this view appears, get the latest subscription status.
                                await purchasesState.updateSubscriptionStatus()
                            }
                        }
                    }
                }
                else {
                    if let product = purchasesState.product {
                        // Products View
                        Text("Get Full Access")
                            .font(.title)
                        HStack {
                            Text("create unlimited number of notebooks.")
                                .font(.body)
                            Text("3 notebooks")
                                .strikethrough()
                                .font(.body)
                                .fontWeight(.thin)
                        }
                        Group {
                            Text("\(product.displayPrice) / \(product.displayName)")
                            Button {
                                Task {
                                    do {
                                        try await purchasesState.buy()
                                    } catch StoreError.failedVerification {
                                        errorTitle = "Your purchase could not be verified by the App Store."
                                        isShowingError = true
                                    }
                                }
                            } label: {
                                Text("Buy")
                                    .padding()
                                    .padding(.bottom, 60)
                            }
                            // Restore
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
                    } else {
                        // reload product description
                        Button("Retry") {
                            Task {
                                if let product = purchasesState.product {
                                    purchasesState.isPurchased = (try? await store.isPurchased(product)) ?? false
                                }
                                // When this view appears, get the latest subscription status.
                                await purchasesState.updateSubscriptionStatus()
                            }
                        }
                    }
                }
            }
            .frame(minHeight: 300)
            .padding(40)
            .onAppear(perform: {
                Task {
                    if let product = purchasesState.product {
                        purchasesState.isPurchased = (try? await store.isPurchased(product)) ?? false
                    }
                    // When this view appears, get the latest subscription status.
                    await purchasesState.updateSubscriptionStatus()
                }
            })
            .onChange(of: store.purchasedSubscriptions) { _ in
                Task {
                    //When `purchasedSubscriptions` changes, get the latest subscription status.
                    await purchasesState.updateSubscriptionStatus()
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
    
    
}



