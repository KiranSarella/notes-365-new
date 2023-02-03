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
        case feedback = "Feedback"
        
        public var id: String { self.name }
        
        var name: String {
            return self.rawValue
        }
        
        var description: String {
            switch self {
            case .themes:
                return "customized 1"
            case .feedback:
                return ""
            }
        }
        
        var image: String {
            switch self {
            case .themes:
                return "paintbrush"
            case .feedback:
                return "hand.thumbsup"
            }
        }
        
        static func getMode(id: String?) -> Self? {
            guard let id = id else { return nil }
            return Setting(rawValue: id)
        }
        
    }

    @Binding var showModel: Bool
    
    @StateObject private var themesListState = ThemesListState()
    
    @State private var selectedModeID: Mode.ID?
    
    @State private var selectedLightThemeID: MarkdownTheme.ID = UUID()
    @State private var selectedDarkThemeID: MarkdownTheme.ID = UUID()
    
    
    @State private var selectedThemeID: MarkdownTheme.ID?
    @State private var selectedTheme: MarkdownTheme?
    
    @State private var showThemeDetail = false
    
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
                        
                        List {
                            Picker("Light", selection: $selectedLightThemeID) {
                                ForEach(themesListState.themes) { theme in
                                    Text(theme.themeName).tag(theme.id)
                                }
                            }
                            Picker("Dark", selection: $selectedDarkThemeID) {
                                ForEach(themesListState.themes) { theme in
                                    Text(theme.themeName).tag(theme.id)
                                }
                            }
                            
                            Section("Themes") {
                                ForEach(themesListState.themes, id:\.self) { theme in
                                    
//                                    Button {
//                                        showThemeDetail = true
//                                    } label: {
//                                        
//                                        HStack {
//                                            Text(theme.themeName)
//                                            Spacer()
//                                            Image(systemName: "chevron.right")
//                                                .foregroundColor(.gray)
//                                                .fixedSize()
//                                                .frame(width: 8, height: 8)
//                                        }
//                                        
//                                    }

                                    
//                                    Button(theme.themeName) {
//                                        showThemeDetail = true
//                                    }
                                    
                                    NavigationLink {
                                        ThemeDetailView_iOS()
                                    } label: {
                                        Text(theme.themeName)
                                    }

                                    
//                                    NavigationLink(theme.themeName, value: selectedTheme)
                                    
//                                    Text(theme.themeName).tag(theme.id)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                            }
//                            .sheet(isPresented: $showThemeDetail) {
//                                ThemeDetailView_iOS(showThemeDetail: $showThemeDetail)
//                            }
//                            .navigationDestination(for: MarkdownTheme.self) { selectedTheme in
//                                Text(selectedTheme.themeName)
//                            }
                            
                        }
                        .navigationTitle("Themes")
                        
                        
                    case .feedback:
                        FeedbackView_iPadOS()
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                Button("Done") {
                    showModel = false
                }
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

//struct SettingsView_iPadOS_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView_iPadOS(showModel: <#Binding<Bool>#>)
//    }
//}


#endif
