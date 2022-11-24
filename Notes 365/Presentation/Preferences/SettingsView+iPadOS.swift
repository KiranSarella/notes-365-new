//
//  SettingsView+iPadOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//

#if os(iOS)

import SwiftUI

struct SettingsView_iPadOS: View {
    
    public enum Setting: String, CaseIterable, Identifiable {
        case themes = "Themes"
        case purchases = "Purchases"
        case feedback = "Feedback"
        
        public var id: String { self.name }
        
        var name: String {
            return self.rawValue
        }
        
        var description: String {
            switch self {
            case .themes:
                return "customized 1"
            case .purchases:
                return "yearly - 2020 april"
            case .feedback:
                return ""
            }
        }
        
        var image: String {
            switch self {
            case .themes:
                return "paintbrush"
            case .purchases:
                return "cart"
            case .feedback:
                return "hand.thumbsup"
            }
        }
        
        static func getMode(id: String?) -> Self? {
            guard let id = id else { return nil }
            return Setting(rawValue: id)
        }
        
    }
    
//    enum Setting: Hashable, Identifiable {
//        var id: ObjectIdentifier
//
//        case themes
//        case purchases
//        case feedback
//    }
//
//    struct Setting: Hashable, Identifiable {
//        let id = UUID()
//        let name: String
//        let image: String
//        var description: String?
//    }
    
//    @State private var options: [Setting] = []
//
//    @State private var selectedOption: Setting?
    
    @State private var selectedModeID: Mode.ID?
    
    var body: some View {
        
        NavigationStack {
            VStack {
                List(Setting.allCases, selection: $selectedModeID) { selectedMode in
                    NavigationLink(value: selectedMode) {
                        HStack(spacing: 0) {
                            Image(systemName: selectedMode.image)
                                .imageScale(.large)
//                                .frame(width: 80, height: 80)
                            
                            VStack(alignment: .leading) {
                                Text(selectedMode.name)
                                    .font(.system(Font.TextStyle.title2))
//                                Text(selectedMode.description)
//                                    .font(.system(Font.TextStyle.caption))
                                
                            }.padding(.leading)
                        }.padding(6)
                    }
                }
                .navigationDestination(for: Setting.self) { option in
                    switch option {
                    case .themes:
                        Text("inprogress")
                    case .purchases:
                        PurchaseSettingsView()
                    case .feedback:
                        FeedbackView_iPadOS()
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        
        
        
//        List(options, selection: $selectedOption) { option in
//            HStack(spacing: 0) {
//                Image(systemName: option.image)
//                Text(option.name)
//                    .padding(.horizontal)
//            }
//        }.onAppear {
//
//            options = [
//                Setting(name: "Themes", image: "paintbrush"),
//                Setting(name: "Purchases", image: "cart"),
//                Setting(name: "Feedback", image: "hand.thumbsup"),
//            ]
//
//            selectedOption = .
//        }
    }
}

struct SettingsView_iPadOS_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView_iPadOS()
    }
}


#endif
