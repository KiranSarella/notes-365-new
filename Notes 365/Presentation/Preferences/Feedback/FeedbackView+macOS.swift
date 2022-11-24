//
//  FeedbackSettingsView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/11/22.
//

import SwiftUI


struct FeedbackView: View {
   
    @StateObject private var feedbackState = FeedbackState()
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Subject:")
                    Picker("", selection: $feedbackState.subject) {
                        ForEach(FeedbackState.Subject.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                }
                HStack(alignment: .top) {
                    Text("Message:")
                    HStack {
                        VStack {
                            TextEditor(text: $feedbackState.message)
                                .frame(height: 160)
                            HStack {
                                Text("mailto:feedback@notes365.app")
                                Spacer()
                                Button {
                                    feedbackState.sendMail(recipients: ["feedback@notes365.app"])
                                } label: {
                                    Text("send")
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(50)
        }
        
        
    }
}
