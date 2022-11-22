//
//  PreferencesView.swift
//  Notes 365 (macOS)
//
//  Created by Kiran Sarella on 09/02/22.
//

#if os(macOS)

import SwiftUI
import AppKit
import StoreKit

struct PreferencesView: View {
    
    var body: some View {
        TabView {
            
            TheamSettingsView()
                .tabItem {
                    Label("Themes", systemImage: "paintbrush")
                }
            
            PurchaseSettingsView()
                .tabItem {
                    Label("Purchases", systemImage: "cart")
                }
            
//            AppearanceSettingsView()
//                .tabItem {
//                    Label("Appearance", systemImage: "paintpalette")
//                }
            
            FeedbackView()
                .tabItem {
                        Label("Feedback", systemImage: "hand.thumbsup")
                    }
            
//            PrivacySettingsView()
//                .tabItem {
//                    Label("Privacy", systemImage: "hand.raised")
//                }
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


struct AppearanceSettingsView: View {
    var body: some View {
        Text("Appearance Settings")
            .font(.title)
    }
}


struct PrivacySettingsView: View {
    
 
    var body: some View {
        Text("Privacy Settings")
            .font(.title)
    }
}




#endif
