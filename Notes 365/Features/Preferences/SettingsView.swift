//
//  SettingsView+iPadOS.swift
//  Notes 365
//
//  Created by Kiran Sarella on 23/11/22.
//


import SwiftUI

struct SettingsView_iPadOS: View {
    
    public enum Setting: String, CaseIterable, Identifiable {
        case themes = "Themes"
        case editorSymbols = "Text Formatting Symbols"
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
            case .editorSymbols:
                return ""
            }
        }
        
        var image: String {
            switch self {
            case .themes:
                return "paintbrush"
            case .editorSymbols:
                return "textformat"
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
    @State private var selectedTheme: MarkdownTheme?// = MarkdownTheme(id: UUID())
    
    @State private var showThemeDetail = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                List {
                    Section("") {
                        NavigationLink {
                            List {
                                Picker("Light", selection: $selectedLightThemeID) {
                                    ForEach(themesListState.themes) { theme in
                                        Text(theme.themeName).tag(theme.id)
                                    }
                                }
                                .tag(selectedLightThemeID)
                                
                                Picker("Dark", selection: $selectedDarkThemeID) {
                                    ForEach(themesListState.themes) { theme in
                                        Text(theme.themeName).tag(theme.id)
                                    }
                                }
                                .tag(selectedDarkThemeID)
                                
                                Section("Themes") {
                                    ForEach(themesListState.themes, id:\.self) { theme in
                                        Button(theme.themeName) {
                                            selectedTheme = theme
                                            showThemeDetail = true
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .onChange(of: selectedLightThemeID) { newValue in
                                themesListState.saveLightTheme(newValue)
                            }
                            .onChange(of: selectedDarkThemeID) { newValue in
                                themesListState.saveDarkTheme(newValue)
                            }
                            .navigationTitle("Themes")
                            .sheet(item: $selectedTheme, content: { theme in
                                NavigationStack {
                                    ThemeDetailView_iOS(theme: theme, onThemeChange: { value in
                                        themesListState.saveChanges(value)
                                    })
                                }
                            })
                        } label: {
                            let selectedMode = Setting.themes
                            HStack(spacing: 0) {
                                Image(systemName: selectedMode.image)
                                    .imageScale(.large)
                                VStack(alignment: .leading) {
                                    Text(selectedMode.name)
                                        .font(.system(Font.TextStyle.title2))
                                }.padding(.leading)
                            }.padding(6)
                        }
                    }
                    
                    Section("") {
                        NavigationLink {
                            EditorSymbolsView()
                        } label: {
                            let selectedMode = Setting.editorSymbols
                            HStack(spacing: 0) {
                                Image(systemName: selectedMode.image)
                                    .imageScale(.large)
                                VStack(alignment: .leading) {
                                    Text(selectedMode.name)
                                        .lineLimit(1)
                                        .font(.system(Font.TextStyle.title2))
                                }.padding(.leading)
                            }.padding(6)
                        }
                        
                        NavigationLink {
                            FeedbackView_iPadOS()
                        } label: {
                            let selectedMode = Setting.feedback
                            HStack(spacing: 0) {
                                Image(systemName: selectedMode.image)
                                    .imageScale(.large)
                                VStack(alignment: .leading) {
                                    Text(selectedMode.name)
                                        .font(.system(Font.TextStyle.title2))
                                }.padding(.leading)
                            }.padding(6)
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                #if targetEnvironment(macCatalyst)
                Button("Close") {
                    showModel = false
                }
                #endif
            }
        }
        .onAppear {
            selectedLightThemeID = themesListState.selectedLightTheme.id
            selectedDarkThemeID = themesListState.selectedDarkTheme.id
        }
    }
}

//struct SettingsView_iPadOS_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView_iPadOS(showModel: <#Binding<Bool>#>)
//    }
//}


