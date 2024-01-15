//
//  PurchaseOptionsView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI
import StoreKit

struct PurchaseOptionsView: View {
    var state = PurchaseOptionsState()
    
    var yearlyTitle: String {
        "\(String(format: "%.0f", state.yearlyPrice)) / Year"
    }
    
    var lifetimeTitle: String {
        "\(String(format: "%.0f", state.lifeTimePrice)) / Lifetime"
    }
    
    var body: some View {
        ScrollView {
            ProductView(id: "LIFETIME001")
                .padding()
            ProductView(id: "YEARLY002")
                .padding()
        }
       
    }
}

#Preview {
    PurchaseOptionsView()
}

@Observable
class PurchaseOptionsState {
    var hasFullAccess = true
    var yearlyPrice: CGFloat = 0
    var lifeTimePrice: CGFloat = 0
}
