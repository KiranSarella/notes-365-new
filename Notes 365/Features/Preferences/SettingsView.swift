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
        case editorSymbols = "Text Format Symbols"
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
                            .tag(selectedLightThemeID)
                            
                            Picker("Dark", selection: $selectedDarkThemeID) {
                                ForEach(themesListState.themes) { theme in
                                    Text(theme.themeName).tag(theme.id)
                                }
                            }
                            .tag(selectedDarkThemeID)
                            
                            Section("Themes") {
                                ForEach(themesListState.themes, id:\.self) { theme in
                                    
//                                    Text(theme.themeName)
                                    
//                                    Button {
////                                        showThemeDetail = true
//
//                                        NavigationLink(theme.themeName, value: selectedTheme)
//
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

                                    
                                    Button(theme.themeName) {
                                        
                                        selectedTheme = theme
//                                        print(selectedTheme?.id, selectedTheme?.themeName)
                                        showThemeDetail = true
                                        
                                       
                                        
//                                        selectedTheme = theme
//                                        print(selectedTheme?.id, selectedTheme?.themeName)
                                    }
                                    
//                                    NavigationLink {
//                                        ThemeDetailView_iOS(theme: theme, onThemeChange: { value in
//                                            print(value)
////                                            theme = value
////                                            themesListState.saveChanges(value)
//                                        }).tag(theme.id)
//                                    } label: {
//                                        Text(theme.themeName)
//                                    }

                                    
//                                    NavigationLink(theme.themeName, value: selectedTheme)
                                    
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
//                        .listStyle(InsetGroupedListStyle())
                        .onAppear {
                            
//                            selectedLightThemeID = themesListState.themes.first!.id
//                            selectedDarkThemeID = themesListState.themes.first!.id
                            
//                            print(selectedLightThemeID)
//                            selectedThemeID = ThemeState.shared.theme.id
//                            selectedLightThemeID = themesListState.selectedLightTheme.id
//                            selectedDarkThemeID = themesListState.selectedDarkTheme.id
//                            print(selectedLightThemeID)
//                            print(themesListState.themes)
                        }
                        .sheet(item: $selectedTheme, content: { theme in
                            NavigationStack {
                                ThemeDetailView_iOS(theme: theme, onThemeChange: { value in
//                                    selectedTheme = value
                                    themesListState.saveChanges(value)
                                })
                            }
                        })
//                        .sheet(isPresented: $showThemeDetail) {
//
//                            if selectedTheme == nil {
////                               Text("invalid selection")
//                            } else {
//                                NavigationStack {
//                                    ThemeDetailView_iOS(theme: selectedTheme, onThemeChange: { value in
//                                        selectedTheme = value
//                                        themesListState.saveChanges(value)
//                                    })
//                                }
//                            }
//                        }
//                        .navigationDestination(for: MarkdownTheme.self) { selectedTheme in
////                            Text(selectedTheme.themeName)
//                            ThemeDetailView_iOS(theme: selectedTheme, onThemeChange: { value in
//                                // print(value)
////                                  theme = value
//                                 themesListState.saveChanges(value)
//                            })
//                        }
                        
                    case .editorSymbols:
                        EditorSymbolsView()
                    case .feedback:
                        FeedbackView_iPadOS()
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
            
//            selectedTheme = ThemeState.shared.theme
//
//            showThemeDetail = true
//            showThemeDetail = false
//
            
//            selectedTheme = theme
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


