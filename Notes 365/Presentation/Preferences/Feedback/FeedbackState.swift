//
//  FeedbackState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 22/11/22.
//

import SwiftUI

class FeedbackState: ObservableObject {
    
    enum Subject: String, CaseIterable, Identifiable {
        case feedback = "feedback"
        case issue = "issue"
        case feature = "feature request"
        case other = "other"
        
        var id: Self { self }
    }
    
    @Published var subject: Subject = Subject.feedback
    @Published var message: String = ""
 
    
    func sendMail(recipients: [String]) {
        #if os(macOS)
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = recipients
        service.subject = subject.rawValue
        service.perform(withItems: [message])
        #endif
    }
}
