//
//  PurchaseBaseView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI

struct PurchaseBaseView: View {
    @Environment(\.dismiss) var dismiss
    
    var purchased: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if purchased {
                    PurchaseDetailView()
                        .navigationTitle("Current Subscription")
                } else {
                    PurchaseOptionsView()
                        .navigationTitle("Get Full Access")
                }
            }
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

#Preview {
    PurchaseBaseView()
}
