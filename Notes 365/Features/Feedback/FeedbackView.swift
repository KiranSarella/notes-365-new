//
//  FeedbackView+iPadOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State var today = DateTime.now()
    let text = """
Thank you for using Notes 365. Please share your feedback.
"""
    let mailId = "feedback@notes365.app"
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text(text)
                    Spacer()
                }
                HStack {
                    Image(systemName: "envelope")
                    Link(mailId, destination: URL(string: "mailto:\(mailId)")!)
                    Spacer()
                }
                .padding(.vertical)
                Spacer()
            }
            .padding()
            .navigationTitle("Feedback")
            .toolbar {
#if targetEnvironment(macCatalyst)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
#endif
            }
#if DEBUG
            HStack {
                Button {
                    DateTime.changeToBeforeDay()
                    today = DateTime.now()
                } label: {
                    Text("before day")
                }

                Text(today, style: .date)

                Button {
                    DateTime.changeToNextDay()
                    today = DateTime.now()
                } label: {
                    Text("next day")
                }
            }
            .padding()
#endif
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
