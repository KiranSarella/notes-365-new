//
//  SpeechState.swift
//  Notes 365
//
//  Created by Kiran Sarella on 18/11/22.
//

import SwiftUI

class SpeechHelperState: ObservableObject {
    
    @Published var speechState = SpeechState.stopped
    
    let speechHelper = SpeechHelper()
    
    
}

