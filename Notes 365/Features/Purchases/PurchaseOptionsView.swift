//
//  PurchaseOptionsView.swift
//  Notes 365
//
//  Created by kiran ipc on 02/01/24.
//

import SwiftUI

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
                 VStack {
//                     HStack {
//                         Text("Get Full Access")
//                             .font(.title)
//                         Spacer()
//                     }
                    
                     HStack {
                         Button {
                             
                         } label: {
                             HStack {
                                 Text(yearlyTitle)
                                     .font(.system(.title2))
                             }
                             .frame(minWidth: 300)
                         }
                         .buttonStyle(.borderedProminent)
                         .buttonBorderShape(.roundedRectangle(radius: 4))
                         .controlSize(.large)
                         .padding()
                     }
                   
                     HStack {
                         Button {
                             
                         } label: {
                             HStack {
                                 Text(lifetimeTitle)
                                     .font(.system(.title2))
                             }
                             .frame(minWidth: 300)
                         }
                         .buttonStyle(.borderedProminent)
                         .buttonBorderShape(.roundedRectangle(radius: 4))
                         .controlSize(.large)
                         .padding()
                     }
                    
                     HStack {
                         Button {
                             
                         } label: {
                             Text("Restore Purchases")
                                 .foregroundStyle(Color.blue)
                         }
                         .padding()
                     }
                }
                 
            }
        
       
    }
}

#Preview {
    PurchaseOptionsView()
}

@Observable
class PurchaseOptionsState {
    var hasFullAccess = true
    var yearlyPrice: CGFloat = 799
    var lifeTimePrice: CGFloat = 2999
    
}
