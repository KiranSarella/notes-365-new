//
//  ContentView.swift
//  Notes 365
//
//  Created by Kiran Sarella on 13/11/22.
//

import SwiftUI

public enum SidebarItem: String, CaseIterable, Identifiable {
    public var id: String { self.rawValue }
    case timeline
    case notebooks
    case recents
    case search
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @State var settingsExpanded = true
    @State private var showThemes = false
    @State private var showFormattingSymbols = false
    @State private var showPurchases = false
    @State private var showFeedback = false
    @State private var sidebarItemSelected: SidebarItem.ID? = SidebarItem.timeline.id
    @State private var selectedNotebookM: Notebook?
    @State var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    var todayVersionBusiness = BusinessFactory.dayVersionInteractor()
    @State private var timelineDetailState = TimelineBaseViewState(timelineBusiness: BusinessFactory.timelineInteractor())
    @State private var path = NavigationPath()
    @State private var horizontalCalendarViewState = HorizontalCalendarViewState()
    let cloudKitSync = CloudKitSync()
    
    let iconWidth: CGFloat = 18
    
    var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            VStack {
                List(selection: $sidebarItemSelected) {
                    Label {
                        Text("Timeline")
                    } icon: {
                        Image(systemName: "calendar")
//                        Image(systemName: "rectangle.stack.fill")
                            .circularIconStyle(background: .purple)
                    }
                    .tag(SidebarItem.timeline.id)
                        
                    Label {
                        Text("Notebooks")
                    } icon: {
                        Image(systemName: "books.vertical.fill")
                            .circularIconStyle(background: .pink)
                    }
                    .tag(SidebarItem.notebooks.id)
                    
                    Label {
                        Text("Recents")
                    } icon: {
                        Image(systemName: "clock.fill")
                            .circularIconStyle(background: .orange)
                    }
                    .tag(SidebarItem.recents.id)
                    
                    Label {
                        Text("Search")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                            .circularIconStyle(background: .indigo)
                    }
                    .tag(SidebarItem.search.id)
                    
                    Section("Settings", isExpanded: $settingsExpanded) {
                        Button {
                            showThemes = true
                        } label: {
                            Label {
                                Text("Themes")
                            } icon: {
                                Image(systemName: "paintbrush.fill")
                                    .circularIconStyle(background: .red)
                            }
                        }
                        Button {
                            showFormattingSymbols = true
                        } label: {
                            Label {
                                Text("Symbols Guide")
                            } icon: {
                                Image(systemName: "textformat")
                                    .circularIconStyle(background: .teal)
                            }
                        }
                        
                        Button {
                            showPurchases = true
                        } label: {
                            Label {
                                Text("Full Access")
                            } icon: {
                                Image(systemName: "lock.open.fill")
                                    .circularIconStyle(background: .yellow)
                            }
                        }
                        
                        Button {
                            showFeedback = true
                        } label: {
                            Label {
                                Text("Feedback")
                            } icon: {
                                Image(systemName: "hand.thumbsup.fill")
                                    .circularIconStyle(background: .blue)
                            }
                        }
                    }
                    
//                    if cloudKitSync.isImportDone == false {
//                        ProgressView("Syncing..")
//                    }
                }
                .navigationTitle("Notes 365")
                .onAppear {
                    BusinessFactory.dayVersionInteractor().setupDayVersionCreationProcess()
                    BusinessFactory.timelineInteractor().setupTimeineCreationProcess()
                    BusinessFactory.recentsInteractor().setupRecentsAddingProcess()
                }
                .sheet(isPresented: $showThemes) {
                    ThemesBaseView()
                }
                .sheet(isPresented: $showFormattingSymbols) {
                    EditorSymbolsView()
                }
                .sheet(isPresented: $showPurchases) {
                    PurchaseBaseView()
                }
                .sheet(isPresented: $showFeedback) {
                    FeedbackView()
                }
                .onAppear {
                    ThemeState.shared.updateColorScheme(colorScheme)
                }
                .onChange(of: colorScheme, { oldValue, newValue in
                    if ThemeState.shared.colorScheme != newValue {
                        ThemeState.shared.updateColorScheme(newValue)
                    }
                })
                .onChange(of: sidebarItemSelected) { oldValue, newValue in
                    if newValue == SidebarItem.timeline.rawValue {
                        path = NavigationPath()
                    }
                }
            }
            
        }
        detail: {
            let selectedItem = SidebarItem(rawValue: sidebarItemSelected ?? SidebarItem.timeline.id)!
            switch selectedItem {
            case .timeline:
                TimelineBaseView(state: $timelineDetailState, horizontalCalendarViewState: $horizontalCalendarViewState)
            case .notebooks:
                NotebooksBaseDetailView(path: $path)
            case .search:
                ContentSearchView()
            case .recents:
                RecentsBaseDetailView(path: $path)
            }
        }
    }
}

struct CircleIcon: View {
    let systemName: String
    let background: Color
    var body: some View {
        Image(systemName: systemName)
          .resizable()
          .fontWeight(.bold)
          .frame(width: 18, height: 18)
          .foregroundColor(.white)
          .padding(6)
          .background(background)
          .clipShape(Circle())
    }
}


extension Image {
    func circularIconStyle(background: Color) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 18, height: 18, alignment: .center)
            .foregroundColor(.white)
            .padding(6)
            .background(background)
            .clipShape(Circle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

