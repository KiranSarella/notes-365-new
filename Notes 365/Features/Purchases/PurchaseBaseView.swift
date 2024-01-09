//
//  PurchaseBaseView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI
import StoreKit

struct PurchaseBaseView: View {
    @Environment(\.dismiss) var dismiss
    
    var purchased: Bool = false
    
    var body: some View {
//        StoreView(ids: ["LIFETIME001", "YEARLY001"])
        
        NavigationStack {
            VStack {
                PurchaseDetailView()
//                PurchaseOptionsView()
//                
//                if purchased {
//                    PurchaseDetailView()
//                        .navigationTitle("Current Subscription")
//                } else {
//                    PurchaseOptionsView()
////                    StoreView(ids: ["LIFETIME001", "YEARLY001"])
//                        .navigationTitle("Get Full Access")
//                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}
