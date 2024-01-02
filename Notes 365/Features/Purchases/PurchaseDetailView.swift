//
//  PurchaseDetailView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI

struct PurchaseDetailView: View {
    
    var cancelNote: String {
        "Aenean lacinia bibendum nulla sed consectetur. Cras mattis consectetur purus sit amet fermentum."
    }
    
    var body: some View {
        List {
            Section {
                Label("$7.99 yearly", systemImage: "creditcard")
                    .listRowSeparator(.hidden, edges: .all)
                Label("Renews Nov 5, 2024", systemImage: "calendar")
                    .listRowSeparator(.hidden, edges: .all)
            }
            
            Section {
                Button("Cancel Subscription", role: .destructive) {
                    
                }
            } footer: {
                Text(cancelNote)
            }

//                .font(.caption2)
            
            Section {
               
            } footer: {
                HStack {
                    Spacer()
                    Button("About Subscriptions & Privacy") {
                        
                    }
                }
            }
        }
    }
}

#Preview {
    PurchaseDetailView()
}
