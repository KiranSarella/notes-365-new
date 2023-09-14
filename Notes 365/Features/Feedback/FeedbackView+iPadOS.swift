//
//  FeedbackView+iPadOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

import SwiftUI
import MessageUI

struct FeedbackView_iPadOS: View {
    
    @State private var feedbackState = FeedbackState()
    
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    
    var enableSendButton: Bool {
        canSendMail && (feedbackState.message.count > 0)
    }
    
    var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                Text("feedback@notes365.app")
                HStack {
                    Text("Subject")
                    Picker("", selection: $feedbackState.subject) {
                        ForEach(FeedbackState.Subject.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                }
                HStack(alignment: .top) {
                    HStack {
                        VStack {
                            TextEditor(text: $feedbackState.message)
                                .frame(height: 160)
                                .border(.gray)
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        if canSendMail {
                            self.isShowingMailView.toggle()
                        }
                    } label: {
                        Text("send")
                    }
                    .disabled(!enableSendButton)
                }
                HStack {
                    Spacer()
                    Text("Can't send emails from this device")
                        .opacity(canSendMail ? 0 : 1)
                        .fontWeight(.ultraLight)
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                Spacer()
            }
            .padding(50)
        }
        .navigationTitle("Feedback")
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: $result) { composer in
                composer.setSubject(feedbackState.subject.rawValue)
                composer.setMessageBody(feedbackState.message, isHTML: false)
                composer.setToRecipients(["feedback@notes365.app"])
            }
        }
        
        
    }
}

struct FeedbackView_iPadOS_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView_iPadOS()
    }
}
