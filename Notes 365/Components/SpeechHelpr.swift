//
//  SpeechHelpr.swift
//  Notes 365
//
//  Created by Kiran Sarella on 08/08/22.
//

import Foundation
import AVFoundation
import NaturalLanguage

class SpeechHelper: NSObject {
    
    let defaultLanguageVoice = "en-US"
    
    let synth = AVSpeechSynthesizer()
    
    var finished: (() -> ())?
    
    func startSpeech(string: String) {
        
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(string)
        
        let utterance = AVSpeechUtterance(string: string)
//        if let langVoice = languageRecognizer.dominantLanguage?.rawValue {
//            utterance.voice = AVSpeechSynthesisVoice(language:  langVoice)
//        }
        utterance.voice = AVSpeechSynthesisVoice(language:  defaultLanguageVoice)
        
        utterance.voice = AVSpeechSynthesisVoice.speechVoices().first { $0.name.contains("Samantha") }
        
        utterance.rate = 0.25
//        utterance.prefersAssistiveTechnologySettings = true
        
        synth.speak(utterance)
        
        synth.delegate = self
    }
    
//    func startSpeech(attributedStting: NSAttributedString) {
//
//        let utterance = AVSpeechUtterance(attributedString: attributedStting)
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        utterance.rate = 0.3
//        
//        synth.speak(utterance)
//
//        synth.delegate = self
//    }
    
    
    
    func pauseSpeech() {
        synth.pauseSpeaking(at: .word)
    }
    
    func stopSpeech() {
        synth.stopSpeaking(at: .word)
    }
    
    func continueSpeech() {
        synth.continueSpeaking()
    }
}

extension SpeechHelper: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        finished?()
    }
    
}
