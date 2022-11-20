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
            
            FeedbackSettingsView()
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



struct FeedbackSettingsView: View {
    
    enum Subject: String, CaseIterable, Identifiable {
        
        case feedback = "feedback"
        case issue = "issue"
        case feature = "feature request"
        case other = "other"
        
        var id: Self { self }
    }
    
    @State private var subject: Subject = Subject.feedback
    @State private var message: String = ""
    
    var body: some View {
        
        VStack {
            
            
            VStack(alignment: .leading) {
                //            Section(header: Text("Feedback")) {
                
                HStack {
                    Text("Subject:")
                    Picker("", selection: $subject) {
                        ForEach(Subject.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                }
                
                HStack(alignment: .top) {
                    Text("Message:")
                    
                    HStack {
                        VStack {
                            TextEditor(text: $message)
                                .frame(height: 160)
                            HStack {
                                Text("mailto:feedback@notes365.app")
                                Spacer()
                                Button {
                                    let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
                                    service.recipients = ["feedback@notes365.app"]
                                    service.subject = subject.rawValue
                                    service.perform(withItems: [message])
                                } label: {
                                    Text("send")
                                }
                            }
                        }
                    }
                }
                //            }
                
                //            Section(header: Text("Rating")) {
                //
                //            }
                
                Spacer()
                
                
            }
            .padding(50)
            
//            HStack() {
//                Spacer()
//                Text("We all need people who will give us feedback. That's how we improve   -- Bill Gates")
//                    .fontWeight(Font.Weight.ultraLight)
//                    .opacity(0.6)
//                    .padding(.vertical)
//                Spacer()
//            }
        }
        
        
    }
}


#endif
