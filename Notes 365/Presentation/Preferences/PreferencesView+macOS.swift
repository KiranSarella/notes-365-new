//
//  PreferencesView.swift
//  Notes 365 (macOS)
//
//  Created by Kiran Sarella on 09/02/22.
//

#if os(macOS)

import SwiftUI
//import AppKit
//import StoreKit

struct PreferencesView: View {
    
    var body: some View {
        TabView {
            
            ThemesListView()
                .tabItem {
                    Label("Themes", systemImage: "paintbrush")
                }
            
            PurchaseSettingsView()
                .tabItem {
                    Label("Purchases", systemImage: "cart")
                }
            
            FeedbackView()
                .tabItem {
                    Label("Feedback", systemImage: "hand.thumbsup")
                }
        }
        .frame(minWidth: 960, minHeight: 500)
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
            .previewLayout(.device)
    }
}




#endif
